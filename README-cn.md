# 在K8s上运行大数据组件
## 一、项目背景
智领云研发团队在大数据平台云原生化的开发过程中，通过对开源大数据组件的扩展和集成，实现了传统大数据平台到K8s的平稳迁移。在这个项目中，我们将HDFS、Hive、Spark operator、和Kafka Operator这些大数据组件的部署方式共享出来，开发者可以基于这个项目部署一个实验的大数据集群来体验一下云原生大数据平台。需要注意的是，本项目只能作为一个实验系统来运行，因为它不支持高可用、Kerberos安全认证、以及基于Apache Ranger的鉴权机制。关于大数据平台的云原生改造，大家可以参考我们在CSDN上发表的文章：<br>
[Spark & Hive 云原生改造在智领云的应用](https://blog.csdn.net/csdnnews/article/details/124054543)

## 二、资源配置
如果在单机上进行实验，建议至少配置8核16GB内存（空余资源），以及至少50GB空闲的硬盘空间。需要预先安装[helm](https://helm.sh/docs/intro/install/)，[docker](https://www.docker.com/get-started/), [kubectl](https://kubernetes.io/docs/tasks/tools/)和K8s。推荐使用[k3d](https://github.com/k3d-io/k3d)（只支持单节点）或者[kind](https://kind.sigs.k8s.io/)（支持多节点）来搭建K8s集群。同时，我们推荐使用[Lens](https://k8slens.dev/)来管理K8s集群。<br><br>
经过验证的软件版本<br>
Helm: v3.9.0<br>
Docker Engine: 20.10.16<br>
kind: v0.14.0<br>
k3d: v5.4.3<br>
kubectl: v1.24.0<br>
Kubernetes: v1.24<p>

软件安装步骤说明（以Mac笔记本为例）<br>
1、从以下网址下载并安装Docker（M1芯片Mac请选择Mac with Apple chip）<br>
https://docs.docker.com/desktop/mac/install/<br>
2、参照这个网页的说明安装Homebrew，并且将brew切换到国内源：<br>
https://cloud.tencent.com/developer/article/1614039<br>
3、安装Helm
```
brew install helm
```
4、安装kubectl
```
brew install kubectl
```
5、安装k3d或者kind
```
brew install k3d
```
或者
```
brew install kind
```
6、使用k3d或者kind启动K8s集群
```
k3d cluster create single-node
```
或者
```
kind create cluster --name multi-node
```
7、实验结束后销毁K8s集群
```
k3d cluster delete single-node
```
或者
```
kind delete cluster --name multi-node
```


## 三、测试环境
我们使用Mac笔记本进行了本地测试，给Docker Desktop分配了5核8GB内存资源。以下每步的执行时间都是在该环境下基于k3d测试运行的结果。测试中绝大部分的时间是花在拉取镜像的过程中。由于测试环境资源的限制，我们只能安装MySQL+HDFS+Hive+Spark集群，或者MySQL+Kafka集群。在资源充足的情况下，可以将大数据所有组件都安装上去。

## 四、在K8s上运行Hive和Spark
### 第1步：启动MySQL（大约需要2分钟）
```
bash mysql-on-k8s/deploy.sh
```

### 第2步：启动HDFS（大约需要6分钟）
```
bash hdfs-on-k8s/deploy.sh
```
为了验证hdfs的成功启动，我们先执行一个port forwarding命令：
```
kubectl port-forward my-hdfs-namenode-0 50070:9870
```
执行上述命令后，在浏览器中打开http://127.0.0.1:50070/dfshealth.html#tab-datanode，应该可以看到所有datanode都在正常运行。

### 第3步：启动Hive（大约需要18分钟）
```
bash hive-on-k8s/deploy.sh
```
为了验证Hive on K8s是否正常启动，我们先进入到linktime-hms-0的shell中：
```
kubectl exec --stdin --tty linktime-hms-0 -- /bin/bash
```
然后进入beeline的命令行：
```
/opt/hive/bin/beeline -u 'jdbc:hive2://linktime-hs2-0.linktime-hs2.default.svc.cluster.local:10000/;'
```
在beeline的命令行中按顺序执行下列3条语句，如果这些语句正常执行，则说明Hive启动正常，Spark on K8s可以运行Hive语句：
```
create table if not exists student(id int, name string) partitioned by(month string, day string);

set hive.spark.client.server.connect.timeout=270000ms;

insert into table student partition(month="202003", day="13")
values (1, "student1"), (2, "student2"), (3, "student3"), (4, "student4"), (5, "student5");

select * from student;
```
最后输入“!q”退出beeline命令行，输入“exit”退出pod的shell。以上验证步骤在单节点K8s集群环境下需要大约4分钟时间。

#### 第3步 Trouble Shooting
##### 如果运行Hive的insert语句时超时，出现timed out错误提示
出现这种情况是因为系统资源不够或者网络问题导致driver和executor pods镜像无法拉取，这时可以重新运行insert语句。

### 第4步：启动Spark operator（大约需要3分钟）
```
bash spark-on-k8s/deploy.sh
```
为了验证Spark Operator能正常执行Spark程序的执行，我们先拷贝两个文件到linktime-hms-0:

```
kubectl cp spark-on-k8s/demo.py  linktime-hms-0:/hms/.
kubectl cp spark-on-k8s/spark-submit.sh  linktime-hms-0:/hms/.
```
然后我们进入linktime-hms-0的shell中：
```
kubectl exec --stdin --tty linktime-hms-0 -- /bin/bash
```
在shell中，我们按顺序执行下列命令:
```
/opt/hadoop/bin/hdfs dfs -mkdir /upload
/opt/hadoop/bin/hdfs dfs -put demo.py /upload/.
bash spark-submit.sh
```

为了验证Spark程序的成功执行，我们先得到Spark Application的pod名称：
```
kubectl get pods | grep spark-schedule-driver
```
然后对这个pod执行一个port forwarding命令：
```
kubectl port-forward sparkapplication-xxxxxx-spark-schedule-driver 54040:4040
```
接着在浏览器中输入下列网址：http://localhost:54040 来查看Spark程序运行情况。

#### 第4步 Trouble Shooting
##### 如果运行Spark的spark-submit.sh脚本时，没有看到相关的pods在启动
出现这种情况是因为系统资源不够或者网络问题导致driver和executor pods镜像无法拉取，这时可以重新运行spark-submit.sh脚本。

### 第5步：清理安装
```
bash spark-on-k8s/undeploy.sh
bash hive-on-k8s/undeploy.sh
bash hdfs-on-k8s/undeploy.sh
bash mysql-on-k8s/undeploy.sh
```

如果需要清理PVC和PV（一般不需要），则执行：
```
kubectl delete pvc metadatadir-my-hdfs-namenode-0
kubectl delete pvc mysql-storage-mysql-0
```

## 五、在K8s上运行Kafka
### 第1步：设置环境变量
###
```
source kafka-on-k8s/setup-env.sh
```

### 第2步：启动MySQL（大约需要2分钟）
```
bash mysql-on-k8s/deploy.sh
```

### 第3步：启动Kafka Operator（大约需要3分钟）
```
bash kafka-on-k8s/kafka-operator/deploy.sh
```

### 第4步：启动Kafka Cluster（大约需要10分钟）
```
bash kafka-on-k8s/kafka-cluster/deploy.sh
```

### 第5步：启动Schema Registry（大约需要4分钟）
```
bash kafka-on-k8s/schema-registry/deploy.sh
```

### 第6步：启动Kafka Connect（大约需要2分钟）
```
bash kafka-on-k8s/kafka-connect/deploy.sh
```

### 第7步：启动AKHQ Kafka manager（大约需要2分钟）
```
bash kafka-on-k8s/kafka-manager/deploy.sh
```
### 第8步：验证Kafka集群的成功启动
为了验证Kafka集群的成功启动，我们先得到kafka-manager的pod名称：
```
kubectl get pods | grep kafka-manager
```
然后执行一个port forwarding命令：
```
kubectl port-forward kafka-manager的pod名称 50060:9060
```
接着在浏览器中输入下列网址：
```
http://127.0.0.1:50060/api/oidc?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJ1c2VyIjp7ImlzQWRtaW4iOnRydWUsIm5hbWUiOiJkY29zIiwiZW1haWwiOiJoYWtlZWRyYUBxcS5jb20iLCJ1c2VyTmFtZSI6ImRjb3MiLCJ1aWQiOiIwNDhmZjc3MC1lMTcxLTExZWItOTA5OC01OTdhYzdjMzY3YWYiLCJncm91cHMiOlsia2Fma2EiLCJhZG1pbiIsInVzZXIiXX0sImJkb3NEb21haW4iOiJodHRwOi8vMTkyLjE2OC4xMDAuMTU4OjMwMDAiLCJhdXRoVHlwZSI6Im9wZW5pZCJ9.po2xh-d6oe8sW4A-TLshI61CJYi2aGy_yUmfBX7knWkyY3hrj0RoXV1PYTVSFlGBeTrNrnWa6s9fdrUrSXC9nA
```
打开Kafka Manager的界面，我们输入下面的参数，点“Submit”后就可以看到Kafka集群的情况了：<br>
集群名称：test<br>
集群地址：<br>
```
kafka-cluster-strimzi-kafka-0.kafka-cluster-strimzi-kafka-brokers.default.svc.cluster.local:9092
```
SchemaRegistry:<br>
```
{"url":"http://schema-registry-cluster-svc:8085"}
```
Connects:<br>
```
{"connectArray":[{"name":"kafka-connect","url":"http://my-connect-cluster-connect-api:8083"}]}
```

### 第9步：清理安装
```
bash kafka-on-k8s/undeploy.sh
bash mysql-on-k8s/undeploy.sh
```
如果需要清理PVC和PV（一般不需要），则执行
```
kubectl delete pvc mysql-storage-mysql-0
kubectl delete pvc data-kafka-cluster-strimzi-zookeeper-0
kubectl delete pvc data-kafka-cluster-strimzi-kafka-0
```
