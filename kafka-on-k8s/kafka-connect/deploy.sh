#!/usr/bin/env bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

WORK_DIR="$BASE_DIR/kafka-connect"

source $BASE_DIR/util/check.sh
checkVar DOCKER_REGISTRY DOCKER_ORG DOCKER_TAG

echo "WORK_DIR=${WORK_DIR}"
kafka_connect_image=${DOCKER_REGISTRY}/${DOCKER_ORG}/kafka-connect:${DOCKER_TAG}-kafka-2.8.1
echo "kafka_connect image:${kafka_connect_image}"

broker_num=${BROKER_NUM:-1}
echo "kafka broker_num:${broker_num}"

set -e

kubectl wait pods -l statefulset.kubernetes.io/pod-name=kafka-cluster-strimzi-kafka-0 --for condition=Ready --timeout=90s

# deploy kafka cluster
pushd "${WORK_DIR}" > /dev/null
if [[ "${broker_num}" == "1" ]];then
  sed "s#{{kafka_connect_image}}#${kafka_connect_image}#g" kafka-connect-single.yaml > kafka-connect.yaml.tmp
else
  sed "s#{{kafka_connect_image}}#${kafka_connect_image}#g" kafka-connect.yaml > kafka-connect.yaml.tmp
fi
kubectl create -f kafka-connect.yaml.tmp
popd

set +e
