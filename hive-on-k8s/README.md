# Steps for deployment

## Install Hive 

```shell
kubectl apply -f hive-cluster.yaml
```


## Uninstall Hive

```shell
kubectl delete -f hive-cluster.yaml
kubectl delete pod -l spark-role=driver
```

## Test Hive

### Using beeline client

```shell
/opt/hive/bin/beeline -u 'jdbc:hive2://linktime-hs2-0.linktime-hs2.default.svc.cluster.local:10000/;'
```
### Increase the connection timeout for beeline client
set hive.spark.client.server.connect.timeout=270000ms;
