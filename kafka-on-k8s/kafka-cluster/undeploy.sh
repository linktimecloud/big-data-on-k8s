#!/usr/bin/env bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
WORK_DIR="$BASE_DIR/kafka-cluster"

source $BASE_DIR/util/check.sh
checkVar DOCKER_REGISTRY DOCKER_ORG DOCKER_TAG

echo "WORK_DIR=${WORK_DIR}"

kafka_image=${DOCKER_REGISTRY}/${DOCKER_ORG}/kafka:${DOCKER_TAG}-kafka-2.8.1
echo "kafka image:${kafka_image}"

broker_num=${BROKER_NUM:-1}
echo "kafka broker_num:${broker_num}"

# deploy kafka cluster
pushd "${WORK_DIR}" > /dev/null
if [[ "${broker_num}" == "1" ]];then
  sed "s#{{kafka_image}}#${kafka_image}#g" kafka-cluster-single.yaml > kafka-cluster.yaml.tmp
else
  sed "s#{{kafka_image}}#${kafka_image}#g" kafka-cluster.yaml > kafka-cluster.yaml.tmp
fi
kubectl delete -f kafka-cluster.yaml.tmp
popd
