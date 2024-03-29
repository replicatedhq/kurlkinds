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
	"net/url"
)

// Option is a function that sets an option in Linter object.
type Option func(*Linter)

// WithAPIBaseURL sets a different api base url from where the linter attempts to load known
// versions for all addons. The default is "https://kurl.sh".
func WithAPIBaseURL(u *url.URL) Option {
	return func(l *Linter) {
		l.apiBaseURL = u
	}
}

// WithDebug enables debug logging for the linter. debug logs are written to stdout.
func WithDebug() Option {
	return func(l *Linter) {
		l.verbose = true
	}
}

// WithInfoSeverity enables info severity in the linter. By default this is disabled.
func WithInfoSeverity() Option {
	return func(l *Linter) {
		l.showInfoSeverity = true
	}
}
