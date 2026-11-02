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

# kube_distributions holds an array of all selected kubernetes "distributions" (kubernetes).
# this is useful if we want to check how many got selected and return an error if more than one
# has been selected.
kube_distributions[distro] {
	installer.spec.kubernetes.version != ""
	distro := "kubernetes"
}

# container_runtime gather the selected container runtimes in an array. we use this to evaluate
# how many of them got selected.
container_runtimes[runtime] {
	installer.spec.docker.version != ""
	runtime := "docker"
}
container_runtimes[runtime] {
	installer.spec.containerd.version != ""
	runtime := "containerd"
}

# cni_providers gather the selected cni providers in an array. we use this to evaluate
# how many of them got selected.
cni_providers[runtime] {
	installer.spec.flannel.version != ""
	runtime := "flannel"
}
cni_providers[runtime] {
	installer.spec.weave.version != ""
	runtime := "weave"
}
cni_providers[runtime] {
	installer.spec.antrea.version != ""
	runtime := "antrea"
}

# evaluates to true if the given addon has its version is lower (older) than or equal to the
# provided semantic version.
is_addon_version_lower_than_or_equal(addon, version) {
	no_latest := replace(installer.spec[addon].version, "latest", known_versions[addon].latest)
	no_version_x := replace(no_latest, ".x", ".999")
	semver.compare(no_version_x, version) <= 0
}

# evaluates to true if the given addon has its version is lower (older) than the provided
# semantic version.
is_addon_version_lower_than(addon, version) {
	no_latest := replace(installer.spec[addon].version, "latest", known_versions[addon].latest)
	no_version_x := replace(no_latest, ".x", ".999")
	semver.compare(no_version_x, version) < 0
}

# evaluates to true if the given addon has its version is greater than or equal to the provided
# semantic version.
is_addon_version_greater_than_or_equal(addon, version) {
	no_latest := replace(installer.spec[addon].version, "latest", known_versions[addon].latest)
	no_version_x := replace(no_latest, ".x", ".999")
	semver.compare(no_version_x, version) >= 0
}

# evaluates to true if the given addon has its version is greater than to the provided semantic
# version.
is_addon_version_greater_than(addon, version) {
	no_latest := replace(installer.spec[addon].version, "latest", known_versions[addon].latest)
	no_version_x := replace(no_latest, ".x", ".999")
	semver.compare(no_version_x, version) > 0
}

# returns the minor version ("1.22") of the given add-on, with "latest" resolved.
addon_minor_version(addon) = minor {
	no_latest := replace(installer.spec[addon].version, "latest", known_versions[addon].latest)
	minor := minor_version(no_latest)
}

# returns the minor version ("1.22") of the given semantic version.
minor_version(version) = minor {
	parts := split(version, ".")
	minor := sprintf("%v.%v", [parts[0], parts[1]])
}

# evaluates to true if the kubernetes version is within the given minor versions (inclusive).
kubernetes_within(min, max) {
	not is_addon_version_lower_than("kubernetes", sprintf("%v.0", [min]))
	not is_addon_version_greater_than("kubernetes", sprintf("%v.999", [max]))
}

# returns the strictest entry of rook_kubernetes_minimums that applies to the selected rook
# version. the table is sorted by rook version so the last match is the strictest.
rook_kubernetes_minimum = minimum {
	some i
	minimum := rook_kubernetes_minimums[i]
	rule_applies(minimum.pinned)
	is_addon_version_greater_than_or_equal("rook", minimum.rook)
	not rook_kubernetes_minimum_after(i)
}

rook_kubernetes_minimum_after(i) {
	some j
	later := rook_kubernetes_minimums[j]
	j > i
	rule_applies(later.pinned)
	is_addon_version_greater_than_or_equal("rook", later.rook)
}

# evaluates to true if the selected kubernetes is older than kurl requires for the selected rook.
rook_below_kubernetes_minimum {
	is_addon_version_lower_than("kubernetes", sprintf("%v.0", [rook_kubernetes_minimum.kubernetes]))
}

# evaluates to true if kurl allows the given rook version with the selected kubernetes and rook
# tests that pair upstream.
rook_version_fits_kubernetes(version) {
	range := rook_tested_kubernetes_versions[minor_version(version)]
	kubernetes_within(range.min, range.max)
	not rook_version_below_kubernetes_minimum(version)
}

rook_version_below_kubernetes_minimum(version) {
	minimum := rook_kubernetes_minimums[_]
	rule_applies(minimum.pinned)
	semver.compare(version, minimum.rook) >= 0
	is_addon_version_lower_than("kubernetes", sprintf("%v.0", [minimum.kubernetes]))
}

# returns the newest known rook version that fits the selected kubernetes, see
# rook_version_fits_kubernetes. falls back to the newest rook version.
newest_rook_for_kubernetes = newest {
	candidates := [v | v := known_versions.rook.versions[_]; semver.is_valid(v); rook_version_fits_kubernetes(v)]
	count(candidates) > 0
	sorted := sort_versions(candidates)
	newest := sorted[count(sorted)-1]
} else = newest {
	newest := newest_add_on_version("rook")
}

# returns the newest known kubernetes version kurl allows with the selected rook version and that
# rook tests upstream. falls back to the newest kubernetes version.
newest_kubernetes_for_rook = newest {
	range := rook_tested_kubernetes_versions[addon_minor_version("rook")]
	floor := rook_kubernetes_floor(range.min)
	candidates := [v |
		v := known_versions.kubernetes.versions[_]
		semver.is_valid(v)
		semver.compare(v, sprintf("%v.0", [floor])) >= 0
		semver.compare(v, sprintf("%v.999", [range.max])) <= 0
	]
	count(candidates) > 0
	sorted := sort_versions(candidates)
	newest := sorted[count(sorted)-1]
} else = newest {
	newest := newest_add_on_version("kubernetes")
}

# returns the greater of the given minor version and the kubernetes minimum kurl requires for the
# selected rook.
rook_kubernetes_floor(min) = floor {
	required := rook_kubernetes_minimum.kubernetes
	semver.compare(sprintf("%v.0", [required]), sprintf("%v.0", [min])) > 0
	floor := required
} else = floor {
	floor := min
}

# rule_applies evaluates to true if a rule with the given pinned policy applies to the spec. this
# matches kURL-api's PinnedPolicy for specs that pin kurl.installerVersion:
#   "always":       every pinned release.
#   a kurl release: pinned releases from that one on, the first release whose scripts reject the
#                   spec (e.g. "v2026.06.22-0").
#   "":             unpinned specs only.
# unpinned specs get every rule. a pinned release that does not parse only gets "always" rules.
rule_applies(policy) {
	not pins_installer_version
}
rule_applies(policy) {
	policy == "always"
}
rule_applies(policy) {
	policy != "always"
	policy != ""
	kurl_release_number(installer.spec.kurl.installerVersion) >= kurl_release_number(policy)
}

pins_installer_version {
	installer.spec.kurl.installerVersion != ""
}

# the lowest containerd version rejected with weave, see the weave rule.
weave_containerd_floor = "1.6.0" {
	rule_applies("v2022.09.08-0")
} else = "1.6.4"

# kurl_release_number turns a kurl release name such as "v2026.06.22-0", which is not valid
# semver, into a number that sorts like the release.
kurl_release_number(release) = number {
	match := regex.find_all_string_submatch_n(`^v?(\d{4})\.(\d{2})\.(\d{2})-(\d+)$`, release, 1)
	count(match) == 1
	parts := match[0]
	number := ((to_number(parts[1]) * 10000 + to_number(parts[2]) * 100 + to_number(parts[3])) * 10000) + to_number(parts[4])
}

# is_spec_property_valid checks if the provided property is valid inside the installer spec.
is_spec_property_valid(prop) {
	valid_spec_properties[_] == prop
}

# addon_version_exists checks if provided addon supports the provided version. if version
# is "latest" then this evaluates to true, if it is an static version it checks if the version
# exists and if it is a "x" version it makes sure at least one version exists in the x range.
# if an override (s3Override) has been provided to the add-on this will evaluates to true.
addon_version_exists(addon, version) {
	version == "latest"
}
addon_version_exists(addon, version) {
	installer.spec[addon].s3Override
}
addon_version_exists(addon, version) {
	known_versions[addon].versions[_] == version
}
addon_version_exists(addon, version) {
	endswith(version, "x")
	x_version_removed := replace(version, "x", "")
	x_version_removed != ""
	startswith(known_versions[addon].versions[_], x_version_removed)
}

# valid_ipv4_cidr evaluates to true if cidr is a valid ipv4 network cidr (address + netmask).
valid_ipv4_cidr(cidr) {
	# this regex evaluates for valid ipv4 network cidrs. here be dragons. 
	regex.match(`^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/(3[0-2]|[1-2][0-9]|[0-9]))$`, cidr)
}

# valid_cidr_range verifies if the provided cidr range is valid. the range may be provided in
# 2 distinct ways, for example: '/16' or only '16'.
valid_cidr_range(range) {
	regex.match(`^\/\d+$`, range)
}
valid_cidr_range(range) {
	regex.match(`^\d+$`, range)
}

# valid_kubernetes_service_cidr_range_override checks if the service cidr range override has
# been passed on by the user and if it is valid.
valid_kubernetes_service_cidr_range_override {
	not installer.spec.kubernetes.serviceCidrRange
}
valid_kubernetes_service_cidr_range_override {
	valid_cidr_range(installer.spec.kubernetes.serviceCidrRange)
}

# valid_kubernetes_service_cidr_override checks if the service cidr range override has been
# passed on by the user and if it is valid. kubernetes service cidr can be either ipv4 or
# ipv6. if the property is not set valid_kubernetes_service_cidr_range_override evaluates to
# true as well.
valid_kubernetes_service_cidr_override {
	not installer.spec.kubernetes.serviceCIDR
}
valid_kubernetes_service_cidr_override {
	net.cidr_is_valid(installer.spec.kubernetes.serviceCIDR)
}

# valid_pod_cidr_range_override checks if the provided podCidrRange property is valid.
valid_pod_cidr_range_override(podCidrRange) {
	not podCidrRange
}
valid_pod_cidr_range_override(podCidrRange) {
	valid_cidr_range(podCidrRange)
}

# valid_pod_cidr checks id the provided podCIDR property is valid. antrea pod cidr can be
# either ipv4 or ipv6.
valid_antrea_pod_cidr_override() {
	not installer.spec.antrea.podCIDR
}
valid_antrea_pod_cidr_override() {
	net.cidr_is_valid(installer.spec.antrea.podCIDR)
}

# valid_add_on_version checks if the version for the addon exists (is valid). if the addon
# has not been selected (there is no version specified for it) then this evaluates to true.
valid_add_on_version(addon) {
	installer.spec[addon].version == ""
}
valid_add_on_version(addon) {
	addon_version_exists(addon, installer.spec[addon].version)
}

# port_out_of_range evaluates to true if provided port is out of provided range. 
port_out_of_range(port, floor, ceil) {
	port < floor
}
port_out_of_range(port, floor, ceil) {
	port > ceil
}

# count_versions_less_than returns a counter indicating how many versions in the versions array are
# less than the requested version (uses sematic versioning to compare).
count_versions_less_than(version, versions) = vcount {
	semver.is_valid(version)
	vcount := count({v | v := versions[_]; semver.compare(version, v) == 1})
} else = vcount {
	vcount := count({v | v := versions[_]; version > v})
}

# sort_versions sorts the provided versions array using sematic versioning, if all elements in the
# are are not valid sematic versions then the array is returned sorted as strings. return is sorted
# in ascending order.
sort_versions(versions) = sorted {
	some i
	sorted := { count_versions_less_than(versions[i], versions): x | x := versions[i] }
}

# newest_add_on_version returns the newest version of the add-on.
newest_add_on_version(add_on) = newest {
	known_versions[add_on]
	sorted := sort_versions(known_versions[add_on].versions)
	newest := sorted[count(sorted)-1]
} else = newest {
	newest := "latest"
}

# preceding_version returns the version preceding the provided version.
preceding_version(add_on, version) = preceding {
	known_versions[add_on]
	sorted := sort_versions(known_versions[add_on].versions)
	pos := count_versions_less_than(version, sorted)
	pos > 0
	preceding := sorted[pos - 1]
} else = preceding {
	known_versions[add_on]
	sorted := sort_versions(known_versions[add_on].versions)
	preceding := sorted[0]
} else = preceding {
	preceding := "latest"
}
