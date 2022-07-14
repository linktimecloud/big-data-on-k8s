# Kafka manager

replace 127.0.0.1:9060 to proxy url generating by lens

## docker image build

jwt secret: AUTHORIZATION_KEY
payload:
```json
{
  "user": {
    "isAdmin": true,
    "name": "dcos",
    "email": "hakeedra@qq.com",
    "userName": "dcos",
    "uid": "048ff770-e171-11eb-9098-597ac7c367af",
    "groups": [
      "admin"
    ]
  },
  "authType": "openid"
}
```

## must login, please replace the address:127.0.0.1:xxx to the kafka-manager real address

```shell
http://127.0.0.1:xxx/api/oidc?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJ1c2VyIjp7ImlzQWRtaW4iOnRydWUsIm5hbWUiOiJkY29zIiwiZW1haWwiOiJoYWtlZWRyYUBxcS5jb20iLCJ1c2VyTmFtZSI6ImRjb3MiLCJ1aWQiOiIwNDhmZjc3MC1lMTcxLTExZWItOTA5OC01OTdhYzdjMzY3YWYiLCJncm91cHMiOlsia2Fma2EiLCJhZG1pbiIsInVzZXIiXX0sImJkb3NEb21haW4iOiJodHRwOi8vMTkyLjE2OC4xMDAuMTU4OjMwMDAiLCJhdXRoVHlwZSI6Im9wZW5pZCJ9.po2xh-d6oe8sW4A-TLshI61CJYi2aGy_yUmfBX7knWkyY3hrj0RoXV1PYTVSFlGBeTrNrnWa6s9fdrUrSXC9nA
```



## add cluster

```shell
集群名称:local-test
集群地址:kafka-cluster-strimzi-kafka-0.kafka-cluster-strimzi-kafka-brokers.default.svc.cluster.local:9092
安全配置:{}
SchemaRegistry: {"url":"http://schema-registry-cluster-svc:8085"}
Connects": {"connectArray":[{"name":"kafka-connect","url":"http://my-connect-cluster-connect-api:8083"}]}
```
