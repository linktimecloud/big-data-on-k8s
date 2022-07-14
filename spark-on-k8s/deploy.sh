set -e

READY_STR=$(kubectl get pods|grep hs2 |head -n 1|awk '{print $2}')
while [ -z "${READY_STR}" ]; do
  echo "waiting for Hive to create"
  sleep 5
  READY_STR=$(kubectl get pods|grep hs2 |head -n 1|awk '{print $2}')
done

arr=(${READY_STR//\// })
while [ "${arr[0]}" != "${arr[1]}" ]; do
  echo "waiting for Hive to start"
  sleep 5
  READY_STR=$(kubectl get pods|grep hs2 |head -n 1|awk '{print $2}')
  arr=(${READY_STR//\// })
done


WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "WORK_DIR=${WORK_DIR}"

helm install -f ${WORK_DIR}/operator/charts/spark-operator-chart/values.yaml my-spark-operator \
  -n default ${WORK_DIR}/operator/charts/spark-operator-chart/ --set localmode.enable=true

kubectl apply -f ${WORK_DIR}/kbms.yaml

READY_STR=$(kubectl get pods|grep kbms |head -n 1|awk '{print $2}')
while [ -z "${READY_STR}" ]; do
  echo "waiting for Kafka Manager to create"
  sleep 5
  READY_STR=$(kubectl get pods|grep kbms |head -n 1|awk '{print $2}')
done

arr=(${READY_STR//\// })
while [ "${arr[0]}" != "${arr[1]}" ]; do
  echo "waiting for Kafka Manager to start"
  sleep 5
  READY_STR=$(kubectl get pods|grep kbms |head -n 1|awk '{print $2}')
  arr=(${READY_STR//\// })
done

set +e
