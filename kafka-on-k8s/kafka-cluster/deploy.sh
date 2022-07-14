#!/usr/bin/env bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
WORK_DIR="$BASE_DIR/kafka-cluster"

source $BASE_DIR/util/check.sh
checkVar DOCKER_REGISTRY DOCKER_ORG DOCKER_TAG

echo "WORK_DIR=${WORK_DIR}"

kafka_image=${DOCKER_REGISTRY}/${DOCKER_ORG}/kafka:${DOCKER_TAG}-kafka-2.8.1
echo "kafka image:${kafka_image}"
# waiting for strimzi operator startup

broker_num=${BROKER_NUM:-1}
echo "kafka broker_num:${broker_num}"

READY_STR=$(kubectl get pods|grep strimzi-cluster-operator|head -n 1|awk '{print $2}')
while [ -z "${READY_STR}" ]; do
  echo "waiting for operator to create"
  sleep 5
  READY_STR=$(kubectl get pods|grep strimzi-cluster-operator|head -n 1|awk '{print $2}')
done

arr=(${READY_STR//\// })
while [ "${arr[0]}" != "${arr[1]}" ]; do
  echo "waiting for operator to start"
  sleep 5
  READY_STR=$(kubectl get pods|grep strimzi-cluster-operator|head -n 1|awk '{print $2}')
  arr=(${READY_STR//\// })
done

pushd "${WORK_DIR}" > /dev/null

set -e
if [[ "${broker_num}" == "1" ]];then
  sed "s#{{kafka_image}}#${kafka_image}#g" kafka-cluster-single.yaml > kafka-cluster.yaml.tmp
else
  sed "s#{{kafka_image}}#${kafka_image}#g" kafka-cluster.yaml > kafka-cluster.yaml.tmp
fi
kubectl create -f kafka-cluster.yaml.tmp
set +e

popd
