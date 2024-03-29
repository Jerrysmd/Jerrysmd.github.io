---
title: "Kafka: A Stream Processing Platform for Distributed Applications" # Title of the blog post.
date: 2020-04-27T14:21:19+08:00 # Date of post creation.
description: "Article description." # Description used for search engine.
featured: true # Sets if post is a featured post, making appear on the home page side bar.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: true # Controls if a table of contents should be generated for first-level links automatically.
# menu: main
# featureImage: "/images/path/file.jpg" # Sets featured image on blog post.
# thumbnail: "images/data2.png" # 1-13 Sets thumbnail image appearing inside card on homepage.
# shareImage: "/images/path/share.png" # Designate a separate image for social media sharing.
codeMaxLines: 40 # Override global value for how many lines within a code block before auto-collapsing.
codeLineNumbers: true # Override global value for showing of line numbers within code block.
figurePositionShow: true # Override global value for showing the figure label.
categories:
  - Technology
tags:
  - Kafka
  - Distribution
comments: true # Disable comment if false.
---
Apache Kafka aims to provide a unified, high-throughput, low-latency platform for handling real-time data feeds. Kafka can connect to external systems (for data import/export) via Kafka Connect and provides Kafka Streams, a Java stream processing library. Kafka uses a binary TCP-based protocol that is optimized for efficiency and relies on a "message set" abstraction that naturally groups messages together to reduce the overhead of the network roundtrip. This "leads to larger network packets, larger sequential disk operations, contiguous memory blocks [...] which allows Kafka to turn a bursty stream of random message writes into linear writes."
<!--more-->

## Message queue

### 1. Why

为什么使用消息队列？

从系统之间有通信需求开始，就自然产生了消息队列。

在计算机科学中，消息队列（英语：Message queue）是一种进程间通信或同一进程的不同线程间的通信方式，软件的贮列用来处理一系列的输入，通常是来自用户。消息队列提供了异步的通信协议，每一个贮列中的纪录包含详细说明的资料，包含发生的时间，输入设备的种类，以及特定的输入参数，也就是说：消息的发送者和接收者不需要同时与消息队列交互。消息会保存在队列中，直到接收者取回它。

### 2. Feature

1. 解耦：

   允许你独立的扩展或修改两边的处理过程，只要确保它们遵守同样的接口约束。

2. 冗余：

   消息队列把数据进行持久化直到它们已经被完全处理，通过这一方式规避了数据丢失风险。许多消息队列所采用的”插入-获取-删除”范式中，在把一个消息从队列中删除之前，需要你的处理系统明确的指出该消息已经被处理完毕，从而确保你的数据被安全的保存直到你使用完毕。

3. 扩展性：

   因为消息队列解耦了你的处理过程，所以增大消息入队和处理的频率是很容易的，只要另外增加处理过程即可。

4. 灵活性 & 峰值处理能力：

   在访问量剧增的情况下，应用仍然需要继续发挥作用，但是这样的突发流量并不常见。如果为以能处理这类峰值访问为标准来投入资源随时待命无疑是巨大的浪费。使用消息队列能够使关键组件顶住突发的访问压力，而不会因为突发的超负荷的请求而完全崩溃。

5. 可恢复性：

   系统的一部分组件失效时，不会影响到整个系统。消息队列降低了进程间的耦合度，所以即使一个处理消息的进程挂掉，加入队列中的消息仍然可以在系统恢复后被处理。

6. 顺序保证：

   在大多使用场景下，数据处理的顺序都很重要。大部分消息队列本来就是排序的，并且能保证数据会按照特定的顺序来处理。（Kafka 保证一个 Partition 内的消息的有序性）

7. 缓冲：

   有助于控制和优化数据流经过系统的速度，解决生产消息和消费消息的处理速度不一致的情况。

8. 异步通信：

   很多时候，用户不想也不需要立即处理消息。消息队列提供了异步处理机制，允许用户把一个消息放入队列，但并不立即处理它。想向队列中放入多少消息就放多少，然后在需要的时候再去处理它们。

### 3. Usage

- 服务解耦：

  下游系统可能只需要当前系统的一个子集，应对不断增加变化的下游系统，当前系统不停地修改调试与这些下游系统的接口，系统间耦合过于紧密。引入消息队列后，当前系统变化时发送一条消息到消息队列的一个主题中，所有下游系统都订阅主题，这样每个下游系统都可以获得一份实时完整的订单数据。

- 异步处理：

  以秒杀为例：风险控制->库存锁定->生成订单->短信通知->更新统计数据

![kafkaAsyn](/posts/picture/kafkaAsyn.webp)

+ 限流削峰/流量控制

  一个设计健壮的程序有自我保护的能力，也就是说，它应该可以在海量的请求下，还能在自身能力范围内尽可能多地处理请求，拒绝处理不了的请求并且保证自身运行正常。使用消息队列隔离网关和后端服务，以达到流量控制和保护后端服务的目的。

### 4. Realize

+ 点对点：

  系统 A 发送的消息只能被系统 B 接收，其他任何系统都不能读取 A 发送的消息。

  日常生活的例子比如电话客服就属于这种模型：

  同一个客户呼入电话只能被一位客服人员处理，第二个客服人员不能为该客户服务。

![kafkaP2p](/posts/picture/kafkaP2p.webp)

+ 发布/订阅模型

  这个模型可能存在多个发布者向相同的主题发送消息，而订阅者也可能存在多个，它们都能接收到相同主题的消息。

  生活中的报纸订阅就是一种典型的发布 / 订阅模型。

![kafkaSub](/posts/picture/kafkaSub.webp)

## Kafka

### 1. Intro

kafka是一个分布式流处理平台。

- 类似一个消息系统，读写流式的数据
- 编写可扩展的流处理应用程序，用于实时事件响应的场景
- 安全的将流式的数据存储在一个分布式，有副本备份，容错的集群

### 2.  History

Kafka从何而来?我们为什么要开发Kafka? Kafka到底是什么?
    Kafka 最初是 LinkedIn 的一个内部基础设施系统。我们发现虽然有很多数据库和系统可以用来存储数据，但在我们的架构里，**刚好缺一个可以帮助处理持续数据流的组件**。在开发Kafka之前，我们实验了各种现成的解决方案，**从消息系统到日志聚合系统，再到ETL工具，它们都无法满足我们的需求。**
    最后，我们决定从头开发一个系统。**我们不想只是开发一个能够存储数据的系统**，比如传统的关系型数据库、键值存储引擎、搜索引擎或缓存系统，**我们希望能够把数据看成是持续变化和不断增长的流**，并基于这样的想法构建出一个数据系统。事实上，是一个数据架构。
    这个想法实现后比我们最初预想的适用性更广。Kafka 一开始被用在社交网络的实时应用和数据流当中，而现在已经成为下一代数据架构的基础。大型零售商正在基于持续数据流改造他们的基础业务流程，汽车公司正在从互联网汽车那里收集和处理实时数据流，银行也在重新思考基于 Kafka 改造他们的基础。

它可以用于两大类别的应用:

1. 构造实时流数据管道，它可以在系统或应用之间可靠地获取数据。(相当于message queue)
2. 构建实时流式应用程序，对这些流数据进行转换或者影响。(就是流处理，通过kafka stream topic和topic之间内部进行变化)

| 版本号   | 备注                                                         |
| -------- | ------------------------------------------------------------ |
| 0.7      | 上古版本，提供了最基础的消息队列功能                         |
| 0.8      | 引入了**副本机制**，成为了一个真正意义上完备的分布式高可靠消息队列解决方案 |
| 0.8.2    | **新版本 Producer API**，即需要指定 Broker 地址的 Producer   |
| 0.9      | 增加了基础的安全认证 / 权限，Java 重写了新版本消费者 API     |
| 0.10.0.0 | **引入了 Kafka Streams**                                     |
| 0.11.0.0 | 提供幂等性 Producer API 以及事务（Transaction） API，对 Kafka 消息格式做了重构。 |
| 1.0      | Kafka Streams 的各种改进                                     |
| 2.0      | Kafka Streams 的各种改进                                     |

### 3. Item

- 消息：Record。这里的消息就是指 Kafka 处理的主要对象。
- 服务：**Broker**。一个 Kafka 集群由多个 Broker 组成，Broker 负责接收和处理客户端发送过来的请求，以及对消息进行持久化。
- 主题：**Topic**。主题是承载消息的逻辑容器，在实际使用中多用来区分具体的业务。
- 分区：**Partition**。一个有序不变的消息序列。每个主题下可以有多个分区。
- 消息位移：Offset。表示分区中每条消息的位置信息，是一个单调递增且不变的值。
- 副本：Replica。Kafka 中同一条消息能够被拷贝到多个地方以提供数据冗余，这些地方就是所谓的副本。副本还分为领导者副本和追随者副本，各自有不同的角色划分。副本是在分区层级下的，即每个分区可配置多个副本实现高可用。
- 生产者：**Producer**。向主题发布新消息的应用程序。
- 消费者：**Consumer**。从主题订阅新消息的应用程序。
- 消费者位移：Consumer Offset。表征消费者消费进度，每个消费者都有自己的消费者位移。
- 消费者组：Consumer Group。多个消费者实例共同组成的一个组，同时消费多个分区以实现高吞吐。
- 重平衡：Rebalance。消费者组内某个消费者实例挂掉后，其他消费者实例自动重新分配订阅主题分区的过程。Rebalance 是 Kafka 消费者端实现高可用的重要手段。

![kafkaItem](/posts/picture/kafkaItem.png "kafkaItem")

### 4. Topic

日志

日志可能是一种最简单的不能再简单的存储抽象，只能追加、按照时间完全有序（totally-ordered）的记录序列。日志看起来的样子：

![kafkaLog](/posts/picture/kafkaLog.png "kafkaLog")

在日志的末尾添加记录，读取日志记录则从左到右。每一条记录都指定了一个唯一的顺序的日志记录编号。

日志记录的次序（ordering）定义了『时间』概念，因为位于左边的日志记录表示比右边的要早。日志记录编号可以看作是这条日志记录的『时间戳』。把次序直接看成是时间概念，刚开始你会觉得有点怪异，但是这样的做法有个便利的性质：解耦了 时间 和 任一特定的物理时钟（physical clock）。引入分布式系统后，这会成为一个必不可少的性质。

日志 和 文件或数据表（table）并没有什么大的不同。文件是一系列字节，表是由一系列记录组成，而日志实际上只是一种按照时间顺序存储记录的数据表或文件。

对于每一个topic， Kafka集群都会维持一个分区日志，如下所示：

![kafkaPartitionLog](/posts/picture/kafkaPartitionLog.png "kafkaPartitionLog")

**实操**

启动zk

```shell
cd /usr/local/kara/kafka_2.13-2.6.0/bin
zookeeper-server-start.sh ../config/zookeeper.properties
```

启动kafka服务器

```shell
kafka-server-start.sh ../config/server.properties
```

创建topic，4个分区，一个副本

```shell
kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 4 --topic partition_test
```

发送一些消息

```shell
kafka-console-producer.sh --broker-list localhost:9092 --topic partition_test
```

启动一个consumer

```shell
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic partition_test --from-beginning
```

**分区**

**partition存储分布**

一个topic下有多个不同partition，每个partition为一个目录，partiton命名规则为**topic名称+有序序号**，第一个partiton序号从0开始，序号最大值为partitions数量减1

**partition文件存储**

1.每个partion(目录)相当于一个巨型文件被平均分配到多个大小相等segment(段)数据文件中。但每个段segment file消息数量不一定相等，这种特性方便old segment file快速被删除。

2.每个partiton只需要支持顺序读写就行了，segment文件生命周期由服务端配置参数决定。

**segment文件存储**

1. segment file组成：由2大部分组成，分别为index file和data file，此2个文件一一对应，成对出现，分别表示为segment索引文件、数据文件.

2. segment文件命名规则：partion全局的第一个segment从0开始，后续每个segment文件名为上一个segment文件最后一条消息的offset值。数值最大为64位long大小，19位数字字符长度，没有数字用0填充。segment index file采取稀疏索引存储方式，它减少索引文件大小，通过mmap可以直接内存操作，稀疏索引为数据文件的每个对应message设置一个元数据指针,它比稠密索引节省了更多的存储空间，但查找起来需要消耗更多的时间。
3. segment中的消息message物理结构字段说明

| 关键字              | 解释说明                                                     |
| :------------------ | :----------------------------------------------------------- |
| 8 byte offset       | 在parition(分区)内的每条消息都有一个有序的id号，这个id号被称为偏移(offset),它可以唯一确定每条消息在parition(分区)内的位置。即offset表示partiion的第多少message |
| 4 byte message size | message大小                                                  |
| 4 byte CRC32        | 用crc32校验message                                           |
| 1 byte “magic”      | 表示本次发布Kafka服务程序协议版本号                          |
| 1 byte “attributes” | 表示为独立版本、或标识压缩类型、或编码类型。                 |
| 4 byte key length   | 表示key的长度,当key为-1时，K byte key字段不填                |
| K byte key          | 可选                                                         |
| value bytes payload | 表示实际消息数据。                                           |

**文件系统**

Kafka 对消息的存储和缓存严重依赖于文件系统。人们对于“磁盘速度慢”具有普遍印象，事实上，磁盘的速度比人们预期的要慢的多，也快得多，这取决于人们使用磁盘的方式。

使用6个7200rpm、SATA接口、RAID-5的磁盘阵列在JBOD配置下的顺序写入的性能约为600MB/秒，但随机写入的性能仅约为100k/秒，相差6000倍以上。

线性的读取和写入是磁盘使用模式中最有规律的，并且由操作系统进行了大量的优化。

- read-ahead 是以大的 data block 为单位预先读取数据
- write-behind 是将多个小型的逻辑写合并成一次大型的物理磁盘写入

关于该问题的进一步讨论可以参考 ACM Queue article，他们发现实际上顺序磁盘访问在某些情况下比随机内存访问还要快！

**为了弥补这种性能差异，现代操作系统主动将所有空闲内存用作 disk caching（磁盘高速缓存），所有对磁盘的读写操作都会通过这个统一的 cache（ in-process cache）。**

即使进程维护了 in-process cache，该数据也可能会被复制到操作系统的 pagecache 中，事实上所有内容都被存储了两份。

此外，Kafka 建立在 JVM 之上，任何了解 Java 内存使用的人都知道两点：

1. 对象的内存开销非常高，通常是所存储的数据的两倍(甚至更多)。
2. 随着堆中数据的增加，Java 的垃圾回收变得越来越复杂和缓慢。

kafka选择了一个非常简单的设计：相比于维护尽可能多的 in-memory cache，并且在空间不足的时候匆忙将数据 flush 到文件系统，我们把这个过程倒过来。**所有数据一开始就被写入到文件系统的持久化日志中，而不用在 cache 空间不足的时候 flush 到磁盘**。实际上，这表明数据被转移到了内核的 pagecache 中。

**Pagecache页面缓存**

- **Page cache（页面缓存）**

  Page cache 也叫页缓冲或文件缓冲，是由好几个磁盘块构成，大小通常为4k，在64位系统上为8k，构成的几个磁盘块在物理磁盘上不一定连续，文件的组织单位为一页， 也就是一个page cache大小，文件读取是由外存上不连续的几个磁盘块，到buffer cache，然后组成page cache，然后供给应用程序。

- **Buffer cache（块缓存）**

  Buffer cache 也叫块缓冲，是对物理磁盘上的一个磁盘块进行的缓冲，其大小为通常为1k，磁盘块也是磁盘的组织单位。设立buffer cache的目的是为在程序多次访问同一磁盘块时，减少访问时间。

- **Page cache（页面缓存）与Buffer cache（块缓存）的区别**

  磁盘的操作有逻辑级（文件系统）和物理级（磁盘块），这两种Cache就是分别缓存逻辑和物理级数据的。

  我们通过文件系统操作文件，那么文件将被缓存到Page Cache，如果需要刷新文件的时候，Page Cache将交给Buffer Cache去完成，因为Buffer Cache就是缓存磁盘块的。

  **简单说来，page cache用来缓存文件数据，buffer cache用来缓存磁盘数据。在有文件系统的情况下，对文件操作，那么数据会缓存到page cache，如果直接采用dd等工具对磁盘进行读写，那么数据会缓存到buffer cache。**

  Buffer(Buffer Cache)以块形式缓冲了块设备的操作，定时或手动的同步到硬盘，它是为了缓冲写操作然后一次性将很多改动写入硬盘，避免频繁写硬盘，提高写入效率。

  Cache(Page Cache)以页面形式缓存了文件系统的文件，给需要使用的程序读取，它是为了给读操作提供缓冲，避免频繁读硬盘，提高读取效率。

**降低时间复杂度**

消息系统使用的持久化数据结构通常是和 BTree 相关联的消费者队列或者其他用于存储消息源数据的通用随机访问数据结构。**BTree 的操作复杂度是 O(log N)**，通常我们认为 O(log N) 基本等同于常数时间，但这条在磁盘操作中不成立。

存储系统将非常快的cache操作和非常慢的物理磁盘操作混合在一起，当数据随着 fixed cache 增加时，可以看到树的性能通常是非线性的——比如数据翻倍时性能下降不只两倍。

**kafka选择把持久化队列建立在简单的读取和向文件后追加两种操作之上**，这和日志解决方案相同。**这种架构的优点在于所有的操作复杂度都是O(1)，而且读操作不会阻塞写操作，读操作之间也不会互相影响。**

在不产生任何性能损失的情况下能够访问几乎无限的硬盘空间，Kafka 可以让消息保留相对较长的一段时间(比如一周)，而不是试图在被消费后立即删除。

**降低大量小型IO操作的影响**

小型的 I/O 操作发生在客户端和服务端之间以及服务端自身的持久化操作中。

为了避免这种情况，kafka的协议是建立在一个 “消息块” 的抽象基础上，合理将消息分组。将多个消息打包成一组，而不是每次发送一条消息，从而使整组消息分担网络中往返的开销。

这个简单的优化对速度有着数量级的提升。批处理允许更大的网络数据包，更大的顺序读写磁盘操作，连续的内存块等等，所有这些都使 KafKa 将随机流消息顺序写入到磁盘， 再由 consumers 进行消费。

**零拷贝**

字节拷贝是低效率的操作，在消息量少的时候没啥问题，但是在高负载的情况下，影响就不容忽视。为了避免这种情况，kafka使用 producer ，broker 和 consumer 都共享的标准化的二进制消息格式，这样数据块不用修改就能在他们之间传递。

保持这种通用格式可以**对一些很重要的操作进行优化**: 持久化**日志块的网络传输**。现代的unix 操作系统提供了一个高度优化的编码方式，用于将数据从 pagecache 转移到 socket 网络连接中；在 Linux 中系统调用 sendfile 做到这一点。

- 传统IO **(4次上下文切换4次拷贝)**

  假如将磁盘上的文件读取出来，然后通过网络协议发送给客户端。

  一般需要两个系统调用，**但是一共4次上下文切换，4次拷贝**

  ```
  read(file, tmp_buf, len);
  write(socket, tmp_buf, len);
  ```

- **要想提高文件传输的性能，就需要减少「用户态与内核态的上下文切换」和「内存拷贝」的次数**。

- mmap(**4次上下文切换3次拷贝**)

  mmap()系统调用函数会直接把内核缓冲区里的数据「**映射**」到用户空间，这样，操作系统内核与用户空间就不需要再进行任何的数据拷贝操作，它替换了read()系统调用函数。

  ```
  buf = mmap(file, len);
  write(sockfd, buf, len);
  ```

+ sendfile（**2次上下文切换3次拷贝**）

  Linux 内核版本 2.1 中，提供了一个专门发送文件的系统调用函数 sendfile()

  首先，它可以替代前面的 read()和 write()这两个系统调用，这样就可以减少一次系统调用，也就减少了 2 次上下文切换的开销。

  其次，该系统调用，可以直接把内核缓冲区里的数据拷贝到 socket 缓冲区里，不再拷贝到用户态，这样就只有 2 次上下文切换，和 3 次数据拷贝。

```
#include <sys/socket.h>
ssize_t sendfile(int out_fd, int in_fd, off_t *offset, size_t count);
```

+ 它的前两个参数分别是目的端和源端的文件描述符，后面两个参数是源端的偏移量和复制数据的长度，返回值是实际复制数据的长度。

+ 零拷贝（2次上下文切换2次拷贝）

  Linux 内核 2.4 版本开始起，对于支持网卡支持 SG-DMA 技术的情况下， sendfile() 系统调用的过程发生了点变化，具体过程如下：

- 第一步，通过 DMA 将磁盘上的数据拷贝到内核缓冲区里；
- 第二步，缓冲区描述符和数据长度传到 socket 缓冲区，这样网卡的 SG-DMA 控制器就可以直接将内核缓存中的数据拷贝到网卡的缓冲区里，此过程不需要将数据从操作系统内核缓冲区拷贝到 socket 缓冲区中，这样就减少了一次数据拷贝；

**kafka高效文件存储设计特点**

- Kafka把topic中一个parition大文件分成多个小文件段，通过多个小文件段，就容易定期清除或删除已经消费完文件，减少磁盘占用。
- 通过索引信息可以快速定位message和确定response的最大大小。
- 通过index元数据全部映射到memory，可以避免segment file的IO磁盘操作。
- 通过索引文件稀疏存储，可以大幅降低index文件元数据占用空间大小。