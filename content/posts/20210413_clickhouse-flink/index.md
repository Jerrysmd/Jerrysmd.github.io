---
title: "Data Warehouse: ClickHouse With Flink"
# subtitle: ""
date: 2021-04-13T17:55:21+08:00
# lastmod: 2022-07-18T17:55:21+08:00
draft: false
# author: ""
# authorLink: ""
# description: ""
# license: ""
# images: []

tags: ["DataWarehouse", "ClickHouse"]
categories: ["Technology"]

# featuredImage: ""
# featuredImagePreview: ""

hiddenFromHomePage: false
hiddenFromSearch: false
# twemoji: false
# lightgallery: true
# ruby: true
# fraction: true
# fontawesome: true
# linkToMarkdown: true
# rssFullText: false

# toc:
#   enable: true
#   auto: true
# code:
#   copy: true
#   maxShownLines: 50
# math:
#   enable: false
#   # ...
# mapbox:
#   # ...
# share:
#   enable: true
#   # ...
# comment:
#   enable: true
#   # ...
# library:
#   css:
#     # someCSS = "some.css"
#     # located in "assets/"
#     # Or
#     # someCSS = "https://cdn.example.com/some.css"
#   js:
#     # someJS = "some.js"
#     # located in "assets/"
#     # Or
#     # someJS = "https://cdn.example.com/some.js"
# seo:
#   images: []
#   # ...
---

There are systems that can store values of different columns separately, but that can’t effectively process analytical queries due to their optimization for other scenarios. Examples are HBase and BigTable. You would get throughput around a hundred thousand rows per second in these systems, but not hundreds of millions of rows per second.

<!--more-->

## MergeTree 选型

### ReplacingMergeTree

在 MergeTree 的基础上，添加了 “处理重复数据” 的功能，该引擎和 MergeTree 的不同之处在于它会删除具有相同主键的重复项。使用 `order by` 使用的字段来规定去重字段。

### SummingMergeTree

在 MergeTree 的基础上，添加了 “合并重复数据” 的功能，会把具有相同主键的行合并为一行，该行包含了被合并的行中具有数值数据类型的列的汇总值。

### 选型

{{< admonition info ReplacingMergeTree>}}

+ 使用 SummingMergeTree 不能保证数据准确性，如中断重启数据会重新进来合并。
+ 解决数据合并的方式有很多。

{{< /admonition>}}

## Flink JDBC  CH

业务：

```java
result.addSink(JdbcSink.sink());
//question: Phoenix 也是 JDBC，为什么没有用 JdbcSink?
//          因为之前访问 Hbase 的表都不一样，表字段也不一样。( phoenix 可以用 自定义的 MySQLSink 或 JDBC)
//          CH 数据来源唯一

//使用工具类
result.addSink(ClickHouseUtil.getSink("insert into line(?, ?, ?)"))
```

工具类：

```java
public class ClickHouseUtil{
    public static <T> SinkFunction<T> getSink()String sql{
        return JdbcSink.<T>sink(sql,
                               new JdbcStatementBuilder<T>(){
                                   @Override
                                   public void accept(PreparedStatement preparedStatement, T t) throws SQLException{
                                       //获取所有属性信息
                                       Field[] fields = t.getClass().getDeclaredFields();
                                       for (int i = 0; i < fields.length; i++){
                                           Field field = fields[i];
                                           //反射 获取值
                                           Object value = field.get(t);
                                           //给预编译 SQL 对象赋值
                                           preparedStatement.setObject(i + 1, value);
                                       }
                                   }
                               },
                               new JdbcExecutionOptions.Builder().withBatchSize(5).build(),
                               new JdbcConnectionOptions.JdbcConnectionOptionsBuilder()
                                .withDriverName("")
                                .withUrl("")
                                .build());
    }
}
```

## Kafka2CH

Goods topic from Kafka2CH

```java
//1.get exeEnv
//2.read kafka all topic, create stream
//3.uniform all stream format
//4.union all stream
//5.get tm from data and create WaterMark
//6.group by, window, reduce. (按 id 分组，10秒滚动窗口，增量聚合(累加值)和全量聚合(提取窗口信息))
//7.join dimension info
//8.wite stream to CH
```

## Sugar 大屏展示
