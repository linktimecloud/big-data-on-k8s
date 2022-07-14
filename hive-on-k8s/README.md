#安装步骤

## 依赖环境
1、Kind
2、Hdfs

## Kind 安装



## Hdfs local 安装

```shell
helm dependency build charts/hdfs-k8s
helm install my-hdfs charts/hdfs-k8s \
    --set global.kerberosEnabled=false \
    --set tags.kerberos=false \
    --set hdfs-namenode-k8s.hostNetworkEnabled=false \
    --set hdfs-namenode-k8s.persistence.size=10Gi \
    --set global.namenodeHAEnabled=false
```

## Hive 安装

```shell
kubectl apply -f hive-cluster.yaml
```


## Hive 卸载

```shell
kubectl delete -f hive-cluster.yaml
kubectl delete pod -l spark-role=driver
```

## 使用

### beeline 直接连接 HS2

```shell
/opt/hive/bin/beeline -u 'jdbc:hive2://linktime-hs2-0.linktime-hs2.default.svc.cluster.local:10000/;'
```
### 在beeline中修改启动Spark的延迟等待时间
set hive.spark.client.server.connect.timeout=270000ms;
