//go:build !ignore_autogenerated
// +build !ignore_autogenerated

/*
Copyright 2020 Replicated Inc.

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
// Code generated by deepcopy-gen. DO NOT EDIT.

package v1beta1

import (
	v1beta2 "github.com/replicatedhq/troubleshoot/pkg/apis/troubleshoot/v1beta2"
	runtime "k8s.io/apimachinery/pkg/runtime"
)

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *AWS) DeepCopyInto(out *AWS) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new AWS.
func (in *AWS) DeepCopy() *AWS {
	if in == nil {
		return nil
	}
	out := new(AWS)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *Antrea) DeepCopyInto(out *Antrea) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new Antrea.
func (in *Antrea) DeepCopy() *Antrea {
	if in == nil {
		return nil
	}
	out := new(Antrea)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *Calico) DeepCopyInto(out *Calico) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new Calico.
func (in *Calico) DeepCopy() *Calico {
	if in == nil {
		return nil
	}
	out := new(Calico)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *CertManager) DeepCopyInto(out *CertManager) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new CertManager.
func (in *CertManager) DeepCopy() *CertManager {
	if in == nil {
		return nil
	}
	out := new(CertManager)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *Collectd) DeepCopyInto(out *Collectd) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new Collectd.
func (in *Collectd) DeepCopy() *Collectd {
	if in == nil {
		return nil
	}
	out := new(Collectd)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *Containerd) DeepCopyInto(out *Containerd) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new Containerd.
func (in *Containerd) DeepCopy() *Containerd {
	if in == nil {
		return nil
	}
	out := new(Containerd)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *Contour) DeepCopyInto(out *Contour) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new Contour.
func (in *Contour) DeepCopy() *Contour {
	if in == nil {
		return nil
	}
	out := new(Contour)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *Docker) DeepCopyInto(out *Docker) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new Docker.
func (in *Docker) DeepCopy() *Docker {
	if in == nil {
		return nil
	}
	out := new(Docker)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *Ekco) DeepCopyInto(out *Ekco) {
	*out = *in
	if in.PodImageOverrides != nil {
		in, out := &in.PodImageOverrides, &out.PodImageOverrides
		*out = make([]string, len(*in))
		copy(*out, *in)
	}
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new Ekco.
func (in *Ekco) DeepCopy() *Ekco {
	if in == nil {
		return nil
	}
	out := new(Ekco)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *FirewalldConfig) DeepCopyInto(out *FirewalldConfig) {
	*out = *in
	if in.FirewalldCmds != nil {
		in, out := &in.FirewalldCmds, &out.FirewalldCmds
		*out = make([][]string, len(*in))
		for i := range *in {
			if (*in)[i] != nil {
				in, out := &(*in)[i], &(*out)[i]
				*out = make([]string, len(*in))
				copy(*out, *in)
			}
		}
	}
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new FirewalldConfig.
func (in *FirewalldConfig) DeepCopy() *FirewalldConfig {
	if in == nil {
		return nil
	}
	out := new(FirewalldConfig)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *Fluentd) DeepCopyInto(out *Fluentd) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new Fluentd.
func (in *Fluentd) DeepCopy() *Fluentd {
	if in == nil {
		return nil
	}
	out := new(Fluentd)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *Goldpinger) DeepCopyInto(out *Goldpinger) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new Goldpinger.
func (in *Goldpinger) DeepCopy() *Goldpinger {
	if in == nil {
		return nil
	}
	out := new(Goldpinger)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *Helm) DeepCopyInto(out *Helm) {
	*out = *in
	if in.AdditionalImages != nil {
		in, out := &in.AdditionalImages, &out.AdditionalImages
		*out = make([]string, len(*in))
		copy(*out, *in)
	}
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new Helm.
func (in *Helm) DeepCopy() *Helm {
	if in == nil {
		return nil
	}
	out := new(Helm)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *Installer) DeepCopyInto(out *Installer) {
	*out = *in
	out.TypeMeta = in.TypeMeta
	in.ObjectMeta.DeepCopyInto(&out.ObjectMeta)
	in.Spec.DeepCopyInto(&out.Spec)
	out.Status = in.Status
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new Installer.
func (in *Installer) DeepCopy() *Installer {
	if in == nil {
		return nil
	}
	out := new(Installer)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyObject is an autogenerated deepcopy function, copying the receiver, creating a new runtime.Object.
func (in *Installer) DeepCopyObject() runtime.Object {
	if c := in.DeepCopy(); c != nil {
		return c
	}
	return nil
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *InstallerList) DeepCopyInto(out *InstallerList) {
	*out = *in
	out.TypeMeta = in.TypeMeta
	in.ListMeta.DeepCopyInto(&out.ListMeta)
	if in.Items != nil {
		in, out := &in.Items, &out.Items
		*out = make([]Installer, len(*in))
		for i := range *in {
			(*in)[i].DeepCopyInto(&(*out)[i])
		}
	}
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new InstallerList.
func (in *InstallerList) DeepCopy() *InstallerList {
	if in == nil {
		return nil
	}
	out := new(InstallerList)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyObject is an autogenerated deepcopy function, copying the receiver, creating a new runtime.Object.
func (in *InstallerList) DeepCopyObject() runtime.Object {
	if c := in.DeepCopy(); c != nil {
		return c
	}
	return nil
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *InstallerSpec) DeepCopyInto(out *InstallerSpec) {
	*out = *in
	if in.Kubernetes != nil {
		in, out := &in.Kubernetes, &out.Kubernetes
		*out = new(Kubernetes)
		**out = **in
	}
	if in.RKE2 != nil {
		in, out := &in.RKE2, &out.RKE2
		*out = new(RKE2)
		**out = **in
	}
	if in.K3S != nil {
		in, out := &in.K3S, &out.K3S
		*out = new(K3S)
		**out = **in
	}
	if in.Docker != nil {
		in, out := &in.Docker, &out.Docker
		*out = new(Docker)
		**out = **in
	}
	if in.Weave != nil {
		in, out := &in.Weave, &out.Weave
		*out = new(Weave)
		(*in).DeepCopyInto(*out)
	}
	if in.Antrea != nil {
		in, out := &in.Antrea, &out.Antrea
		*out = new(Antrea)
		**out = **in
	}
	if in.Calico != nil {
		in, out := &in.Calico, &out.Calico
		*out = new(Calico)
		**out = **in
	}
	if in.Contour != nil {
		in, out := &in.Contour, &out.Contour
		*out = new(Contour)
		**out = **in
	}
	if in.Rook != nil {
		in, out := &in.Rook, &out.Rook
		*out = new(Rook)
		**out = **in
	}
	if in.Registry != nil {
		in, out := &in.Registry, &out.Registry
		*out = new(Registry)
		**out = **in
	}
	if in.Prometheus != nil {
		in, out := &in.Prometheus, &out.Prometheus
		*out = new(Prometheus)
		**out = **in
	}
	if in.Fluentd != nil {
		in, out := &in.Fluentd, &out.Fluentd
		*out = new(Fluentd)
		**out = **in
	}
	if in.Kotsadm != nil {
		in, out := &in.Kotsadm, &out.Kotsadm
		*out = new(Kotsadm)
		**out = **in
	}
	if in.Velero != nil {
		in, out := &in.Velero, &out.Velero
		*out = new(Velero)
		**out = **in
	}
	if in.Minio != nil {
		in, out := &in.Minio, &out.Minio
		*out = new(Minio)
		**out = **in
	}
	if in.OpenEBS != nil {
		in, out := &in.OpenEBS, &out.OpenEBS
		*out = new(OpenEBS)
		**out = **in
	}
	if in.Kurl != nil {
		in, out := &in.Kurl, &out.Kurl
		*out = new(Kurl)
		(*in).DeepCopyInto(*out)
	}
	if in.SelinuxConfig != nil {
		in, out := &in.SelinuxConfig, &out.SelinuxConfig
		*out = new(SelinuxConfig)
		(*in).DeepCopyInto(*out)
	}
	if in.IptablesConfig != nil {
		in, out := &in.IptablesConfig, &out.IptablesConfig
		*out = new(IptablesConfig)
		(*in).DeepCopyInto(*out)
	}
	if in.FirewalldConfig != nil {
		in, out := &in.FirewalldConfig, &out.FirewalldConfig
		*out = new(FirewalldConfig)
		(*in).DeepCopyInto(*out)
	}
	if in.Ekco != nil {
		in, out := &in.Ekco, &out.Ekco
		*out = new(Ekco)
		(*in).DeepCopyInto(*out)
	}
	if in.Containerd != nil {
		in, out := &in.Containerd, &out.Containerd
		*out = new(Containerd)
		**out = **in
	}
	if in.Collectd != nil {
		in, out := &in.Collectd, &out.Collectd
		*out = new(Collectd)
		**out = **in
	}
	if in.CertManager != nil {
		in, out := &in.CertManager, &out.CertManager
		*out = new(CertManager)
		**out = **in
	}
	if in.MetricsServer != nil {
		in, out := &in.MetricsServer, &out.MetricsServer
		*out = new(MetricsServer)
		**out = **in
	}
	if in.Helm != nil {
		in, out := &in.Helm, &out.Helm
		*out = new(Helm)
		(*in).DeepCopyInto(*out)
	}
	if in.Longhorn != nil {
		in, out := &in.Longhorn, &out.Longhorn
		*out = new(Longhorn)
		**out = **in
	}
	if in.Sonobuoy != nil {
		in, out := &in.Sonobuoy, &out.Sonobuoy
		*out = new(Sonobuoy)
		**out = **in
	}
	if in.UFWConfig != nil {
		in, out := &in.UFWConfig, &out.UFWConfig
		*out = new(UFWConfig)
		**out = **in
	}
	if in.Goldpinger != nil {
		in, out := &in.Goldpinger, &out.Goldpinger
		*out = new(Goldpinger)
		**out = **in
	}
	if in.AWS != nil {
		in, out := &in.AWS, &out.AWS
		*out = new(AWS)
		**out = **in
	}
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new InstallerSpec.
func (in *InstallerSpec) DeepCopy() *InstallerSpec {
	if in == nil {
		return nil
	}
	out := new(InstallerSpec)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *InstallerStatus) DeepCopyInto(out *InstallerStatus) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new InstallerStatus.
func (in *InstallerStatus) DeepCopy() *InstallerStatus {
	if in == nil {
		return nil
	}
	out := new(InstallerStatus)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *IptablesConfig) DeepCopyInto(out *IptablesConfig) {
	*out = *in
	if in.IptablesCmds != nil {
		in, out := &in.IptablesCmds, &out.IptablesCmds
		*out = make([][]string, len(*in))
		for i := range *in {
			if (*in)[i] != nil {
				in, out := &(*in)[i], &(*out)[i]
				*out = make([]string, len(*in))
				copy(*out, *in)
			}
		}
	}
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new IptablesConfig.
func (in *IptablesConfig) DeepCopy() *IptablesConfig {
	if in == nil {
		return nil
	}
	out := new(IptablesConfig)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *K3S) DeepCopyInto(out *K3S) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new K3S.
func (in *K3S) DeepCopy() *K3S {
	if in == nil {
		return nil
	}
	out := new(K3S)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *Kotsadm) DeepCopyInto(out *Kotsadm) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new Kotsadm.
func (in *Kotsadm) DeepCopy() *Kotsadm {
	if in == nil {
		return nil
	}
	out := new(Kotsadm)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *Kubernetes) DeepCopyInto(out *Kubernetes) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new Kubernetes.
func (in *Kubernetes) DeepCopy() *Kubernetes {
	if in == nil {
		return nil
	}
	out := new(Kubernetes)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *Kurl) DeepCopyInto(out *Kurl) {
	*out = *in
	if in.AdditionalNoProxyAddresses != nil {
		in, out := &in.AdditionalNoProxyAddresses, &out.AdditionalNoProxyAddresses
		*out = make([]string, len(*in))
		copy(*out, *in)
	}
	if in.HostPreflights != nil {
		in, out := &in.HostPreflights, &out.HostPreflights
		*out = new(v1beta2.HostPreflight)
		(*in).DeepCopyInto(*out)
	}
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new Kurl.
func (in *Kurl) DeepCopy() *Kurl {
	if in == nil {
		return nil
	}
	out := new(Kurl)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *Longhorn) DeepCopyInto(out *Longhorn) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new Longhorn.
func (in *Longhorn) DeepCopy() *Longhorn {
	if in == nil {
		return nil
	}
	out := new(Longhorn)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *MetricsServer) DeepCopyInto(out *MetricsServer) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new MetricsServer.
func (in *MetricsServer) DeepCopy() *MetricsServer {
	if in == nil {
		return nil
	}
	out := new(MetricsServer)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *Minio) DeepCopyInto(out *Minio) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new Minio.
func (in *Minio) DeepCopy() *Minio {
	if in == nil {
		return nil
	}
	out := new(Minio)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *OpenEBS) DeepCopyInto(out *OpenEBS) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new OpenEBS.
func (in *OpenEBS) DeepCopy() *OpenEBS {
	if in == nil {
		return nil
	}
	out := new(OpenEBS)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *Prometheus) DeepCopyInto(out *Prometheus) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new Prometheus.
func (in *Prometheus) DeepCopy() *Prometheus {
	if in == nil {
		return nil
	}
	out := new(Prometheus)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *RKE2) DeepCopyInto(out *RKE2) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new RKE2.
func (in *RKE2) DeepCopy() *RKE2 {
	if in == nil {
		return nil
	}
	out := new(RKE2)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *Registry) DeepCopyInto(out *Registry) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new Registry.
func (in *Registry) DeepCopy() *Registry {
	if in == nil {
		return nil
	}
	out := new(Registry)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *Rook) DeepCopyInto(out *Rook) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new Rook.
func (in *Rook) DeepCopy() *Rook {
	if in == nil {
		return nil
	}
	out := new(Rook)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *SelinuxConfig) DeepCopyInto(out *SelinuxConfig) {
	*out = *in
	if in.ChconCmds != nil {
		in, out := &in.ChconCmds, &out.ChconCmds
		*out = make([][]string, len(*in))
		for i := range *in {
			if (*in)[i] != nil {
				in, out := &(*in)[i], &(*out)[i]
				*out = make([]string, len(*in))
				copy(*out, *in)
			}
		}
	}
	if in.SemanageCmds != nil {
		in, out := &in.SemanageCmds, &out.SemanageCmds
		*out = make([][]string, len(*in))
		for i := range *in {
			if (*in)[i] != nil {
				in, out := &(*in)[i], &(*out)[i]
				*out = make([]string, len(*in))
				copy(*out, *in)
			}
		}
	}
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new SelinuxConfig.
func (in *SelinuxConfig) DeepCopy() *SelinuxConfig {
	if in == nil {
		return nil
	}
	out := new(SelinuxConfig)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *Sonobuoy) DeepCopyInto(out *Sonobuoy) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new Sonobuoy.
func (in *Sonobuoy) DeepCopy() *Sonobuoy {
	if in == nil {
		return nil
	}
	out := new(Sonobuoy)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *UFWConfig) DeepCopyInto(out *UFWConfig) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new UFWConfig.
func (in *UFWConfig) DeepCopy() *UFWConfig {
	if in == nil {
		return nil
	}
	out := new(UFWConfig)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *Velero) DeepCopyInto(out *Velero) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new Velero.
func (in *Velero) DeepCopy() *Velero {
	if in == nil {
		return nil
	}
	out := new(Velero)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *Weave) DeepCopyInto(out *Weave) {
	*out = *in
	if in.NoMasqLocal != nil {
		in, out := &in.NoMasqLocal, &out.NoMasqLocal
		*out = new(bool)
		**out = **in
	}
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new Weave.
func (in *Weave) DeepCopy() *Weave {
	if in == nil {
		return nil
	}
	out := new(Weave)
	in.DeepCopyInto(out)
	return out
}
