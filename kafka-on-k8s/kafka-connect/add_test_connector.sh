#!/usr/bin/env bash

set -e
set -x

kubectl exec -i kafka-cluster-strimzi-kafka-0 -- curl -i -X PUT -H "Content-Type:application/json" \
http://my-connect-cluster-connect-api:8083/connectors/kafka_demo_cow_dsn/config \
-d '{
"connector.class":"io.debezium.connector.mysql.MySqlConnector",
"connection.password":"linktime",
"database.history.kafka.topic":"user_topic",
"database.history.consumer.security.protocol":"PLAINTEXT",
"table.whitelist":"kafka_demo.user",
"value.converter":"io.confluent.connect.avro.AvroConverter",
"database.whitelist":"kafka_demo",
"key.converter":"io.confluent.connect.avro.AvroConverter",
"database.user":"root",
"database.server.id":"116",
"database.history.producer.security.protocol":"PLAINTEXT",
"database.history.kafka.bootstrap.servers":"kafka-cluster-strimzi-kafka-0.kafka-cluster-strimzi-kafka-brokers.default.svc.cluster.local:9092",
"database.server.name":"kafka_demo_cow_dsn",
"check.mode":"strict",
"database.port":"3306",
"inconsistent.schema.handling.mode":"fail",
"key.converter.schemas.enable":"true",
"value.converter.schema.registry.url":"http://schema-registry-cluster-svc:8085",
"connection.user":"root",
"database.hostname":"mysql.default.svc.cluster.local",
"database.password":"linktime",
"value.converter.schemas.enable":"true",
"name":"kafka_demo_cow_dsn",
"connection.url":"jdbc:mysql://mysql.default.svc.cluster.local:3306/kafka_demo?useSSL=false",
"key.converter.schema.registry.url":"http://schema-registry-cluster-svc:8085",
"snapshot.mode":"schema_only",
"database.source":"64"
}'

kubectl exec -i kafka-cluster-strimzi-kafka-0 -- curl -i -X PUT -H "Content-Type:application/json" \
    http://my-connect-cluster-connect-api:8083/connectors/kafka_demo_jdbcSourceConnector_x_user/config \
    -d '{
    "connector.class":"io.confluent.connect.jdbc.JdbcSourceConnector",
    "incrementing.column.name":"id",
    "connection.password":"linktime",
    "table.whitelist":"kafka_demo.user",
    "mode":"incrementing",
    "topic.prefix":"JdbcSourceConnector_x_user",
    "connection.user":"root",
    "name":"kafka_demo_jdbcSourceConnector_x_user",
    "connection.url":"jdbc:mysql://mysql.default.svc.cluster.local:3306/kafka_demo?useSSL=false"
    }'

kubectl exec -i kafka-cluster-strimzi-kafka-0 -- curl -X GET http://my-connect-cluster-connect-api:8083/connectors