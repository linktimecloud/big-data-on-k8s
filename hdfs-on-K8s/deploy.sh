set -e

READY_STR=$(kubectl get pods|grep mysql |head -n 1|awk '{print $2}')
while [ -z "${READY_STR}" ]; do
  echo "waiting for MySQL to create"
  sleep 5
  READY_STR=$(kubectl get pods|grep mysql |head -n 1|awk '{print $2}')
done

arr=(${READY_STR//\// })
while [ "${arr[0]}" != "${arr[1]}" ]; do
  echo "waiting for MySQL to start"
  sleep 5
  READY_STR=$(kubectl get pods|grep mysql |head -n 1|awk '{print $2}')
  arr=(${READY_STR//\// })
done

WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "WORK_DIR=${WORK_DIR}"

rm -rf ${WORK_DIR}/charts/hdfs-k8s/requirements.lock
rm -rf ${WORK_DIR}/charts/hdfs-k8s/charts
helm dependency build ${WORK_DIR}/charts/hdfs-k8s
helm install my-hdfs ${WORK_DIR}/charts/hdfs-k8s

set +e
