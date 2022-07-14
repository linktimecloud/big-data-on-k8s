set -e

WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "WORK_DIR=${WORK_DIR}"

kubectl delete configmap -l spark-role=executor
kubectl delete pods,services -l spark-role=driver
kubectl delete -f ${WORK_DIR}/kbms.yaml
helm uninstall my-spark-operator

set +e
