#!/usr/bin/env bash

set +x

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

WORK_DIR="$BASE_DIR/kafka-operator"
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"

echo "WORK_DIR=${WORK_DIR}"
echo "ROOT_DIR=${ROOT_DIR}"

# build strimzi kafka operator and deploy operator
pushd "${ROOT_DIR}" > /dev/null
mkdir -p /tmp/strimzi-kafka-operator
cp -fr packaging/install/cluster-operator/* /tmp/strimzi-kafka-operator/
rm -fr /tmp/strimzi-kafka-operator/060-Deployment-strimzi-cluster-operator.yaml
kubectl create -f /tmp/strimzi-kafka-operator
rm -fr /tmp/strimzi-kafka-operator/*
popd
