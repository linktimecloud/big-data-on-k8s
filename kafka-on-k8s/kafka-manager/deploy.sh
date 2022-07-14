#!/usr/bin/env bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

WORK_DIR="$BASE_DIR/kafka-manager"

source $BASE_DIR/util/check.sh
checkVar DOCKER_REGISTRY DOCKER_ORG

echo "WORK_DIR=${WORK_DIR}"
kafka_manager_image=${DOCKER_REGISTRY}/${DOCKER_ORG}/kafka-manager:1.0.0
echo "kafka_manager image:${kafka_manager_image}"

# waiting for strimzi operator startup
split() {
   # Usage: split "string" "delimiter"
   IFS=$'\n' read -d "" -ra arr <<< "${1//$2/$'\n'}"
}

# download images
docker pull ${kafka_manager_image}

# deploy kafka cluster
pushd "${WORK_DIR}" > /dev/null
sed "s#{{kafka_manager_image}}#${kafka_manager_image}#g" kafka-manager.yaml > kafka-manager.yaml.tmp
kubectl create -f kafka-manager.yaml.tmp
popd

POD_NAME_PREFIX=kafka-manager
READY_STR=$(kubectl get pods|grep ${POD_NAME_PREFIX}|head -n 1|awk '{print $2}')
while [ -z "${READY_STR}" ]; do
  echo "waiting for ${POD_NAME_PREFIX} to create"
  sleep 5
  READY_STR=$(kubectl get pods|grep ${POD_NAME_PREFIX}|head -n 1|awk '{print $2}')
done

split "${READY_STR}" "/"
while [ "${arr[0]}" != "${arr[1]}" ]; do
  echo "waiting for ${POD_NAME_PREFIX} to start"
  sleep 5
  READY_STR=$(kubectl get pods|grep ${POD_NAME_PREFIX}|head -n 1|awk '{print $2}')
  split "${READY_STR}" "/"
done

kubectl exec -i kafka-cluster-strimzi-kafka-0 -- curl -X GET http://kafka-manager-svc:9060/health
