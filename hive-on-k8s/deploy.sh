set -e

READY_STR=$(kubectl get pods|grep datanode |head -n 1|awk '{print $2}')
while [ -z "${READY_STR}" ]; do
  echo "waiting for HDFS to create"
  sleep 5
  READY_STR=$(kubectl get pods|grep datanode |head -n 1|awk '{print $2}')
done

arr=(${READY_STR//\// })
while [ "${arr[0]}" != "${arr[1]}" ]; do
  echo "waiting for HDFS to start"
  sleep 5
  READY_STR=$(kubectl get pods|grep datanode |head -n 1|awk '{print $2}')
  arr=(${READY_STR//\// })
done


WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "WORK_DIR=${WORK_DIR}"

kubectl apply -f ${WORK_DIR}/hive-cluster.yaml

set +e
