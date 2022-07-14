curl --location --request POST 'http://k8s-bigdata-manage-server-svc.default.svc.cluster.local:8400/sokos/v1/jobs' \
--header 'Content-Type: application/json' \
--data-raw '{
    "executorMemory": "1g",
    "executorCores": 1,
    "numExecutors": 1,
    "driverMemory": "1g",
    "driverCores": 1.0,
    "name": "spark-schedule",
    "file": "hdfs:///upload/demo.py",
    "owner": "root",
    "ownerid": 2024,
    "namespace": "default",
    "conf": {
        "spark.eventLog.dir": "hdfs:///tmp/spark/historyservice"

    },
    "args": [
    ],
    "pyFiles": [],
    "kind": "Python"
}'
