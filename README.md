# Overview

This repository contains a kubernetes application used to quickly launch a full EOSIO Blockchain Testnet with 1 or more nodes.  This will allow users 
to have a test environment to debug their smart contracts before deploying to a live EOSIO network.


# Getting started

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this EIOSIO Testnet to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/eosio-testnet).

## Command line instructions

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment:
- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [docker](https://docs.docker.com/install/)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Create a Google Kubernetes Engine cluster

Create a new cluster from the command line:

```shell
export CLUSTER=eosio-cluster
export ZONE=us-central1-a

gcloud container clusters create "$CLUSTER" --zone "$ZONE"
```


## Updating git submodules

You can run the following commands to make sure submodules
are populated with proper code.

```shell
git submodule sync --recursive
git submodule update --recursive --init --force
```

## Setting up your cluster and environment

See [Getting Started](https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/blob/master/README.md#getting-started)

## Installing EOSIO Testnet

Run the following commands from within `testnet-marketplace` folder.

Do a one time setup for application CRD:

```shell
make crd/install
```

Build and install EOSIO Testnet onto your cluster:

```shell
make app/install
```

This will build the containers and install the application. You can
watch the kubernetes resources being created directly from your CLI
by running:

```shell
make app/watch
```

To delete the installation, run:

```shell
make app/uninstall
```

## Overriding context values (Optional)

By default `make` derives docker registry and k8s namespace
from your local configurations of `gcloud` and `kubectl`. 

You can see these values using

```shell
kubectl config view
```

If you want to use values that differ from the local context of `gcloud` and `kubectl`,
you can override them by exporting the appropriate environment variables:

```shell
export REGISTRY=gcr.io/your-registry
export NAMESPACE=your-namespace
export NAME=your-installation-name
export APP_TAG=your-tag
```