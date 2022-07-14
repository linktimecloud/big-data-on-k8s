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

READY_STR=$(kubectl get pods|grep kafka-cluster-strimzi-kafka-0|head -n 1|awk '{print $2}')
while [ -z "${READY_STR}" ]; do
  echo "waiting for kafka to create"
  sleep 5
  READY_STR=$(kubectl get pods|grep kafka-cluster-strimzi-kafka-0|head -n 1|awk '{print $2}')
done

split "${READY_STR}" "/"
while [ "${arr[0]}" != "${arr[1]}" ]; do
  echo "waiting for kafka cluster to start"
  sleep 5
  READY_STR=$(kubectl get pods|grep kafka-cluster-strimzi-kafka-0|head -n 1|awk '{print $2}')
  split "${READY_STR}" "/"
done

set -e

# deploy kafka cluster
pushd "${WORK_DIR}" > /dev/null
echo "create schema-registry"
sed "s#{{schema_registry_image}}#${schema_registry_image}#g" schema-registry.yaml > schema-registry.yaml.tmp
kubectl create -f schema-registry.yaml.tmp
popd
set +e


POD_NAME_PREFIX=schema-registry-cluster
READY_STR=$(kubectl get pods|grep ${POD_NAME_PREFIX}|head -n 1|awk '{print $2}')
while [ -z "${READY_STR}" ]; do
  echo "waiting for schema-registry to create"
  sleep 5
  READY_STR=$(kubectl get pods|grep ${POD_NAME_PREFIX}|head -n 1|awk '{print $2}')
done

split "${READY_STR}" "/"
while [ "${arr[0]}" != "${arr[1]}" ]; do
  echo "waiting for schema-registry to start"
  sleep 5
  READY_STR=$(kubectl get pods|grep ${POD_NAME_PREFIX}|head -n 1|awk '{print $2}')
  split "${READY_STR}" "/"
done

kubectl exec -i kafka-cluster-strimzi-kafka-0 -- curl -X GET http://schema-registry-cluster-svc:8085/subjects
