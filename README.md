# Big Data Platform on K8s
## Background
The engineering team at LinkTimeCloud has been working on migrating traditional big data platform to K8s. By expanding the existing open source projects, we have implemented a fairly stable platform that runs purely on K8s with production features such as authentication and authorization etc. In this project, we share a simple version of our implementation that allows developers to deploy an experimental platform with core components like HDFS, Hive, Spark and Kafka on K8s.

## Prerequisites
To deploy the platform, we recommend a test environment with at least 8 core CPU, 16GB RAM and 50GB disk space.
The following softwares are required: [helm](https://helm.sh/docs/intro/install/), [docker](https://www.docker.com/get-started/), and [kubectl](https://kubernetes.io/docs/tasks/tools/). To run a K8s cluster, we recommend to try [k3d](https://github.com/k3d-io/k3d)（only supports single node cluster）or [kind](https://kind.sigs.k8s.io/)（supports multiple nodes cluster）. To manage K8s clusters, we recommend to use [Lens](https://k8slens.dev/).

The following packages were tested on Macbook Pro:<br>
Helm: v3.9.0<br>
Docker Engine: 20.10.16<br>
kind: v0.14.0<br>
k3d: v5.4.3<br>
kubectl: v1.24.0<br>
Kubernetes: v1.24<p>

#### 1. Download and install Docker Desktop (Mac with M1 chip choose "Mac with Apple chip"):<br>
https://docs.docker.com/desktop/mac/install/<br>
#### 2. Install brew:<br>
https://docs.brew.sh/Installation
#### 3. Install helm:<br>
```
brew install helm
```
#### 4. Install kubectl:<br>
```
brew install kubectl
```
#### 5. Install k3d or kind:<br>
```
brew install k3d
```
or
```
brew install kind
```
#### 6. Create a K8s cluster:<br>
```
k3d cluster create single-node
```
or
```
kind create cluster --name multi-nodes
```
#### 7. Delete K8s cluster after the experiment:<br>
```
k3d cluster delete single-node
```
or
```
kind delete cluster --name multi-nodes
```

## Testing environment
We use a Macbook Pro for the experiment and allocate 5 core CPU and 8GB RAM to Docker Desktop. We run the following steps on a K8s cluster that is created by using k3d. Due to the limited resource, we can only run either a platform with MySQL+HDFS+Hive+Spark or a platform with MySQL+Kafka. If you have enough resource, you can install all of them.

## Deploy a platform with HDFS, Hive, and Spark
### 1. Start MySQL(about 2 mins)
```
bash mysql-on-k8s/deploy.sh
```

### 2. Start HDFS(about 6 mins)
```
bash hdfs-on-k8s/deploy.sh
```
To verify HDFS is started, we run a port forwarding command：
```
kubectl port-forward my-hdfs-namenode-0 50070:9870
```
Then open a browser with the following url:<br>
http://127.0.0.1:50070/dfshealth.html#tab-datanode<br>
We should see that all the datanodes are running normally.
<br><br>
To run HDFS with HA, we have to make the following changes in hdfs-on-k8s/charts/hdfs-k8s/values.yaml before we execute deploy.sh:
```
global:
  namenodeHAEnabled: true

tags:
  ha: true
  kerberos: false
  simple: false
```

### 3. Start Hive(about 18 mins)
```
bash hive-on-k8s/deploy.sh
```
To verify Hive is started，we get into the shell of pod linktime-hms-0:
```
kubectl exec --stdin --tty linktime-hms-0 -- /bin/bash
```
Then start a beeline client：
```
/opt/hive/bin/beeline -u 'jdbc:hive2://linktime-hs2-0.linktime-hs2.default.svc.cluster.local:10000/;'
```
In beeline cliet, we run the following statements:
```
create table if not exists student(id int, name string) partitioned by(month string, day string);

set hive.spark.client.server.connect.timeout=270000ms;

insert into table student partition(month="202003", day="13")
values (1, "student1"), (2, "student2"), (3, "student3"), (4, "student4"), (5, "student5");

select * from student;
```
If everything is ok, we should see the data after running the last statement. To exit from beeline, we type "!q". Finally, we exit the shell by typing "exit".

#### Trouble Shooting for Step 3
##### If there is a timeout error for the insert statement in beeline
When this happens, it usually means spark driver and executor pods cannot start due to limited resource. You can retry the insert statement.

### 4. Start Spark operator(about 3 mins)
```
bash spark-on-k8s/deploy.sh
```
To verify that Spark Operator is  working properly, we first copy two files tp the pod linktime-hms-0:
```
kubectl cp spark-on-k8s/demo.py  linktime-hms-0:/hms/.
kubectl cp spark-on-k8s/spark-submit.sh  linktime-hms-0:/hms/.
```
Then we get into the shell of pod linktime-hms-0:
```
kubectl exec --stdin --tty linktime-hms-0 -- /bin/bash
```
Run the following commands in the shell:
```
/opt/hadoop/bin/hdfs dfs -mkdir /upload
/opt/hadoop/bin/hdfs dfs -put demo.py /upload/.
bash spark-submit.sh
```
To see if a Spark application is started, we first find its pod name：
```
kubectl get pods | grep spark-schedule-driver
```
If this pod is running, then we do a port forwarding on it:
```
kubectl port-forward sparkapplication-xxxxxx-spark-schedule-driver 54040:4040
```
After port-forwarding, we open a browser with the following url to check the status of this Spark application: http://localhost:54040.

#### Trouble Shooting for Step 4
##### If we did not see driver and executor pods after running spark-submit.sh script
When this happens, it usually means spark driver and executor pods cannot start due to limited resource. You can retry the spark-submit.sh script.
### 5. Cleanup
```
bash spark-on-k8s/undeploy.sh
bash hive-on-k8s/undeploy.sh
bash hdfs-on-k8s/undeploy.sh
bash mysql-on-k8s/undeploy.sh
```
If you want to cleanup PVC and PV(not necessary), run:
```
kubectl delete pvc metadatadir-my-hdfs-namenode-0
kubectl delete pvc hdfs-data-0-my-hdfs-datanode-0
kubectl delete pvc mysql-storage-mysql-0
```
If you are running with n (n>1) datanodes and want to cleanup PVCs, run the following by replacing x from 1 to n:
```
kubectl delete pvc hdfs-data-0-my-hdfs-datanode-x
```
If you run HDFS with HA and want to cleanup all PVCs, run:
```
kubectl delete pvc data-my-hdfs-zookeeper-0
kubectl delete pvc data-my-hdfs-zookeeper-1
kubectl delete pvc data-my-hdfs-zookeeper-2
kubectl delete pvc editdir-my-hdfs-journalnode-0
kubectl delete pvc editdir-my-hdfs-journalnode-1
kubectl delete pvc editdir-my-hdfs-journalnode-2
kubectl delete pvc metadatadir-my-hdfs-namenode-1
```

## Deploy a Kafka cluster on K8s
### 1. Setup environment variables
```
source kafka-on-k8s/setup-env.sh
```
### 2. Start MySQL(about 2 mins)
```
bash mysql-on-k8s/deploy.sh
```
### 3. Start Kafka Operator(about 3 mins)
```
bash kafka-on-k8s/kafka-operator/deploy.sh
```
### 4. Start Kafka Cluster(about 10 mins)
```
bash kafka-on-k8s/kafka-cluster/deploy.sh
```
### 5. Start Schema Registry(about 4 mins)
```
bash kafka-on-k8s/schema-registry/deploy.sh
```
### 6. Start Kafka Connect(about 2 mins)
```
bash kafka-on-k8s/kafka-connect/deploy.sh
```
### 7. Start AKHQ Kafka manager(about 2 mins)
```
bash kafka-on-k8s/kafka-manager/deploy.sh
```
### 8. Verify that Kafka Cluster is running
We first find the pod name for kafka-manager:
```
kubectl get pods | grep kafka-manager
```
Run a pod forwarding command on that pod:
```
kubectl port-forward kafka-manager-pod-name 50060:9060
```
Then open a browser with the following url:
```
http://127.0.0.1:50060/api/oidc?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJ1c2VyIjp7ImlzQWRtaW4iOnRydWUsIm5hbWUiOiJkY29zIiwiZW1haWwiOiJoYWtlZWRyYUBxcS5jb20iLCJ1c2VyTmFtZSI6ImRjb3MiLCJ1aWQiOiIwNDhmZjc3MC1lMTcxLTExZWItOTA5OC01OTdhYzdjMzY3YWYiLCJncm91cHMiOlsia2Fma2EiLCJhZG1pbiIsInVzZXIiXX0sImJkb3NEb21haW4iOiJodHRwOi8vMTkyLjE2OC4xMDAuMTU4OjMwMDAiLCJhdXRoVHlwZSI6Im9wZW5pZCJ9.po2xh-d6oe8sW4A-TLshI61CJYi2aGy_yUmfBX7knWkyY3hrj0RoXV1PYTVSFlGBeTrNrnWa6s9fdrUrSXC9nA
```
After opening the UI of Kafka Manager, we enter the following information, then click "Submit":<br>
Cluster name：test<br>
Cluster address：<br>
```
kafka-cluster-strimzi-kafka-0.kafka-cluster-strimzi-kafka-brokers.default.svc.cluster.local:9092
```
Security Configuration:(skip)<br>
SchemaRegistry:<br>
```
{"url":"http://schema-registry-cluster-svc:8085"}
```
Connects:<br>
```
{"connectArray":[{"name":"kafka-connect","url":"http://my-connect-cluster-connect-api:8083"}]}
```
If everything is ok, we should be able to manage the Kafka cluster via Kafka Manager.

### 9. Cleanup
```
bash kafka-on-k8s/undeploy.sh
bash mysql-on-k8s/undeploy.sh
```
If you want to cleanup PVC and PV(not necessary), run:
```
kubectl delete pvc mysql-storage-mysql-0
kubectl delete pvc data-kafka-cluster-strimzi-zookeeper-0
kubectl delete pvc data-kafka-cluster-strimzi-kafka-0
```
