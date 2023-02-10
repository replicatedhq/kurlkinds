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
		"message": "No container runtime (Docker or Containerd) selected",
		"field": "spec"
	}
}

# reports an error if user has selected multiple container runtimes at the same
# time. only one can be selected (or docker or containerd).
lint[output] {
	count(container_runtimes) > 1
	output := {
		"type": "misconfiguration",
		"message": "Multiple container runtimes selected",
		"field": "spec"
	}
}

# generates an error if kubernetes is the selected distribution but no cni plugin has
# been selected by the user.
lint[output] {
	installer.spec.kubernetes.version != ""
	count(cni_providers) == 0
	output :=  {
		"type": "misconfiguration",
		"message": "No CNI plugin (Flannel, Weave or Antrea) selected",
		"field": "spec"
	}
}

# returns an error if the config has any two of flannel, weave or antrea selected at the same time.
lint[output] {
	count(cni_providers) > 1
	output := {
		"type": "misconfiguration",
		"message": "Multiple CNI plugins selected (choose one of Flannel, Weave or Antrea)",
		"field": "spec"
	}
}

# checks if there is at least one selected kubernetes distro (kubernetes).
lint[output] {
	count(kube_distributions) == 0
	output := {
		"type": "misconfiguration",
		"message": "No kubernetes distribution selected",
		"field": "spec"
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
		"message": "Kubernetes 1.24+ does not support Docker runtime, Containerd is recommended",
		"field": "spec.docker"
	}
}

# verifies if the kubernetes service cidr override provided by the user is valid.
lint[output] {
	not valid_kubernetes_service_cidr_override
	output := {
		"type": "misconfiguration",
		"message": "Invalid Kubernetes services CIDR",
		"field": "spec.kubernetes.serviceCIDR"
	}
}

# verifies if the kubernetes service cidr range override provided by the user is valid.
lint[output] {
	not valid_kubernetes_service_cidr_range_override
	output := {
		"type": "misconfiguration",
		"message": "Invalid Kubernetes services CIDR range",
		"field": "spec.kubernetes.serviceCidrRange"
	}
}

# verifies if the weave pod cidr range override provided by the user is valid.
lint[output] {
	not valid_pod_cidr_range_override(installer.spec.weave.podCidrRange)
	output := {
		"type": "misconfiguration",
		"message": "Invalid Weave pod CIDR range",
		"field": "spec.weave.podCidrRange"
	}
}

# verifies if the weave pod cidr override provided by the user is valid.
lint[output] {
	installer.spec.weave.podCIDR
	not valid_ipv4_cidr(installer.spec.weave.podCIDR)
	output := {
		"type": "misconfiguration",
		"message": "Invalid Weave pod CIDR",
		"field": "spec.weave.podCIDR"
	}
}

# verifies if the flannel pod cidr range override provided by the user is valid.
lint[output] {
	not valid_pod_cidr_range_override(installer.spec.flannel.podCIDRRange)
	output := {
		"type": "misconfiguration",
		"message": "Invalid Flannel pod CIDR range",
		"field": "spec.flannel.podCIDRRange"
	}
}

# verifies if the flannel pod cidr override provided by the user is valid.
lint[output] {
	installer.spec.flannel.podCIDR
	not valid_ipv4_cidr(installer.spec.flannel.podCIDR)
	output := {
		"type": "misconfiguration",
		"message": "Invalid Flannel pod CIDR",
		"field": "spec.flannel.podCIDR"
	}
}

# verifies if the antrea pod cidr range override provided by the user is valid.
lint[output] {
	not valid_pod_cidr_range_override(installer.spec.antrea.podCidrRange)
	output := {
		"type": "misconfiguration",
		"message": "Invalid Antrea pod CIDR range",
		"field": "spec.antrea.podCidrRange"
	}
}

# verifies if the antrea pod cidr override provided by the user is valid.
lint[output] {
	not valid_antrea_pod_cidr_override
	output := {
		"type": "misconfiguration",
		"message": "Invalid Antrea pod CIDR",
		"field": "spec.antrea.podCIDR"
	}
}

# returns an error if selected kubernetes is >= 1.20 and rook is less than 1.1.0.
lint[output] {
	is_addon_version_greater_than_or_equal("kubernetes", "1.20.0")
	is_addon_version_lower_than("rook", "1.1.0")
	output := {
		"type": "incompatibility",
		"message": "Rook versions <= 1.1.0 are not compatible with Kubernetes versions 1.20+",
		"field": "spec.rook.version"
	}
}

# returns an error if longhorn <= 1.4.0 is selected with kubernetes >= 1.25.0, this
# pair is incompatible.
lint[output] {
	is_addon_version_greater_than_or_equal("kubernetes", "1.25.0")
	is_addon_version_lower_than("longhorn", "1.4.0")
	output := {
		"type": "incompatibility",
		"message": "Longhorn versions <= 1.4.0 are not compatible with Kubernetes versions 1.25+",
		"field": "spec.longhorn.version"
	}
}

# this returns an error if an invalid or unknown version for an add-on has been selected.
lint[output] {
	some name 
	ignored := known_versions[name]
	not valid_add_on_version(name)
	output := {
		"type": "unknown-addon",
		"message": sprintf("Unknown %v add-on version %v", [name, installer.spec[name].version]),
		"field": sprintf("spec.%v.version", [name])
	}
}

# returns an error if weave has been selected with containerd in versions between 1.6.0 and
# 1.6.4 as this pair is incompatible.
lint[output] {
	is_addon_version_greater_than_or_equal("containerd", "1.6.0")
	is_addon_version_lower_than_or_equal("containerd", "1.6.4")
	output := {
		"type": "incompatibility",
		"message": "Containerd versions 1.6.0 - 1.6.4 are not compatible with Weave",
		"field": "spec.containerd.version"
	}
}

# reports incompatiblity error for the openebs <= 2.12.9 and kubernetes >= 1.22.0 duo.
lint[output] {
	is_addon_version_greater_than_or_equal("kubernetes", "1.22.0")
	is_addon_version_lower_than_or_equal("openebs", "2.12.9")
	output := {
		"type": "incompatibility",
		"message": "OpenEBS versions <= 2.12.9 are not compatible with Kubernetes 1.22+",
		"field": "spec.openebs.version"
	}
}

# if due to a network error we could not load the list of known versions we report an error
# as well.
lint[output] {
	remote_versions.error.message
	output :=  {
		"type": "preprocess",
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
		"message": "OpenEBS add-on versions >= 2.12.9 do not support cStor",
		"field": "spec.openebs.isCstorEnabled"
	}
}

# reports an error if rook is <= 1.9.10 and kubernetes >= 1.25 as this pair is incompatible.
lint[output] {
	is_addon_version_greater_than_or_equal("kubernetes", "1.25.0")
	is_addon_version_lower_than_or_equal("rook", "1.9.10")
	output := {
		"type": "incompatibility",
		"message": "Rook versions <= 1.9.10 are not compatible with Kubernetes 1.25+",
		"field": "spec.rook.version"
	}
}

# prometheus versions <= 0.49.0-17.1.3 are incompatible with Kubernetes 1.22+.
lint[output] {
	is_addon_version_greater_than_or_equal("kubernetes", "1.22.0")
	is_addon_version_lower_than_or_equal("prometheus", "0.49.0")
	output := {
		"type": "incompatibility",
		"message": "Prometheus versions <= 0.49.0-17.1.3 are not compatible with Kubernetes 1.22+",
		"field": "spec.prometheus.version"
	}
}

# prometheus versions less than or equal to 0.59.0 are not compatible with kubernetes 1.25+.
lint[output] {
	is_addon_version_greater_than_or_equal("kubernetes", "1.25.0")
	is_addon_version_lower_than_or_equal("prometheus", "0.59.0")
	output := {
		"type": "incompatibility",
		"message": "Prometheus versions <= 0.59.0 are not compatible with Kubernetes 1.25+",
		"field": "spec.prometheus.version"
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
		"message": msg,
		"field": "spec.prometheus.serviceType"
	}
}

# prometheus service type is only supported for versions >= 0.48.1
lint[output] {
	installer.spec.prometheus.serviceType
	is_addon_version_lower_than("prometheus", "0.48.1")
	output := {
		"type": "misconfiguration",
		"message": "Prometheus service types is supported only for versions 0.48.1-16.10.0+",
		"field": "spec.prometheus.serviceType"
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
		"message": "Rook versions >= 1.8.0 are not compatible with EKCO versions < 0.22.0",
		"field": "spec.ekco.version"
	}
}

# verifies velero 1.6.2 is not compatible with kubernetes versions >= 1.22+
lint[output] {
	is_addon_version_greater_than_or_equal("kubernetes", "1.22.0")
	is_addon_version_lower_than("velero", "1.6.3")
	output := {
		"type": "incompatibility",
		"message": "Velero versions <= 1.6.2 are not compatible with Kubernetes versions 1.22+",
		"field": "spec.velero.version"
	}
}
# verifies rook 1.9.x is not compatible with EKCO versions < 0.23.0
lint[output] {
	is_addon_version_greater_than_or_equal("rook", "1.9.0")
	installer.spec.ekco.version != ""
	is_addon_version_lower_than("ekco", "0.23.0")
	output := {
		"type": "incompatibility",
		"message": "Rook versions >= 1.9.0 are not compatible with EKCO versions < 0.23.0",
		"field": "spec.ekco.version"
	}
}

# verifies if the selected kubernetes version is compatible with the selected containerd
# version. the only thing verified here is that we are not trying to run kubernetes 1.26+
# with containerd >= 1.6.0.
lint[output] {
	is_addon_version_greater_than_or_equal("kubernetes", "1.26.0")
	is_addon_version_lower_than("containerd", "1.6.0")
	output := {
		"type": "incompatibility",
		"message": "Kubernetes 1.26+ is not compatible with Containerd versions < 1.6.0",
		"field": "spec.containerd"
	}
}

# verifies if flannel is compatible with the selected container runtime. flannel and docker are
# incompatible. containerd is required.
lint[output] {
	installer.spec.docker.version != ""
	installer.spec.flannel.version != ""
	output := {
		"type": "incompatibility",
		"message": "Flannel is not compatible with the Docker runtime, Containerd is required",
		"field": "spec.docker"
	}
}
