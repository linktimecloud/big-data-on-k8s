set -e

WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "WORK_DIR=${WORK_DIR}"

rm -rf ${WORK_DIR}/charts/hdfs-k8s/requirements.lock
rm -rf ${WORK_DIR}/charts/hdfs-k8s/charts
helm dependency build ${WORK_DIR}/charts/hdfs-k8s
helm install my-hdfs ${WORK_DIR}/charts/hdfs-k8s

set +e
