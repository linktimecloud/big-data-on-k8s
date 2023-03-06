# Spark on K8s
We tailored Kubernetes Operator for Apache Spark to make simplier deployment in this project. For the complete deployment, please refer to:<p>
https://github.com/GoogleCloudPlatform/spark-on-k8s-operator

## Install spark operator

```shell
bash install.sh
```

## Install kbms service

```shell
kubectl apply -f kbms.yaml
```

## Test Spark
copy demo.py and spark-submit.sh into linktime-hms-0 pod,
```
kubectl cp spark-on-k8s/demo.py  linktime-hms-0:/hms/.
kubectl cp spark-on-k8s/spark-submit.sh  linktime-hms-0:/hms/.
```
execute the following commands in linktime-hms-0 pod,
```
/opt/hadoop/bin/hdfs dfs -mkdir /upload
/opt/hadoop/bin/hdfs dfs -put /hms/demo.py /upload/.

```

## Uninstall
kubectl delete -f kbms.yaml
helm uninstall my-release
