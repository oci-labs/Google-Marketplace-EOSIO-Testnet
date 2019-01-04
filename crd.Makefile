ifndef __CRD_MAKEFILE__

__CRD_MAKEFILE__ := included

include common.Makefile

app-crd.yaml:
	curl -sLO https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml 

# Installs the application CRD on the cluster.
.PHONY: crd/install
crd/install: app-crd.yaml
	kubectl apply -f "app-crd.yaml"

# Uninstalls the application CRD from the cluster.
.PHONY: crd/uninstall
crd/uninstall:
	kubectl delete -f "app-crd.yaml"


endif
