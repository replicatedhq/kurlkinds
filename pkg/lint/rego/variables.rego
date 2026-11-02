# Copyright 2022 Replicated Inc.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# 	http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
package kurl.installer

# installer holds or the installer struct or the yaml unmarshaled value of input.content.
# allows for callers to pass as input an installer struct or a serialized installer struct.
installer = content {
	input.content
	content := yaml.unmarshal(input.content)
} else = content {
	content := input
}

# api_base_url allows for overriding the place where the kurl api is hosted.
api_base_url = "https://kurl.sh"

# info_severity_enabled indicates if the linter should return messages with `info` severity.
# about severities: they are defined in the go code, so far we have 'error', 'warning', and 'info',
# info is the only one that can be disabled (in fact, disabled is its default value).
info_severity_enabled = false

# debug_enabled indicates if the linter should return debug messages.
debug_enabled = false

# valid_spec_properties holds a list of all valid installer spec properties. this is empty by
# default, and is populated by the `prepareVariablesRegoFile()` go function.
valid_spec_properties = []

# this rule determines what endpoint we need to reach when fetching add-on versions remotely
# if there is a pre-determined version in installer.spec.kurl.installerVersion we go for add-ons
# specific to the informed version.
add_ons_versions_endpoint = url {
        installer.spec.kurl.installerVersion != ""
        url := sprintf("%v/installer/version/%v", [api_base_url, installer.spec.kurl.installerVersion])
} else = url {
        url := sprintf("%v/installer", [api_base_url])
}

# rook_tested_kubernetes_versions holds the kubernetes versions each rook minor is tested with
# upstream (rook prerequisites docs), indexed by rook minor. rook versions before 1.12 do not
# document an upper bound. kurl requires a newer kubernetes than upstream for some of these, see
# rook_kubernetes_minimums.
rook_tested_kubernetes_versions = {
	"1.12": {"min": "1.22", "max": "1.28"},
	"1.13": {"min": "1.23", "max": "1.29"},
	"1.14": {"min": "1.25", "max": "1.30"},
	"1.15": {"min": "1.26", "max": "1.31"},
	"1.16": {"min": "1.27", "max": "1.32"},
	"1.17": {"min": "1.28", "max": "1.33"},
	"1.18": {"min": "1.29", "max": "1.34"},
	"1.19": {"min": "1.30", "max": "1.35"},
}

# rook_kubernetes_minimums holds the minimum kubernetes version kurl requires for each rook
# version, sorted by rook version. rook 1.18 and later are gated to kubernetes 1.31 by kurl's rook
# add-on. keep in sync with kURL-api addonKubernetesRules.
rook_kubernetes_minimums = [
	{"rook": "1.9.12", "kubernetes": "1.17"},
	{"rook": "1.10.0", "kubernetes": "1.19"},
	{"rook": "1.12.0", "kubernetes": "1.22"},
	{"rook": "1.13.0", "kubernetes": "1.23"},
	{"rook": "1.18.0", "kubernetes": "1.31"},
]

# remote_versions fetches the list of add-on versions from kurl.sh/installer endpoint.
remote_versions = response {
	http.send(
		{
			"url": add_ons_versions_endpoint,
			"method": "get",
			"raise_error": false,
			"headers": {
				"Accept": "application/json"
			}
		},
		response
	)
}

# iterates over the provided array looking for the "latest" string, once it is found then
# the next element in the array is returned ("latest" precedes "actual latest version").
find_latest_version(allversions) = version {
	some i
	v := allversions[i]
	v == "latest"
	version := allversions[i+1]
}

# known_versions gather all add on known versions according to a remote http request. the
# result here is an object where add-on versions are indexed by the add-on name, something
# similar to:
# {
# 	"addon_name": {
#		"latest": "the latest version (eg. 1.19.0)"
#		"versions": [
#			"1.22.0",
#			"1.21.0",
#			"1.20.0",
#			"1.19.0",
#			...
#		]
#	},
#	...
# }
default known_versions = { addon_name: { "versions": versions, "latest": latest } |
	some addon_name
	allversions := remote_versions.body[addon_name]
	versions := { version | version := allversions[_]; version != "latest" }
	latest = latest_version(addon_name, allversions, versions)
}

# latest_version returns the version "latest" resolves to. the kubernetes versions list is not
# ordered newest first, so like kURL-api "latest" kubernetes is the greatest version. for other
# add-ons it is the version listed after "latest".
latest_version(addon_name, allversions, versions) = version {
	addon_name == "kubernetes"
	version := versions[_]
	semver.is_valid(version)
	not greater_version_exists(version, versions)
} else = version {
	version := find_latest_version(allversions)
}

greater_version_exists(version, versions) {
	other := versions[_]
	semver.is_valid(other)
	semver.compare(other, version) > 0
}
