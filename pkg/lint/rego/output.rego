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

# reports an error if user has selected the kubernetes distribution but has not
# selected a container runtime. a container runtime is necessary to run the kube
# distribution.
lint[output] {
	installer.spec.kubernetes.version != ""
	count(container_runtimes) == 0
	output :=  {
		"type": "misconfiguration",
		"severity": "error",
		"message": "No container runtime (Docker or Containerd) selected",
		"patch": [
			{ "op": "add", "path": "/spec/containerd/version", "value": newest_add_on_version("containerd") }
		]
	}
}

# reports an error if user has selected multiple container runtimes at the same
# time. only one can be selected (or docker or containerd).
lint[output] {
	count(container_runtimes) > 1
	output := {
		"type": "misconfiguration",
		"severity": "error",
		"message": "Multiple container runtimes selected",
		"patch": [
			{ "op": "remove", "path": "/spec/docker" }
		]
	}
}

# generates an error if kubernetes is the selected distribution but no cni plugin has
# been selected by the user.
lint[output] {
	installer.spec.kubernetes.version != ""
	count(cni_providers) == 0
	output :=  {
		"type": "misconfiguration",
		"severity": "error",
		"message": "No CNI plugin (Flannel, Weave or Antrea) selected",
		"patch": [
			{ "op": "add", "path": "/spec/flannel/version", "value": newest_add_on_version("flannel") }
		]
	}
}

# returns an error if the config has any two of flannel, weave or antrea selected at the same time.
lint[output] {
	count(cni_providers) > 1
	output := {
		"type": "misconfiguration",
		"severity": "error",
		"message": "Multiple CNI plugins selected (choose one of Flannel, Weave or Antrea)",
		"patch": [
			{ "op": "remove", "path": "/spec/weave" },
			{ "op": "remove", "path": "/spec/antrea" },
			{ "op": "add", "path": "/spec/flannel/version", "value": newest_add_on_version("flannel") }
		]
	}
}

# checks if there is at least one selected kubernetes distro (kubernetes).
lint[output] {
	count(kube_distributions) == 0
	output := {
		"type": "misconfiguration",
		"severity": "error",
		"message": "No kubernetes distribution selected",
		"patch": [
			{ "op": "remove", "path": "/spec/docker" },
			{ "op": "remove", "path": "/spec/antrea" },
			{ "op": "remove", "path": "/spec/weave" },
			{ "op": "add", "path": "/spec/kubernetes/version", "value": newest_add_on_version("kubernetes") },
			{ "op": "add", "path": "/spec/flannel/version", "value": newest_add_on_version("flannel") },
			{ "op": "add", "path": "/spec/containerd/version", "value": newest_add_on_version("containerd") }
		]
	}
}

# verifies if the selected kubernetes version is compatible with the selected container
# runtime. the only thing verified here is that we are not trying to run kubernetes 1.24+
# with the "docker" container runtime as they are incompatible.
lint[output] {
	is_addon_version_greater_than_or_equal("kubernetes", "1.24.0")
	installer.spec.docker.version
	output := {
		"type": "incompatibility",
		"severity": "error",
		"message": "Kubernetes 1.24+ does not support Docker runtime, Containerd is recommended",
		"patch": [
			{ "op": "remove", "path": "/spec/docker" },
			{ "op": "add", "path": "/spec/containerd/version", "value": newest_add_on_version("containerd") }
		]
	}
}

# verifies if the kubernetes service cidr override provided by the user is valid.
lint[output] {
	not valid_kubernetes_service_cidr_override
	output := {
		"type": "misconfiguration",
		"severity": "error",
		"message": "Invalid Kubernetes services CIDR"
	}
}

# verifies if the kubernetes service cidr range override provided by the user is valid.
lint[output] {
	not valid_kubernetes_service_cidr_range_override
	output := {
		"type": "misconfiguration",
		"severity": "error",
		"message": "Invalid Kubernetes services CIDR range"
	}
}

# verifies if the weave pod cidr range override provided by the user is valid.
lint[output] {
	not valid_pod_cidr_range_override(installer.spec.weave.podCidrRange)
	output := {
		"type": "misconfiguration",
		"severity": "error",
		"message": "Invalid Weave pod CIDR range"
	}
}

# verifies if the weave pod cidr override provided by the user is valid.
lint[output] {
	installer.spec.weave.podCIDR
	not valid_ipv4_cidr(installer.spec.weave.podCIDR)
	output := {
		"type": "misconfiguration",
		"severity": "error",
		"message": "Invalid Weave pod CIDR"
	}
}

# verifies if the flannel pod cidr range override provided by the user is valid.
lint[output] {
	not valid_pod_cidr_range_override(installer.spec.flannel.podCIDRRange)
	output := {
		"type": "misconfiguration",
		"severity": "error",
		"message": "Invalid Flannel pod CIDR range"
	}
}

# verifies if the flannel pod cidr override provided by the user is valid.
lint[output] {
	installer.spec.flannel.podCIDR
	not valid_ipv4_cidr(installer.spec.flannel.podCIDR)
	output := {
		"type": "misconfiguration",
		"severity": "error",
		"message": "Invalid Flannel pod CIDR"
	}
}

# verifies if the antrea pod cidr range override provided by the user is valid.
lint[output] {
	not valid_pod_cidr_range_override(installer.spec.antrea.podCidrRange)
	output := {
		"type": "misconfiguration",
		"severity": "error",
		"message": "Invalid Antrea pod CIDR range"
	}
}

# verifies if the antrea pod cidr override provided by the user is valid.
lint[output] {
	not valid_antrea_pod_cidr_override
	output := {
		"type": "misconfiguration",
		"severity": "error",
		"message": "Invalid Antrea pod CIDR"
	}
}

# reports an error if calico is <= 3.9.1 and kubernetes >= 1.22 as this pair is incompatible.
lint[output] {
	is_addon_version_greater_than_or_equal("kubernetes", "1.22.0")
	is_addon_version_lower_than("calico", "3.9.2")
	output := {
		"type": "incompatibility",
		"severity": "error",
		"message": "Calico versions <= 3.9.1 are not compatible with Kubernetes 1.22+",
		"patch": [
			{ "op": "replace", "path": "/spec/kubernetes/version", "value":  preceding_version("kubernetes", "1.22.0") }
		]
	}
}

# returns an error if selected kubernetes is >= 1.20 and rook is less than 1.1.0.
lint[output] {
	is_addon_version_greater_than_or_equal("kubernetes", "1.20.0")
	is_addon_version_lower_than("rook", "1.1.0")
	output := {
		"type": "incompatibility",
		"severity": "error",
		"message": "Rook versions <= 1.1.0 are not compatible with Kubernetes versions 1.20+",
		"patch": [
			{ "op": "replace", "path": "/spec/rook/version", "value": newest_add_on_version("rook") }
		]
	}
}

# returns an error if selected kubernetes is >= 1.22 and rook is less than 1.4.9.
lint[output] {
	is_addon_version_greater_than_or_equal("kubernetes", "1.22.0")
	is_addon_version_lower_than("rook", "1.5.0")
	output := {
		"type": "incompatibility",
		"severity": "error",
		"message": "Rook versions <= 1.4.9 are not compatible with Kubernetes versions 1.22+",
		"patch": [
			{ "op": "replace", "path": "/spec/rook/version", "value": newest_add_on_version("rook") }
		]
	}
}

# returns an error if longhorn <= 1.4.0 is selected with kubernetes >= 1.25.0, this
# pair is incompatible.
lint[output] {
	is_addon_version_greater_than_or_equal("kubernetes", "1.25.0")
	is_addon_version_lower_than("longhorn", "1.4.0")
	output := {
		"type": "incompatibility",
		"severity": "error",
		"message": "Longhorn versions <= 1.4.0 are not compatible with Kubernetes versions 1.25+",
		"patch": [
			{ "op": "replace", "path": "/spec/kubernetes/version", "value": preceding_version("kubernetes", "1.25.0") }
		]
	}
}

# this returns an error if an invalid or unknown version for an add-on has been selected.
lint[output] {
	some name 
	ignored := known_versions[name]
	not valid_add_on_version(name)
	output := {
		"type": "unknown-addon",
		"severity": "error",
		"message": sprintf("Unknown %v add-on version %v", [name, installer.spec[name].version]),
		"patch": [
			{ "op": "replace", "path": sprintf("/spec/%v/version", [name]), "value": newest_add_on_version(name) }
		]
	}
}

# reports an info linting message if there is a newer version of an add-on available.
lint[output] {
	info_severity_enabled
	some name
	ignored := known_versions[name]
	valid_add_on_version(name)
	newest_version := newest_add_on_version(name)
	is_addon_version_lower_than(name, newest_version)
	output := {
		"type": "upgrade-available",
		"severity": "info",
		"message": sprintf("Add-on %v has a more recent version: %v", [name, newest_version]),
		"patch": [
			{ "op": "replace", "path": sprintf("/spec/%v/version", [name]), "value": newest_version }
		]
	}
}

# returns an error if weave has been selected with containerd in versions between 1.6.0 and
# 1.6.4 as this pair is incompatible.
lint[output] {
	installer.spec.weave.version
	is_addon_version_greater_than_or_equal("containerd", "1.6.0")
	is_addon_version_lower_than_or_equal("containerd", "1.6.4")
	output := {
		"type": "incompatibility",
		"severity": "error",
		"message": "Containerd versions 1.6.0 - 1.6.4 are not compatible with Weave",
		"patch": [
			{ "op": "replace", "path": "/spec/containerd/version", "value": newest_add_on_version("containerd") }
		]
	}
}

# reports incompatiblity error for the openebs <= 2.12.9 and kubernetes >= 1.22.0 duo.
lint[output] {
	is_addon_version_greater_than_or_equal("kubernetes", "1.22.0")
	is_addon_version_lower_than_or_equal("openebs", "2.12.9")
	output := {
		"type": "incompatibility",
		"severity": "error",
		"message": "OpenEBS versions <= 2.12.9 are not compatible with Kubernetes 1.22+",
		"patch": [
			{ "op": "replace", "path": "/spec/openebs/version", "value": newest_add_on_version("openebs") }
		]
	}
}

# if due to a network error we could not load the list of known versions we report an error
# as well.
lint[output] {
	remote_versions.error.message
	output :=  {
		"type": "preprocess",
		"severity": "error",
		"message": remote_versions.error.message
	}
}

# make sure we have been able to read add-on versions from the remote host. if the list of
# add on versions is zeroed then we get the raw body of the request and return it as an error.
# the body is trucated at 50 chars to avoid returning what can be a huge html file.
lint[output] {
	not remote_versions.error.message
	count(known_versions) == 0
	body := substring(remote_versions.raw_body, 0, 50)
	message := sprintf("error reading add-ons, server returned %v: %v", [remote_versions.status, body])
	output :=  {
		"type": "preprocess",
		"severity": "error",
		"message": message,
	}
}

# reports an error if openebs >= 2.12.9 and cstor is enabled. this configuration is not
# supported by kurl.
lint[output] {
	installer.spec.openebs.isCstorEnabled
	is_addon_version_greater_than_or_equal("openebs", "2.12.9")
	output := {
		"type": "incompatibility",
		"severity": "error",
		"message": "OpenEBS add-on versions >= 2.12.9 do not support cStor",
		"patch": [
			{ "op": "remove", "path": "/spec/openebs/isCstorEnabled" }
		]
	}
}

# reports an error if rook is <= 1.9.10 and kubernetes >= 1.25 as this pair is incompatible.
lint[output] {
	is_addon_version_greater_than_or_equal("kubernetes", "1.25.0")
	is_addon_version_lower_than_or_equal("rook", "1.9.10")
	output := {
		"type": "incompatibility",
		"severity": "error",
		"message": "Rook versions <= 1.9.10 are not compatible with Kubernetes 1.25+",
		"patch": [
			{ "op": "replace", "path": "/spec/rook/version", "value": newest_add_on_version("rook") }
		]
	}
}

# prometheus versions <= 0.49.0-17.1.3 are incompatible with Kubernetes 1.22+.
lint[output] {
	is_addon_version_greater_than_or_equal("kubernetes", "1.22.0")
	is_addon_version_lower_than_or_equal("prometheus", "0.49.0")
	output := {
		"type": "incompatibility",
		"severity": "error",
		"message": "Prometheus versions <= 0.49.0-17.1.3 are not compatible with Kubernetes 1.22+",
		"patch": [
			{ "op": "replace", "path": "/spec/prometheus/version", "value": newest_add_on_version("prometheus") }
		]
	}
}

# prometheus versions less than or equal to 0.59.0 are not compatible with kubernetes 1.25+.
lint[output] {
	is_addon_version_greater_than_or_equal("kubernetes", "1.25.0")
	is_addon_version_lower_than_or_equal("prometheus", "0.59.0")
	output := {
		"type": "incompatibility",
		"severity": "error",
		"message": "Prometheus versions <= 0.59.0 are not compatible with Kubernetes 1.25+",
		"patch": [
			{ "op": "replace", "path": "/spec/prometheus/version", "value": newest_add_on_version("prometheus") }
		]
	}
}

# reports an error if prometheus service port is of invalid type.
lint[output] {
	svc_type := installer.spec.prometheus.serviceType
	svc_type != ""
	svc_type != "NodePort"
	svc_type != "ClusterIP"
	msg := sprintf("Prometheus service types are NodePort and ClusterIP, not %v", [svc_type])
	output := {
		"type": "misconfiguration",
		"severity": "error",
		"message": msg,
		"patch": [
			{ "op": "replace", "path": "/spec/prometheus/serviceType", "value": "ClusterIP" }
		]
	}
}

# prometheus service type is only supported for versions >= 0.48.1
lint[output] {
	installer.spec.prometheus.serviceType
	is_addon_version_lower_than("prometheus", "0.48.1")
	output := {
		"type": "misconfiguration",
		"severity": "error",
		"message": "Prometheus service types is supported only for versions 0.48.1-16.10.0+",
		"patch": [
			{ "op": "replace", "path": "/spec/prometheus/version", "value": newest_add_on_version("prometheus") }
		]
	}
}

# verifies rook 1.8.x is not compatible with EKCO versions < 0.22.0
lint[output] {
	is_addon_version_greater_than_or_equal("rook", "1.8.0")
	is_addon_version_lower_than("rook", "1.9.0")
	installer.spec.ekco.version != ""
	is_addon_version_lower_than("ekco", "0.22.0")
	output := {
		"type": "incompatibility",
		"severity": "error",
		"message": "Rook versions >= 1.8.0 are not compatible with EKCO versions < 0.22.0",
		"patch": [
			{ "op": "replace", "path": "/spec/ekco/version", "value": newest_add_on_version("ekco") },
			{ "op": "replace", "path": "/spec/rook/version", "value": newest_add_on_version("rook") }
		]
	}
}

# verifies velero 1.6.2 is not compatible with kubernetes versions >= 1.22+
lint[output] {
	is_addon_version_greater_than_or_equal("kubernetes", "1.22.0")
	is_addon_version_lower_than("velero", "1.6.3")
	output := {
		"type": "incompatibility",
		"severity": "error",
		"message": "Velero versions <= 1.6.2 are not compatible with Kubernetes versions 1.22+",
		"patch": [
			{ "op": "replace", "path": "/spec/velero/version", "value": newest_add_on_version("velero") }
		]
	}
}
# verifies rook 1.9.x is not compatible with EKCO versions < 0.23.0
lint[output] {
	is_addon_version_greater_than_or_equal("rook", "1.9.0")
	installer.spec.ekco.version != ""
	is_addon_version_lower_than("ekco", "0.23.0")
	output := {
		"type": "incompatibility",
		"severity": "error",
		"message": "Rook versions >= 1.9.0 are not compatible with EKCO versions < 0.23.0",
		"patch": [
			{ "op": "replace", "path": "/spec/ekco/version", "value": newest_add_on_version("ekco") }
		]
	}
}

# verifies Contour 1.7.0 is not compatible with kubernetes versions >= 1.22+
lint[output] {
	is_addon_version_greater_than_or_equal("kubernetes", "1.22.0")
	is_addon_version_lower_than("contour", "1.7.1")
	output := {
		"type": "incompatibility",
		"severity": "error",
		"message": "Contour versions <= 1.7.0 are not compatible with Kubernetes 1.22+",
		"patch": [
			{ "op": "replace", "path": "/spec/contour/version", "value": newest_add_on_version("contour") }
		]
	}
}

# verifies if the selected kubernetes version is compatible with the selected containerd
# version. the only thing verified here is that we are not trying to run kubernetes 1.26+
# with containerd < 1.6.0.
lint[output] {
	is_addon_version_greater_than_or_equal("kubernetes", "1.26.0")
	is_addon_version_lower_than("containerd", "1.6.0")
	output := {
		"type": "incompatibility",
		"severity": "error",
		"message": "Kubernetes 1.26+ is not compatible with Containerd versions < 1.6.0",
		"patch": [
			{ "op": "replace", "path": "/spec/containerd/version", "value": newest_add_on_version("containerd") }
		]
	}
}

# verifies if flannel is compatible with the selected container runtime. flannel and docker are
# incompatible. containerd is required.
lint[output] {
	installer.spec.docker.version != ""
	installer.spec.flannel.version != ""
	output := {
		"type": "incompatibility",
		"severity": "error",
		"message": "Flannel is not compatible with the Docker runtime, Containerd is required",
		"patch": [
			{ "op": "remove", "path": "/spec/docker" },
			{ "op": "add", "path": "/spec/containerd/version", "value": newest_add_on_version("containerd") }
		]
	}
}
