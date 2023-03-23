PROJECT=github.com/replicatedhq/kurlkinds


.PHONY: all
all: test


ENVTEST_K8S_VERSION = 1.26.1
ENVTEST ?= $(LOCALBIN)/setup-envtest
# Run tests
.PHONY: test
test: fmt vet envtest
	KUBEBUILDER_ASSETS="$(shell $(ENVTEST) use $(ENVTEST_K8S_VERSION) --bin-dir $(LOCALBIN) -p path)" go test ./pkg/... -coverprofile cover.out

.PHONY: envtest
envtest: $(ENVTEST) ## Download envtest-setup locally if necessary.
$(ENVTEST): $(LOCALBIN)
	test -s $(LOCALBIN)/setup-envtest || GOBIN=$(LOCALBIN) go install sigs.k8s.io/controller-runtime/tools/setup-envtest@latest

## Location to install dependencies to
LOCALBIN ?= $(shell pwd)/bin
$(LOCALBIN):
	mkdir -p $(LOCALBIN)

# Run go fmt against code
.PHONY: fmt
fmt:
	go fmt ./pkg/...

# Run go vet against code
.PHONY: vet
vet:
	go vet ./pkg/...

# Get binaries
.PHONY: deps
deps: update-controller-gen update-client-gen update-deepcopy-gen envtest

# Generate code
.PHONY: generate
generate: client-gen deepcopy-gen manifests

.PHONY: client-gen
client-gen:
	client-gen \
		--output-package=$(PROJECT)/client \
		--clientset-name kurlclientset \
		--input-base $(PROJECT)/pkg/apis \
		--input cluster/v1beta1 \
		-h ./hack/boilerplate.go.txt \
		-o /tmp
	rm -rf client
	mv /tmp/$(PROJECT)/client .

.PHONY: deepcopy-gen
deepcopy-gen:
	deepcopy-gen \
		-i $(PROJECT)/pkg/apis/cluster/v1beta1 \
		-h hack/boilerplate.go.txt \
		-o /tmp
	mv /tmp/$(PROJECT)/pkg/apis/cluster/v1beta1/deepcopy_generated.go pkg/apis/cluster/v1beta1

.PHONY: manifests
manifests:
	controller-gen \
		rbac:roleName=manager-role webhook crd output:crd:artifacts:config=config/crds/v1beta1 paths=./pkg/apis/...
	sed -i'.orig' -e 's/type: BoolString/type: string/' config/crds/v1beta1/cluster.kurl.sh_installers.yaml
	rm config/crds/v1beta1/cluster.kurl.sh_installers.yaml.orig

.PHONY: test-crd
test-crd:
	kubectl apply -f config/crds/v1beta1/cluster.kurl.sh_installers.yaml
	kubectl apply -f config/test/cluster.kurl.sh_example.yaml
	kubectl delete crd installers.cluster.kurl.sh

.PHONY: schemas
schemas: fmt generate
	go build ${LDFLAGS} -o bin/schemagen ./schemagen
	./bin/schemagen --output-dir ./schemas

.PHONY: update-controller-gen
update-controller-gen:
	go install sigs.k8s.io/controller-tools/cmd/controller-gen@latest

.PHONY: update-client-gen
update-client-gen:
	go install k8s.io/code-generator/cmd/client-gen@latest

.PHONY: update-deepcopy-gen
update-deepcopy-gen:
	go install k8s.io/code-generator/cmd/deepcopy-gen@latest

pkg/lint/tests/versions.json:
	curl -sSL https://k8s.kurl.sh/installer | jq '.' > pkg/lint/tests/versions.json
