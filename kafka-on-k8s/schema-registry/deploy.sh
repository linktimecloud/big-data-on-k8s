#!/usr/bin/env bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

WORK_DIR="$BASE_DIR/schema-registry"

source $BASE_DIR/util/check.sh
checkVar DOCKER_REGISTRY  DOCKER_ORG

if [[ "${SCHEMA_DOCKER_REGISTRY}" != "" ]]; then
  DOCKER_REGISTRY=${SCHEMA_DOCKER_REGISTRY}
fi
schema_registry_image=${DOCKER_REGISTRY}/${DOCKER_ORG}/linktime-schema-registry-k8s:6.2.0
echo "schema-registry image:${schema_registry_image}"

echo "WORK_DIR=${WORK_DIR}"

# waiting for strimzi operator startup
split() {
   # Usage: split "string" "delimiter"
   IFS=$'\n' read -d "" -ra arr <<< "${1//$2/$'\n'}"
}


set -e

kubectl wait pods -l statefulset.kubernetes.io/pod-name=kafka-cluster-strimzi-kafka-0 --for condition=Ready --timeout=90s

# deploy kafka cluster
pushd "${WORK_DIR}" > /dev/null
echo "create schema-registry"
sed "s#{{schema_registry_image}}#${schema_registry_image}#g" schema-registry.yaml > schema-registry.yaml.tmp
kubectl create -f schema-registry.yaml.tmp
popd

sleep 10
kubectl wait pods -l app=schema-registry-cluster --for condition=Ready --timeout=90s

set +e

kubectl exec -i kafka-cluster-strimzi-kafka-0 -- curl -X GET http://schema-registry-cluster-svc:8085/subjects
