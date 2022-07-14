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

POD_NAME_PREFIX=kafka-cluster-strimzi-kafka
READY_STR=$(kubectl get pods|grep ${POD_NAME_PREFIX}|head -n 1|awk '{print $2}')
while [ -z "${READY_STR}" ]; do
  echo "waiting for kafka to create"
  sleep 5
  READY_STR=$(kubectl get pods|grep ${POD_NAME_PREFIX}|head -n 1|awk '{print $2}')
done

arr=(${READY_STR//\// })
while [ "${arr[0]}" != "${arr[1]}" ]; do
  echo "waiting for kafka cluster to start"
  sleep 5
  READY_STR=$(kubectl get pods|grep ${POD_NAME_PREFIX}|head -n 1|awk '{print $2}')
  arr=(${READY_STR//\// })
done

# deploy kafka cluster
pushd "${WORK_DIR}" > /dev/null
set -e
if [[ "${broker_num}" == "1" ]];then
  sed "s#{{kafka_connect_image}}#${kafka_connect_image}#g" kafka-connect-single.yaml > kafka-connect.yaml.tmp
else
  sed "s#{{kafka_connect_image}}#${kafka_connect_image}#g" kafka-connect.yaml > kafka-connect.yaml.tmp
fi
kubectl create -f kafka-connect.yaml.tmp
set +e
popd

POD_NAME_PREFIX=my-connect-cluster-connect
READY_STR=$(kubectl get pods|grep ${POD_NAME_PREFIX}|head -n 1|awk '{print $2}')
while [ -z "${READY_STR}" ]; do
  echo "waiting for kafka connect to create"
  sleep 5
  READY_STR=$(kubectl get pods|grep ${POD_NAME_PREFIX}|head -n 1|awk '{print $2}')
done

arr=(${READY_STR//\// })
while [ "${arr[0]}" != "${arr[1]}" ]; do
  echo "waiting for kafka connect to start"
  sleep 5
  READY_STR=$(kubectl get pods|grep ${POD_NAME_PREFIX}|head -n 1|awk '{print $2}')
  arr=(${READY_STR//\// })
done
