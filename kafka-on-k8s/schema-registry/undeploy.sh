#!/usr/bin/env bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

WORK_DIR="$BASE_DIR/schema-registry"

source $BASE_DIR/util/check.sh
checkVar DOCKER_REGISTRY DOCKER_ORG

if [[ "${SCHEMA_DOCKER_REGISTRY}" != "" ]]; then
  DOCKER_REGISTRY=${SCHEMA_DOCKER_REGISTRY}
fi
schema_registry_image=${DOCKER_REGISTRY}/${DOCKER_ORG}/linktime-schema-registry-k8s:6.2.0
echo "schema-registry image:${schema_registry_image}"

echo "WORK_DIR=${WORK_DIR}"

# deploy kafka cluster
pushd "${WORK_DIR}" > /dev/null
sed "s#{{schema_registry_image}}#${schema_registry_image}#g" schema-registry.yaml > schema-registry.yaml.tmp
kubectl delete -f schema-registry.yaml.tmp
popd
