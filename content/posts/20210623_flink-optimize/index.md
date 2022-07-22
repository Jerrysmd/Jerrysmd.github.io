---
title: "Flink Optimization"
# subtitle: ""
date: 2021-06-23T10:32:19+08:00
# lastmod: 2022-07-22T10:32:19+08:00
draft: false
# author: ""
# authorLink: ""
# description: ""
# license: ""
# images: []

tags: ["DataWarehouse", "Flink"]
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
# {{< admonition tip>}}{{< /admonition >}}
---

Flink optimization includes resource configuration optimization, back pressure processing, data skew, KafkaSource optimization and FlinkSQL optimization.

<!--more-->

## 资源配置调优

### 内存设置

给任务分配资源，在一定范围内，增加资源的分配与性能的提升是正比的（部分情况如资源过大，申请资源时间很长）。

提交方式主要是 yarn-per-job，资源的分配在使用脚本提交 Flink 任务时进行指定。

目前通常使用客户端模式，参数使用 -D<property=value> 指定

```shell
bin/fink run \
-t yarn-per-job \
-d \
-p 5 \ 指定并行度
-Dyarn.application.queue=test \ 指定 yarn 队列
-Djobmanager.memory.process.size=2048mb \ jm 2-4G足够
-Dtaskmanager.memory.process.size=6144mb \ 单个 tm 2-8G 足够
-Dtaskmanager.numberOfTaskSlots=2 \ 与容器核数 1core:1slot 或 1core:2slot
```

### 并行度设置

#### 最优并行度计算

完成开发后，压测，任务并行度给 10 以下，测试单个并行度的处理上限。然后 `总 QPS / 单并行度的处理能力 = 并行度`

不能只根据 QPS 得出并行度，因为有些字段少，逻辑简单任务。最好根据高峰期的 QPS 压测，并行度 * 1.2，富余一些资源。

#### Source 端并行度的配置

数据源端是 Kafka，Source 的并行度设置为 Kafka 对应 Topic 的分区数。

如果等于 Kafka 的分区数，消费速度仍跟不上数据生产速度，需考虑 Kafka 要扩大分区，同时调大并行度等于分区数。

{{< admonition tip>}}

1. 优先加资源；
2. Kafka 的分区数增加不可逆操作，增加分区放在最后使用。

{{< /admonition >}}

#### Transform 端并行度的配置

+ keyby 之前的算子

  一般不会做太重的操作，比如是 map、filter、flatmap 等处理较快的算子，并行度可以和 source 保持一致。

+ keyby 之后的算子

  如果并行比较大，可以设置并行度为 2 的整次幂；

  小并发任务的并行度不一定需要设置成 2 的整数次幂；

  大并发如果没有 keyby，并行度也无需设置为 2 的整次幂。

#### Sink 端并行度的配置

可以根据 Sink 端的数据量及下游服务抗压能力进行评估。

**如果 Sink 端是 Kafka，可以设为 Kafka 对应 Topic 的分区数。**

另外 Sink 端要与下游的服务进行交互，要考虑延迟和压测，可以采用：

1. 控制并行度；
2. 采用批量提交的方式。公司采用 CH 采用每5条一提交，加上时间控制 (时间到了，但不足5条，也会提交) 提交的方式。

### RocksDB 大状态调优

状态客户端，Flink 提供的用于管理状态的组件，RocksDB 基于 LSM Tree 实现 (类似于 HBASE)，写数据都是先缓存到内存中，所以 RocksDB 的写请求效率比较高。

+ Memory

  本地：taskmanager内存

  远程：jm内存

+ fs

  本地：tm内存

  远程：文件系统（一般是HDFS）

+ rocksDB

  本地：当前机器的内存 + 磁盘

  远程：文件系统（HDFS）

调优：

1. 增量检查点，（独有的）
2. 设置为 机械 + 内存模式，有条件上 SSD
3. 缓存命中率，和 HBASE 一样，cache 越大，缓存命中率越高。一般设置为 64 ~ 256 MB。

### CheckPoint 设置

cp 防止数据挂掉，从 cp 恢复数据；

一般在生产环境，时间间隔设置为分钟级别；

如果访问 HDFS 比较耗时，时间间隔可以设置为 5 ~ 10 分钟； 

### Flink parameterTool 读取配置



















{{< admonition question 关于各种框架优化的回答>}}

问法：做过什么优化？ 解决过什么问题？遇到哪些问题？

1. 说明业务场景；
2. 遇到了什么问题 --> 往往通过监控工具结合报警系统；
3. 排查问题；
4. 解决手段；
5. 问题被解决。

{{< /admonition >}}
