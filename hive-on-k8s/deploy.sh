set -e

check_app() {
  READY_STR=$(kubectl get pods|grep $1 |head -n 1|awk '{print $2}')
  while [ -z "${READY_STR}" ]; do
    echo "waiting for $1 to create"
    sleep 5
    READY_STR=$(kubectl get pods|grep $1 |head -n 1|awk '{print $2}')
  done

  arr=(${READY_STR//\// })
  while [ "${arr[0]}" != "${arr[1]}" ]; do
    echo "waiting for $1 to start"
    sleep 5
    READY_STR=$(kubectl get pods|grep $1 |head -n 1|awk '{print $2}')
    arr=(${READY_STR//\// })
  done
}

check_app mysql
check_app datanode

WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "WORK_DIR=${WORK_DIR}"

kubectl apply -f ${WORK_DIR}/hive-cluster.yaml

set +e
