# HDFS on K8s
We tailored kubernetes-HDFS project to make simplier deployment in this project. For the complete deployment, please refer to:<p>
https://github.com/apache-spark-on-k8s/kubernetes-HDFS


# Build the dependency for helm chart
rm charts/hdfs-k8s/requirements.lock
helm dependency build charts/hdfs-k8s

# Install a simple HDFS cluster
helm install my-hdfs charts/hdfs-k8s  --set hdfs-namenode-k8s.hostNetworkEnabled=false     --set hdfs-namenode-k8s.persistence.size=10Gi


# Uninstall the HDFS cluster
helm uninstall my-hdfs
kubectl delete pvc metadatadir-my-hdfs-namenode-0
