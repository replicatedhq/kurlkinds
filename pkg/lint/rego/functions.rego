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
	sorted := sort_versions(known_versions[add_on].fixed_versions)
	newest := sorted[count(sorted)-1]
} else = newest {
	newest := "latest"
}

# preceding_version returns the version preceding the provided version.
preceding_version(add_on, version) = preceding {
	known_versions[add_on]
	sorted := sort_versions(known_versions[add_on].fixed_versions)
	pos := count_versions_less_than(version, sorted)
	pos > 0
	preceding := sorted[pos - 1]
} else = preceding {
	known_versions[add_on]
	sorted := sort_versions(known_versions[add_on].fixed_versions)
	preceding := sorted[0]
} else = preceding {
	preceding := "latest"
}
