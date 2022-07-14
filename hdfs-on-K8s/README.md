# HDFS on K8s

本代码库对kubernetes-HDFS项目做了一定程度的裁剪，提供了hdfs on K8s的简洁发布方式，更复杂的发布方式请参考：
https://github.com/apache-spark-on-k8s/kubernetes-HDFS


# 创建helm依赖
rm charts/hdfs-k8s/requirements.lock
helm dependency build charts/hdfs-k8s

# 启动非HA的HDFS集群
helm install my-hdfs charts/hdfs-k8s  --set hdfs-namenode-k8s.hostNetworkEnabled=false     --set hdfs-namenode-k8s.persistence.size=10Gi


# 清除创建的集群
helm uninstall my-hdfs
kubectl delete pvc metadatadir-my-hdfs-namenode-0
