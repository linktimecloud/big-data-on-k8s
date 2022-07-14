set -e

WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "WORK_DIR=${WORK_DIR}"

kubectl apply -f ${WORK_DIR}/mysql.yaml

set +e
