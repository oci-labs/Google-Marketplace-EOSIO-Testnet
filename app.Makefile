ifndef __APP_MAKEFILE__

__APP_MAKEFILE__ := included


include common.Makefile
include var.Makefile


# Combines APP_PARAMETERS and APP_TEST_PARAMETERS.
define combined_parameters
$(shell echo '$(APP_PARAMETERS)' '$(APP_TEST_PARAMETERS)' \
    | docker run -i --entrypoint=/usr/bin/jq --rm $(APP_DEPLOYER_IMAGE) -s '.[0] * .[1]')
endef


.build/app: | .build
	mkdir -p "$@"


.build/app/dev: .build/var/MARKETPLACE_TOOLS_TAG \
              | .build/app
	$(call print_target)
	docker run \
	    "gcr.io/cloud-marketplace-tools/k8s/dev:$(MARKETPLACE_TOOLS_TAG)" \
	    cat /scripts/dev > "$@"
	chmod a+x "$@"


.PHONY: app/phony
app/phony: ;


# Builds the application containers and push them to the registry.
# Including Makefile can extend this target. This target is
# a prerequisite for install.
.PHONY: app/build
app/build:: ;


# Installs the application into target namespace on the cluster.
.PHONY: app/install
app/install:: app/build \
              .build/var/APP_DEPLOYER_IMAGE \
              .build/var/APP_PARAMETERS \
              .build/var/HOME \
              .build/var/MARKETPLACE_TOOLS_TAG \
              | .build/app/dev
	$(call print_target)
	.build/app/dev \
	    /scripts/install \
	        --deployer='$(APP_DEPLOYER_IMAGE)' \
	        --parameters='$(APP_PARAMETERS)' \
	        --entrypoint="/bin/deploy.sh"


# Installs the application into target namespace on the cluster.
.PHONY: app/install-test
app/install-test:: app/build \
                   .build/var/APP_DEPLOYER_IMAGE \
                   .build/var/APP_PARAMETERS \
                   .build/var/APP_TEST_PARAMETERS \
                   .build/var/HOME \
                   .build/var/MARKETPLACE_TOOLS_TAG \
	           | .build/app/dev
	$(call print_target)
	.build/app/dev \
	    /scripts/install \
	        --deployer='$(APP_DEPLOYER_IMAGE)' \
	        --parameters='$(call combined_parameters)' \
	        --entrypoint="/bin/deploy_with_tests.sh"


# Uninstalls the application from the target namespace on the cluster.
.PHONY: app/uninstall
app/uninstall: .build/var/APP_DEPLOYER_IMAGE \
               .build/var/APP_PARAMETERS
	$(call print_target)
	kubectl delete 'application/$(NAME)' \
	    --namespace='$(NAMESPACE)' \
	    --ignore-not-found


# Runs the verification pipeline.
.PHONY: app/verify
app/verify: app/build \
            .build/var/APP_DEPLOYER_IMAGE \
            .build/var/APP_PARAMETERS \
            .build/var/APP_TEST_PARAMETERS \
            .build/var/HOME \
            .build/var/MARKETPLACE_TOOLS_TAG \
            | .build/app/dev
	$(call print_target)
	.build/app/dev \
	    /scripts/verify \
	          --deployer='$(APP_DEPLOYER_IMAGE)' \
	          --parameters='$(call combined_parameters)'

.PHONY: app/watch
app/watch:
	kubectl get all -l "release=$(NAME)" --namespace $(NAMESPACE)
	
endif
