#!/usr/bin/env bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

WORK_DIR="$BASE_DIR/kafka-operator"
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"

source $BASE_DIR/util/check.sh
checkVar DOCKER_REGISTRY DOCKER_ORG DOCKER_TAG

echo "WORK_DIR=${WORK_DIR}"
echo "ROOT_DIR=${ROOT_DIR}"

# build strimzi kafka operator and deploy operator
pushd "${ROOT_DIR}" > /dev/null

if [ -d "${WORK_DIR}/cluster-operator" ];then
  # 支持单独e2e目录发布
  deployment_operator="060-Deployment-strimzi-cluster-operator.yaml"
  cluster_deployment_operator=${WORK_DIR}/cluster-operator/${deployment_operator}

  sed "s#{{DOCKER_REGISTRY}}#${DOCKER_REGISTRY}#g" ${WORK_DIR}/${deployment_operator}.template > ${cluster_deployment_operator}
  platform=`uname -s`
  if [[ "$platform" == "Darwin" ]]; then
    sed -i '' "s#{{DOCKER_ORG}}#${DOCKER_ORG}#g" ${cluster_deployment_operator}
    sed -i '' "s#{{DOCKER_TAG}}#${DOCKER_TAG}#g" ${cluster_deployment_operator}
  else
    sed -i "s#{{DOCKER_ORG}}#${DOCKER_ORG}#g" ${cluster_deployment_operator}
    sed -i "s#{{DOCKER_TAG}}#${DOCKER_TAG}#g" ${cluster_deployment_operator}
  fi
  kubectl delete -f ${WORK_DIR}/cluster-operator
else
  kubectl delete -f ${ROOT_DIR}/packaging/install/cluster-operator
fi
popd