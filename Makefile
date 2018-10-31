include vendor/marketplace-tools/app.Makefile
include vendor/marketplace-tools/crd.Makefile
include vendor/marketplace-tools/gcloud.Makefile
include vendor/marketplace-tools/marketplace.Makefile
include vendor/marketplace-tools/ubbagent.Makefile
include vendor/marketplace-tools/var.Makefile


TAG ?= v1.4.1
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/eosio-testnet/deployer:$(TAG)

NAME ?= eosio-testnet-1
APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)", \
	"imageEos": "$(REGISTRY)/eosio-testnet/eos:${TAG}" \
}
APP_TEST_PARAMETERS ?= {}


app/build:: .build/eosio-testnet/deployer \
            .build/eosio-testnet/eos


.build/eosio-testnet: | .build
	mkdir -p "$@"


.build/eosio-testnet/deployer: Dockerfile \
                           chart/eosio-testnet-mp/* \
                           chart/eosio-testnet-mp/charts/eosio-testnet/* \
                           chart/eosio-testnet-mp/templates/* \
                           schema.yaml \
                           .build/var/APP_DEPLOYER_IMAGE \
                           .build/var/REGISTRY \
                           .build/var/TAG \
                           | .build/eosio-testnet
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/eos" \
	    --build-arg TAG="$(TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/eosio-testnet/eos: .build/var/REGISTRY \
                          .build/var/TAG \
                          | .build/eosio-testnet
	docker pull eosio/eos:$(TAG)
	docker tag eosio/eos:$(TAG) \
	    "$(REGISTRY)/eosio-testnet/eos:$(TAG)"
	docker push "$(REGISTRY)/eosio-testnet/eos:$(TAG)"
	@touch "$@"
	

.PHONY: install
install: app/install
	
.PHONY: uninstall
uninstall: .build/var/APP_DEPLOYER_IMAGE \
           .build/var/APP_PARAMETERS
	$(call print_target)
	kubectl delete 'application/$(NAME)' \
	    --namespace='$(NAMESPACE)' \
	    --ignore-not-found

.PHONY: watch
watch:
	kubectl get all -l "release=$(NAME)" --namespace $(NAMESPACE)