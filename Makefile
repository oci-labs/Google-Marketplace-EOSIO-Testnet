MARKETPLACE_TOOLS_TAG = $(shell cat MARKETPLACE_TOOLS_TAG)
include app.Makefile
include crd.Makefile
include var.Makefile
include gcloud.Makefile


TAG ?= v1.5.2
$(info ---- TAG = $(TAG))
APP_DEPLOYER_IMAGE ?= $(REGISTRY)/eosio-testnet/deployer:$(TAG)

NAME ?= eosio-testnet-1
APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)", \
	"imageEos": "$(REGISTRY)/eos:${TAG}" \
}
APP_TEST_PARAMETERS ?= { \
}

# override name_parameter and namespace_parameter so that
# app/uninstall rule can be executed.

override define name_parameter
$(shell echo '$(NAME)')
endef

override define namespace_parameter
$(shell echo '$(NAMESPACE)')
endef


app/build:: .build/eosio-testnet/deployer 


.build/eosio-testnet: | .build
	mkdir -p "$@"


.build/eosio-testnet/deployer: Dockerfile \
                           chart/eosio-testnet-mp/* \
                           chart/eosio-testnet-mp/charts/eosio-testnet/* \
                           chart/eosio-testnet-mp/charts/eosio-testnet/templates/* \
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
