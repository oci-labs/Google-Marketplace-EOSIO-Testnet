FROM launcher.gcr.io/google/debian9 AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends gettext

ADD chart/eosio-testnet-mp /tmp/chart
RUN cd /tmp \
    && tar -czvf /tmp/eosio-testnet-mp.tar.gz chart

ADD schema.yaml /tmp/schema.yaml

# Provide registry prefix and tag for default values for images.
ARG REGISTRY
ARG TAG
RUN cat /tmp/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "TAG=$TAG" envsubst \
    > /tmp/schema.yaml.new \
    && mv /tmp/schema.yaml.new /tmp/schema.yaml


FROM gcr.io/cloud-marketplace-tools/k8s/deployer_helm
COPY --from=build /tmp/eosio-testnet-mp.tar.gz /data/chart/
COPY --from=build /tmp/schema.yaml /data/
RUN ln -s /data /data-test