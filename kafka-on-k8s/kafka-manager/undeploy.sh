#!/usr/bin/env bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

WORK_DIR="$BASE_DIR/kafka-manager"

source $BASE_DIR/util/check.sh
checkVar DOCKER_REGISTRY DOCKER_ORG

echo "WORK_DIR=${WORK_DIR}"
kafka_manager_image=${DOCKER_REGISTRY}/${DOCKER_ORG}/kafka-manager:1.0.0
echo "kafka_manager image:${kafka_manager_image}"

# undeploy kafka manager
pushd "${WORK_DIR}" > /dev/null
sed "s#{{kafka_manager_image}}#${kafka_manager_image}#g" kafka-manager.yaml > kafka-manager.yaml.tmp
kubectl delete -f kafka-manager.yaml.tmp
popd
