# Flink Performance Tuning


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

#### 读取运行参数

使用 `parameterTool.get("host")` 替换 `args[0]`

传参时使用 `--host hadoop102 --poart 9999`

#### 读取系统属性

#### 读取配置文件

`parameterTool.fromPropertiesFile("/application.properties")`

#### 配置全局参数

### 压测方式

先在 kafka 中积压数据，之后开启 Flink 任务，出现反压，就是处理瓶颈。

## 反压处理

### 反压现象及定位

#### 反压现象

kafka 反压：

1. 逐级传递；
2. transform 的 compute 端有读缓存和写缓存，缓存满了向上级拉取数据的延迟增大；比如上级是 source 端；
3. source 端同理，向 kafka 客户端服务端拉取数据延迟增大；
4. 会造成 kafka 数据延迟，有可能造成机器内存溢出。

spark 反压

1. spark 开启反压一定是基于 receiver 模式。

2. executor -> executor -> executor... 

   与 kafka 不同 executor 出现数据反压不会逐级向上游传递，会直接通信 Driver，Driver 会直接通信最上级 executor 放慢速度。

{{< admonition tip>}}

逐级更好：

1. 设置了缓存就是为了处理这种情况
2. 直接通信 Driver，会影响整体的进程，不方便确定问题。

{{< /admonition >}}

#### 利用 Flink Web UI 定位

#### 利用 Metrics 监控工具定位反压位置

反压时，观察到 `遇到瓶颈的该 Task 的 inPoolUage 为 1`

### 反压的原因及处理

#### 系统资源

1. 内存和CPU资源。一般情况 本都磁盘及网卡资源不会是瓶颈。如果某些资源被充分利用或大量使用，可以借助分析工具分析性能瓶颈（JVM Profiler + FlameGraph 生成火焰图）

   **火焰图表示了 CPU 执行各个功能的时间，从下自上展示了方法的调用关系，尖顶通常表示执行正常，平顶表示运行时间过长，通常为瓶颈。**

2. 针对特定的资源调优 Flink

3. 减少瓶颈算子上游的并行度，从而减少瓶颈算子接受的数据量（可能会造成 Job 数据延迟增大）

#### 垃圾回收GC

1. 运行时打开参数 printGCDetails
2. 下载 GC 日志：因为是 on yarn 模式，一个一个节点看日志比较麻烦，可以打开 WebUI，在 JobManager 或 TaskManager，下载 Stdout
3. 使用 GCviewer 分析数据：最重要的指标是 **Funll GC 后，老年代剩余大小** 这个指标，按照 *Java 性能优化权威指南*  这本书 Java 堆大小计算法则，设 Full GC 后老年代剩余大小空间为 M，那么堆的大小建议设置为 3 ~ 4倍 M，新生代为 1 ~ 1.5 倍 M，老年代为 2 ~ 3倍 M。

#### CPU/线程瓶颈 & 线程竞争

（还是资源问题，使用压测保证资源合理）。 subtask 可能会因为共享资源上高负载线程的竞争成为瓶颈。同样可以考虑上述分析工具。考虑在代码中查找同步开销、锁竞争、尽管避免在代码中添加同步。

#### 负载不平衡

属于数据倾斜问题

#### 外部依赖

source 端读取性能比较低或者 Sink 端性能较差，需要检查第三方组件是否遇到瓶颈。如：

1. kafka集群是否需要扩容，kafka 连接器是否并行度较低；
2. HBASE 的 rowkey 是否遇到热点问题。
3. 需要结合具体组件来分析

解决方案：`旁路缓存 + 异步IO`

## 数据倾斜

### 判断是否存在数据倾斜

通过 Flink Web UI 可以精确的看到每个 subtask 处理了多少数据，即可以判断出 Flink 任务是否存在数据倾斜。通常数据倾斜也会引起反压。

### 数据倾斜的解决

#### keyBy 前发生数据倾斜

上游算子的某些实例可能处理的数据较多，某些实例可能处理的数据较少，产生改情况可能是因为数据源本身就不均匀，例如由于某些原因 Kafka 的 topic 中某些 partition 的数据量较大，对于不存在 keyby 的 Flink 任务也会出现该情况。

解决方案：需要让 Flink 任务强制进行 shuffle。使用 shuffle、**rebalance**（reb的轮询比shuffle的随机更好，rescale是范围轮询）  或 rescale 算子即可将数据均匀分配，从而解决数据倾斜的问题。

#### keyBy 后发生数据倾斜

{{< admonition tip 扩展>}}

Hive、mr、spark 都有可能 keyby 数据倾斜的通用方法：

1. 双重聚合，如 a 开头的数据有10万条，把 a 数据用 hash 打散，a_0 ~ a_9，每个数据 1 万条；第二次把后缀去掉，把 a 的十条数据再做一次累加得到结果。
2. Flink 直接聚合，不用开窗用不了。因为流处理还是一条条写数据，没有解决数据数量问题，下游去掉随机数重新 keyby 还是 a 数据还是到一起了，仍然有可能数据倾斜 + 重复数据问题导致结果不对，由于流处理，keyby 本身是 1+1+1+1，流处理变成了1+2+3+4。当然使用开窗可以规避，但开窗还会数据倾斜。

{{< /admonition >}}

使用 **LocalKeyBy 的思想**：定义状态，积攒批次的处理。类似 MapReduce 中 Combiner 的思想。

在本地定义状态，使用定时器或者设置数量到达多少的时候，map 端的数据进行一个累加经过 keyby 再到 reduce 端。

#### keyBy 后的窗口聚合操作存在数据倾斜

窗口就是批处理，窗口只输出一次结果。

但是两个窗口也会出现 4+4 变成 4+8 的现象。（将多个窗口的数据放在一起）（第一个窗口 4 个 a，最终窗口keyby后输出 [a, 4]，第二个窗口又来 4 个 a，去掉随机数后由于都是 a，第二窗口的 [a, 4] 就会和第一个窗口的 [a, 4] sum 操作 变成 [a, 8]，第一个窗口和第二个窗口累加就会出现 [a, 12] 这个错误结果）

解决方法：带上窗口信息进行聚合。

实现思路：

1. key 拼接随机数前缀或后缀，进行 keyby 、开窗、聚合；

   **注意：** 聚合完不再是 windowedStream，要获取 windowEnd 作为窗口标记作为第二阶段分组依据，避免不同窗口的结果聚合到一起。

2. 去掉随机数前缀或后缀，按照原来的 key 及 windowEnd 作为 keyby、聚合。

## KafkaSource 调优

### 动态发现分区

### 从 kafka 数据源生成 watermark

kafka 单分区内有序，多分区无序，这种情况下，由于网络延迟等因素造成数据无序、错乱等隐患。

使用 flink 中可识别 kafka分区的 watermark 生成机制。将在 kafka 消费端内部针对每个 kafka 分区生成 watermark，且不同分区 watermark  的合并方式与在数据流 shuffle 时的合并方式相同。

### 设置空闲等待

如果数据源中的某一分区/分片在一段时间内未发送事件数据，则以为着 watermarkGenerator 也不会过得任何新数据去生成 watermark。该分区watermark 一直为 long 的最小值 minValue。比如在 kafka 的 topic 中，个别 partition 一直没有新的数据。

由于下游算子 watermark 的计算方式是取所有不同的上游并行数据源 watermark 的最小值，则导致窗口、定时器不会被触发。

可以使用 watermarkStrategy 来检测空闲输入并将其标记为空闲状态。

`.withIdleness(Duration.ofMinutes(5))`

### kafka 的 offset 消费策略

1. 默认消费策略：读取上次的 offset 信息，第一次读会根据 auto.offset.reset 的值来进行消费数据
2. 从最早的数据开始进行消费，忽略存储 offset 信息；
3. 从最新的数据信息消费，忽略存储 offset 信息；
4. 从指定位置开始消费；

