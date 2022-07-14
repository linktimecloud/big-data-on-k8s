# 安装步骤

## 安装spark operator

```shell
bash install.sh
```

## 安装kbms服务

```shell
kubectl apply -f kbms.yaml
```

## 测试
把demo.py和spark-submit.sh拷贝到linktime-hms-0 pod内，
```
kubectl cp spark-on-k8s/demo.py  linktime-hms-0:/hms/.
kubectl cp spark-on-k8s/spark-submit.sh  linktime-hms-0:/hms/.
```
然后进入linktime-hms-0 pod，执行
```
/opt/hadoop/bin/hdfs dfs -mkdir /upload
/opt/hadoop/bin/hdfs dfs -put /hms/demo.py /upload/.

```
该过程即是用http服务提交spark作业。


## 卸载
kubectl delete -f kbms.yaml
helm uninstall my-release
