# Steps for deployment

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
