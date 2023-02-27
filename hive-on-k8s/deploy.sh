set -e

check_app() {
  kubectl wait pods -l app=$1 --for condition=Ready --timeout=90s
}

check_app mysql
check_app hdfs-datanode

WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "WORK_DIR=${WORK_DIR}"

kubectl apply -f ${WORK_DIR}/hive-cluster.yaml

set +e
