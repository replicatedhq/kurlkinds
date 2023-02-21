/*
Copyright 2022 Replicated Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
package lint

import (
	"bytes"
	"context"
	"embed"
	"encoding/json"
	"fmt"
	"log"
	"net/url"
	"path"
	"strings"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

	jsonpatch "github.com/evanphx/json-patch/v5"
	"github.com/mitchellh/mapstructure"
	"github.com/open-policy-agent/opa/rego"
	"gopkg.in/yaml.v2"

	"github.com/replicatedhq/kurlkinds/pkg/apis/cluster/v1beta1"
)

var (
	//go:embed rego
	static          embed.FS
	ErrNotInstaller = fmt.Errorf("object is not an installer")
)

type Severity string

const (
	SeverityError   Severity = "error"
	SeverityWarning Severity = "warning"
	SeverityInfo    Severity = "info"
)

// Output holds the outcome of a lint pass on top of a Installer struct.
type Output struct {
	Field    string          `json:"field,omitempty"`
	Type     string          `json:"type,omitempty"`
	Message  string          `json:"message,omitempty"`
	Severity Severity        `json:"severity,omitempty"`
	Patch    jsonpatch.Patch `json:"patch,omitempty"`
}

// UnmarshalYAML is a helper function that unmarshals a yaml blob into an Output struct.
// As the Output struct contains a jsonpatch.Patch field and that field contains a property
// of type json.RawMessage, the default yaml unmarshaller is not able to do the job.
func (o *Output) UnmarshalYAML(unmarshal func(interface{}) error) error {
	var raw map[string]interface{}
	if err := unmarshal(&raw); err != nil {
		return err
	}
	data, err := json.Marshal(raw)
	if err != nil {
		return err
	}
	return json.Unmarshal(data, o)
}

// AddOn holds an add-on and its respective supported versions.
type AddOn struct {
	Latest   string   `json:"latest"`
	Versions []string `json:"versions"`
}

type Linter struct {
	apiBaseURL       *url.URL
	verbose          bool
	showInfoSeverity bool
}

// New returns a new v1beta1.Installer linter. this linter is capable of evaluating if a
// struct has all its fields properly set, rules in the "rego/" directory are used.
func New(opts ...Option) *Linter {
	linter := &Linter{}
	for _, opt := range opts {
		opt(linter)
	}
	return linter
}

// Versions return a map containing all supported versions indexed by add-on name. it
// goes and fetch the versions from a remote endpoint.
func (l *Linter) Versions(ctx context.Context, inst v1beta1.Installer) (map[string]AddOn, error) {
	content, err := l.prepareVariablesRegoFile(ctx)
	if err != nil {
		return nil, fmt.Errorf("error preparing for api requests: %w", err)
	}

	rules := rego.New(
		rego.Query("data.kurl.installer.known_versions"),
		rego.Module("rego/variables.rego", string(content)),
		rego.Input(inst),
	)

	rs, err := rules.Eval(ctx)
	if err != nil {
		return nil, fmt.Errorf("unexpected error getting add-on versions: %w", err)
	}

	if len(rs) == 0 || len(rs[0].Expressions) == 0 {
		return nil, fmt.Errorf("unexpected empty rego eval return")
	}

	result := map[string]AddOn{}
	if err := mapstructure.Decode(rs[0].Expressions[0].Value, &result); err != nil {
		return nil, fmt.Errorf("error decoding result: %w", err)
	}

	if len(result) == 0 {
		return nil, fmt.Errorf("unable to get versions from %s", l.apiBaseURL.String())
	}

	return result, nil
}

// debug is a helper functions that prior to logging something checks if verbose has been
// enabled in the linter.
func (l Linter) debug(format string, v ...any) {
	if l.verbose {
		format = fmt.Sprintf("installer.linter: %s", format)
		log.Printf(format, v...)
	}
}

// ValidateMarshaledYAML verifies if the provided data blob is an installer and applies the
// lint rules. If you have an already unmarshaled Installer instruct use Validate() instead.
func (l *Linter) ValidateMarshaledYAML(ctx context.Context, data string) ([]Output, error) {
	var meta metav1.TypeMeta
	if err := yaml.Unmarshal([]byte(data), &meta); err != nil {
		return nil, fmt.Errorf("unable to unmarshal installer: %w", err)
	}

	if !strings.EqualFold(meta.Kind, "Installer") {
		l.debug("object kind is %s, not an installer", meta.Kind)
		return nil, ErrNotInstaller
	}

	type blob struct {
		Content string `json:"content"`
	}
	return l.validate(ctx, blob{data})
}

// Validate applies the lint rules on top of the provided Installer object.
func (l *Linter) Validate(ctx context.Context, inst v1beta1.Installer) ([]Output, error) {
	return l.validate(ctx, inst)
}

// Validate checks the provided blob for errors. This function receives an interface{} as it
// is used in different contexts, keeping this "private" is by design.
func (l *Linter) validate(ctx context.Context, blob interface{}) ([]Output, error) {
	content, err := l.prepareVariablesRegoFile(ctx)
	if err != nil {
		return nil, fmt.Errorf("error preparing for api requests: %w", err)
	}

	options := []func(*rego.Rego){
		rego.Query("data.kurl.installer.lint"),
		rego.Module("rego/variables.rego", string(content)),
		rego.Input(blob),
	}

	regofiles := []string{"functions.rego", "output.rego"}
	if l.verbose {
		regofiles = append(regofiles, "debug.rego")
	}

	l.debug("using rego files: %+v", regofiles)
	for _, fname := range regofiles {
		fpath := path.Join("rego", fname)
		content, err := static.ReadFile(fpath)
		if err != nil {
			return nil, fmt.Errorf("unable to load rego rules: %w", err)
		}
		options = append(options, rego.Module(fname, string(content)))
	}

	rs, err := rego.New(options...).Eval(ctx)
	if err != nil {
		return nil, fmt.Errorf("unexpected error evaluating installer: %w", err)
	}

	if len(rs) == 0 || len(rs[0].Expressions) == 0 {
		if len(rs) == 0 {
			l.debug("rego result set is empty")
		} else {
			l.debug("rego result set expressions are empty")
		}
		return []Output{}, nil
	}

	data, err := json.Marshal(rs[0].Expressions[0].Value)
	if err != nil {
		return nil, fmt.Errorf("error marshaling rego eval return: %w", err)
	}

	result := []Output{}
	if err := json.Unmarshal(data, &result); err != nil {
		return nil, fmt.Errorf("error unmarshaling rego eval return: %w", err)
	}

	var filtered = []Output{}
	var ppfailure error
	l.debug("total of results returned by rego: %d", len(result))
	for _, res := range result {
		l.debug("%s: %s", res.Type, res.Message)
		if res.Type == "debug" {
			continue
		}

		if res.Type == "preprocess" {
			ppfailure = fmt.Errorf(res.Message)
			continue
		}

		filtered = append(filtered, res)
	}
	l.debug("results returned after filtering: %d", len(filtered))

	if ppfailure != nil {
		return nil, ppfailure
	}
	return filtered, nil
}

// prepareVariablesRegoFile reads and parses the `rego/variables.rego` file. two things can
// be changed in the original file: 1) the api base url can be replaced by one provided by
// the user and 2) the info severity can be enabled.
func (l *Linter) prepareVariablesRegoFile(ctx context.Context) ([]byte, error) {
	content, err := static.ReadFile("rego/variables.rego")
	if err != nil {
		return nil, fmt.Errorf("error reading rego variables file: %w", err)
	}
	if l.apiBaseURL != nil {
		// if the version url has been set by the user we replace it here.
		oldurl := []byte("https://kurl.sh")
		newurl := []byte(l.apiBaseURL.String())
		content = bytes.ReplaceAll(content, oldurl, newurl)
		l.debug("api base url been replaced by %q", l.apiBaseURL.String())
	}
	if l.showInfoSeverity {
		// if info severity is enabled we update the variable here.
		oldvar := []byte("info_severity_enabled = false")
		newvar := []byte("info_severity_enabled = true")
		content = bytes.ReplaceAll(content, oldvar, newvar)
		l.debug("info severity enable state changed")
	}
	return content, nil
}
