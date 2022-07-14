#!/usr/bin/env bash

WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


echo "WORK_DIR=${WORK_DIR}"

# undeploy kafka-connect
pushd "${WORK_DIR}/kafka-connect/" > /dev/null
bash undeploy.sh
popd

# undeploy schema-registry
pushd "${WORK_DIR}/schema-registry/" > /dev/null
bash undeploy.sh
popd

# undeploy kafka cluster
pushd "${WORK_DIR}/kafka-cluster/" > /dev/null
bash undeploy.sh
popd

# undeploy strimzi operator
pushd "${WORK_DIR}/kafka-operator/" > /dev/null
bash undeploy.sh
popd

# undeploy kafka manager
pushd "${WORK_DIR}/kafka-manager/" > /dev/null
bash undeploy.sh
popd

# delete pvc of kafka and zookeeper
#kubectl delete pvc -l app.kubernetes.io/managed-by=strimzi-cluster-operator
unset DOCKER_REGISTRY
unset DOCKER_ORG
unset DOCKER_TAG
