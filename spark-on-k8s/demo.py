# --coding=utf-8--

from pyspark.sql import SparkSession
from pyspark.sql import Row
import sys, time, datetime


def run():
    _APP_NAME = "ReadWriteHiveTableDemo"
    #USER_HIVE_DB = {{}}
    USER_HIVE_DB = "default"

    table = "{}.spark_read_write_demo".format(USER_HIVE_DB)

    spark = SparkSession.builder.enableHiveSupport().appName(_APP_NAME).getOrCreate()
    sc = spark.sparkContext

    data = []
    for i in range(5):
        id = i
        name = '{}_{}'.format('name',i)
        data.append("{}\t{}".format(id, name))
    tfile = sc.parallelize(data)
    rdd = tfile.map(lambda line: line.split('\t')).filter(lambda line: len(line) == 2)

    c = rdd.collect()
    print(c)

    rdd.map(lambda x: Row(x[0], x[1]))
    rdd.toDF().registerTempTable("tempTable")
    show_database = "show databases"
    spark.sql(show_database).show()

    create_table = "CREATE TABLE IF not EXISTS {}(id string, name string) partitioned by (year string, month string, day string, hour string)".format(
        table)
    spark.sql(create_table)

    date = datetime.date(2022, 6, 2)

    year, month, day = str(date).split("-")
    hour = 10
    local_time = time.localtime(time.time())
    if year is None:
        year = time.strftime('%Y', local_time)
    if month is None:
        month = time.strftime('%m', local_time)
    if day is None:
        day = time.strftime('%d', local_time)
    if hour is None:
        hour = time.strftime('%H', local_time)
    insert_table = "insert into {} partition(year='{}', month='{}', day='{}', hour='{}') select * from tempTable".format(
        table, year, month, day, hour)
    spark.sql(insert_table)

    show_partitions = "show partitions {}".format(table)
    spark.sql(show_partitions).show()

    select_sql = "select * from {}".format(table)
    spark.sql(select_sql).show()

    spark.stop()


if __name__ == "__main__":
    run()
