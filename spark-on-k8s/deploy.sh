set -e

check_app() {
  kubectl wait pods -l app=$1 --for condition=Ready --timeout=90s
}

check_app linktime-hs2

WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "WORK_DIR=${WORK_DIR}"

helm install -f ${WORK_DIR}/operator/charts/spark-operator-chart/values.yaml my-spark-operator \
  -n default ${WORK_DIR}/operator/charts/spark-operator-chart/ --set localmode.enable=true

kubectl apply -f ${WORK_DIR}/kbms.yaml

check_app k8s-bigdata-manage-server

set +e
