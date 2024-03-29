---
title: "ClickHouse: A Distributed Database for High-Performance Analytics" # Title of the blog post.
date: 2020-11-07T14:55:59+08:00 # Date of post creation.
description: "Article description." # Description used for search engine.
featured: false # Sets if post is a featured post, making appear on the home page side bar.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: true # Controls if a table of contents should be generated for first-level links automatically.
# thumbnail: "images/search.png" # Sets thumbnail image appearing inside card on homepage.
# featureImage: "/images/path/file.jpg" # Sets featured image on blog post.
# featureImageAlt: 'Description of image' # Alternative text for featured image.
# featureImageCap: 'This is the featured image.' # Caption (optional).
codeLineNumbers: true # Override global value for showing of line numbers within code block.
codeMaxLines: 40 # Override global value for how many lines within a code block before auto-collapsing.
codeLineNumbers: true # Override global value for showing of line numbers within code block.
figurePositionShow: true # Override global value for showing the figure label.
categories:
  - Technology
tags:
  - ClickHouse
  - SQL
comments: true # Disable comment if false.
---

A high performance columnar OLAP database management system for real-time analytics using SQL. ClickHouse can be customized with a new set of efficient columnar storage engines, and has realized rich functions such as data ordered storage, primary key indexing, sparse indexing, data sharding, data partitioning, TTL, and primary and backup replication.

<!--more-->

## Feature

Yandex，**列式存储数据库**，在线分析处理查询（OLAP），SQL查询实时生成分析数据报告。

{{< admonition tip 列式存储 >}}

| `id1` | `id2` | `id3` | *name1* | *name2* | *name3* | `value1` | `value2` | `value3` |
| ----- | ----- | ----- | ------- | ------- | ------- | -------- | -------- | -------- |

1. 更擅长做 count、sum 、聚合等操作，优于行式存储。
2. 压缩效率高。由于某一列的数据类型都是相同的，针对于数据存储更容易进行数据压缩，每一列选择更优的数据压缩算法，大大提高了数据压缩的比重。

{{< /admonition >}}

{{< admonition note OLAP >}}

OLAP：更擅长一次写入，多次读取。更偏向于查数据

OLTP：更偏向于增删改查数据

{{< /admonition >}}

{{< admonition info 高吞吐的写入能力 >}}

与 HBASE 的存储结构相似，ClickHouse 采用类 LSM Tree 的结构，数据写入后定期在后台 compaction 操作。通过类 LSM tree的结构，ClickHouse 在数据导入时全部是顺序 append 写，写入后数据段不可更改，在后台 compaction 时也是多个段 merge sort 后顺序写回磁盘。顺序写的特性，充分利用了磁盘的吞吐能力，磁盘的吞吐能力，即便在 HDD 上也有着不错的写入性能。

{{< /admonition >}}

{{< admonition warning 数据分区与线程级并行 >}}

分区和切片不同，分区是将数据分为多个 partition，每个 partition 再进一步划分为多个 index granularity (索引粒度)，然后通过 CPU 的多核分别处理其中的一部分来实现并行数据处理。**单条 query 查询就能利用整机所有 CPU。** 极致的并行处理能力，极大的降低了查询延时。

所以也不利于多条并发查询，对于高 qps 的查询业务不是 CH 的强项。

{{< /admonition >}}

## Data Type

| MySQL     | Hive      | ClickHouse(区分大小写) |
| --------- | --------- | ---------------------- |
| byte      | tinyint   | Int8                   |
| short     | smallint  | Int16                  |
| int       | bigint    | Int64                  |
| timestamp | timestamp | DataTime               |
| ...       | ...       | ...                    |

+ 枚举

  数据类型中 **没有布尔值**，可以通过枚举代替。

  创建一个带有一个枚举 Enum8('true' = 1, 'false' = 2) 类型的列：

  ```sql
  CREATE TABLE t_enum
  (
      x Enum8('true' = 1, 'false' = 2)
  )
  ENGINE = TineLog
  # t_enum 表只可以放 true、false、1、2 内容
  ```

+ 数组

  Array(T)，不推荐使用多维数组，对多维数组的支持有限。例如，不能在 MergeTree 表中存储多维数组。

  可以使用 `array(T)` 或 `[]` 创建数组

  ```sql
  SELECT array(1, 2) AS arr, toTypeName(arr)
  ```

+ 元组

  Tuple(T1, T2, ...)，每个元素都有单独的类型

  ```
  SELECT array(1, 'a') AS arr, toTypeName(arr)
  ```

## Table Engine⭐

MySQL 默认的引擎：InnoDB 是事务型数据库的首选引擎，支持事务安全表（ACID）。

使用二十种表引擎决定了：

1. 数据存储方式和位置，写到内存还是磁盘
2. 支持哪些查询以及如何支持
3. 并发访问数据
4. 索引的使用
5. 是否多线程请求
6. 数据复制参数

### 1. TinyLog

最简单的表引擎，用于将数据存储在磁盘上。每列都存储在单独的压缩文件中，写入时，数据将附加到文件末尾。

1. 磁盘
2. 不支持索引
3. 不支持并发写，不支持一边读一边写

```sql
create tabele t (a UInt16, b String) engine = TinyLog
```

### 2. Memory

内存引擎，重启数据就会消失，读写不互相阻塞，不支持索引。简单查询性能表现超过 10 G/s。测试场景或数据量又不太大的场景（上限大约 1 亿行）。

### 3. Merge

（不要和 MergeTree 引擎混淆）本身不存储数据，但可用于同时从任意多个其他的表中读取数据，读是自动并行的，不支持写入。读数据时，那些被真正读取到数据的表的索引会被使用。

```sql
create table t(id UInt16, name String) engine = Merge(currentDatabase(), '^t');
```

### 4. MergeTree (重点)

clickhouse 中最强大的表引擎，当巨量数据要插入到表中，需要高效地一批批写入数据片段，并希望这些数据片段在后台按照一定规则合并。相比插入时不断修改（重写）数据进行存储，这种策略会高效很多。

1. 数据按照主键排序
2. 可以使用分区（如果指定了主键）
3. 支持数据副本
4. 支持数据采样

{{< admonition note 建表参数 >}}

ENGINE = MergeTree()

+ -[PARTITION BY]: 分区键。
  + 作用：与 hive 的分区相同，目的主要是降低扫描的范围，优化查询速度。
  
  + 默认：为一个分区。
  
  + 分区目录：MergeTree 是以列文件 + 索引文件 + 表定义文件组成的，如果设定了分区那么这些文件就会保存到不同的分区目录中。(tip: 要按月分区，可以使用表达式 toYYYYMM(data_column) )
  
  + 并行：跨分区的查询统计，CH 会以分区为单位并行处理。
  
  + 写入和分区合并：任何一个批次的数据写入都会产生一个临时的分区，不会纳入任何已有的分区。十几分钟后 CH 会自动执行合并操作。或手动合并 `optimize table x final;`

  + 通常按天分区比较合适。
  
+ -[PRIMARY KEY]: 主键。
  + 与其他数据库不同，它只提供了数据的一级索引，但却不是唯一约束。可以有相同的 key 数据。
  + 主键的设定依据查询语句，查询最频繁的字段作为 主键。根据条件通过对主键进行某种形式的二分查找，能够定位到对应的 index granularity，避免了全表扫描。
  + index_granularity: 稀疏索引，索引粒度，即索引中相邻【标记】间的数据行数，默认 8192 行一个索引。这就要求字段有序

+ ORDER BY: 表的排序键，可以是一组列的元组或任意的表达式。
  + 设定 **分区内** 的数据按照哪些字段顺序进行有序保存。
  + ORDER BY 是 MergeTree 中唯一一个必须项，比 primary key 更重要，没有主键依照 order by 的字段进行处理（比如去重汇总）
  + **主键必须是 order by 字段的前缀字段** ，如 order by 字段是 (id, sku_id, line)，那么主键必须是 id、 (id, sku_id) 或者 (id, sku_id, line)

+ -[SAMPLE BY]: 用于抽样的表达式，如果要用抽样表达式，主键中必须包含这个表达式

SETTINGS: 影响 MergeTree 性能的额外参数：

1. use_minimalistic_part_header_in_zookeeper: 数据片段头在 Zookeeper 中的存储方式
2. min_merge_bytes_to_use_direct_io: 使用直接 I/O （不经过缓存 I/O）来操作磁盘的合并操作时要求的最小数据量。当数据量特别大时，没必要经过缓存 I/O，默认数据小于 10G 会开启缓存 I/O

{{< /admonition >}}

{{< admonition success 数据TTL >}}

Time To Live, MergeTree 提供了可以管理数据或列的 **生命周期** 的功能。给字段设置时间，到期后字段数据归 0

{{< /admonition >}}

### 5. ReplacingMergeTree

在 MergeTree 的基础上，添加了 “处理重复数据” 的功能，该引擎和 MergeTree 的不同之处在于它会删除具有相同主键的重复项。使用 `order by` 使用的字段来规定去重字段。

### 6. SummingMergeTree

在 MergeTree 的基础上，添加了 “合并重复数据” 的功能，会把具有相同主键的行合并为一行，该行包含了被合并的行中具有数值数据类型的列的汇总值。

```sql
create table smt_table (date Date, name String, sum Uint16, not_sum UInt16)
engine = SummingMergeTree(sum)
partition by date
order by (date, name)
```

### 7. Distributed (重点)

分布式引擎，本身不存储数据，但可以在多个服务器上进行分布式查询。读是自动并行的。读取时，远程服务器表的索引会被使用。

## SQL Operation

1. insert
2. update / delete
3. select
4. alter

## Im/Export HDFS

> Clickhouse 从 18.16.0 版本开始支持从 HDFS 读取文件，在 19.1.6 版本支持读和写，在 19.4 版本开始支持 Parquet 格式。

案例一：client 通过 clickhouse 查询引擎访问 HDFS 上的文件

```shell
# 上传 csv 到 hdfs 根目录
hadoop fs -put module.csv /
# 进入 clickhouse 命令
clickhouse-client -h hadoop2 -m
# 建表
create table hdfs_module_csv
(
	id Int8,
	name String
)
Engine = HDFS('hdfs://hadoop2:9000/module.csv','CSV');
```

验证：

```shell
# 删除 HDFS 上的 CSV，验证是否在 clickhouse 上占用空间
hadoop fs -rm -r /module.csv
# sql
SELECT * from hdfs_module_csv; # error
```

案例二：HDFS 插入数据到本地存储引擎，client 通过 clickhouse 查询引擎查询 clickhouse 本地数据

```sql
# 通过 sql 插入到本地
insert into student_local select * from hdfs_module_csv
```

## Back Up

基于 ZK，需在配置 ZK

## Shard

### 集群写入流程

### 集群读取流程

+ 优先选择 errors_count 小的副本
+ errors_count 相同的有随机、顺序、随机、host 名称相似等四种选择方式。

### 配置三节点集群及副本

| hadoop102                                              | hadoop103                                                    | hadoop104          |
| ------------------------------------------------------ | ------------------------------------------------------------ | ------------------ |
| shard1, shard1副本                                     | shard1, shard1副本<br />(103数据和102数据相同)               | shard2, shard2副本 |
| 102_shard1_replica1 + 104_shard2_replica1 组成完整数据 | 103_shard1_replica2 + 104_shard2_replica1 也可以组成完整数据 |                    |



## Optimize

1. max_memory_usage

   此参数在 /etc/clickhouse-server/user.xml 中，表示单词 Query 占用内存最大值，超过 Query 失败，尽量调大。

2. 删除多个节点上的同一张表

   使用 on cluster 关键字。

   ```sql
   drop table * on cluster table_name
   ```

3. 自动数据备份

   只用 MergeTree 引擎支持副本。

   设置分片和分片副本节点。