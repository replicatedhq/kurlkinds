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

# valid_ipv6_cidr evaluates to true if cidr is a valid ipv6 network cidr (address + netmask).
valid_ipv6_cidr(cidr) {
	# this regex evaluates for valid ipv6 network cidrs. here be dragons. 
	regex.match(`^s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:)))(%.+)?s*(\/(12[0-8]|1[0-1][0-9]|[1-9][0-9]|[0-9]))$`, cidr)
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
	valid_ipv4_cidr(installer.spec.kubernetes.serviceCIDR)
}
valid_kubernetes_service_cidr_override {
	valid_ipv6_cidr(installer.spec.kubernetes.serviceCIDR)
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
	valid_ipv4_cidr(installer.spec.antrea.podCIDR)
}
valid_antrea_pod_cidr_override() {
	valid_ipv6_cidr(installer.spec.antrea.podCIDR)
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
