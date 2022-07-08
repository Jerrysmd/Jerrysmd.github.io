---
title: "Parquet Format" # Title of the blog post.
date: 2020-12-15T10:47:59+08:00 # Date of post creation.
description: "Article description." # Description used for search engine.
featured: true # Sets if post is a featured post, making appear on the home page side bar.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: true # Controls if a table of contents should be generated for first-level links automatically.
# thumbnail: "images/data2.png" # Sets thumbnail image appearing inside card on homepage.
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
  - Spark
  - Distribution
  - Hdfs
comments: true # Disable comment if false.
---

Apache Parquet is designed for efficient as well as performant flat columnar storage format of data compared to row based files like CSV or TSV files. Parquet uses the record shredding and assembly algorithm which is superior to simple flattening of nested namespaces. Parquet is optimized to work with complex data in bulk and features different ways for efficient data compression and encoding types. This approach is best especially for those queries that need to read certain columns from a large table. Parquet can only read the needed columns therefore greatly minimizing the IO.

<!--more-->

HDFS 默认存的是文本格式，所以 hive, presto，都是在文本格式上做计算，hadoop本身是全表扫，只是分布式而以，所以我们之前用的就是分布式的全表扫而以，没有发挥出数据仓库该有的功能,列式存储，天然擅长分析，千万级别的表，count，sum，group by ，秒出结果。

## 1、场景描述：

对客户日志做了数据仓库，但实际业务使用中有一些个共同点，

A  需要关联维度表

B  最终仅取某个产品一段时间内的数据

C 只关注其中极少的字段

基于以上业务，我们决定每天定时统一关联维度表，对关联后的数据进行另外存储。各个业务直接使用关联后的数据进行离线计算。

## 2、选择parquet的外部因素

在各种列存储中，我们最终选择 parquet 的原因有许多。除了 parquet 自身的优点，还有以下因素：

A、公司当时已经上线spark 集群，而spark天然支持parquet，并为其推荐的存储格式(默认存储为parquet)。

B、hive 支持 parquet 格式存储，如果以后使用hivesql 进行查询，也完全兼容。

## 3、选择 parquet 的内在原因

下面通过对比 parquet 和 csv，说说parquet自身都有哪些优势

csv在hdfs上存储的大小与实际文件大小一样。若考虑副本，则为实际文件大小*副本数目。（若没有压缩）

3.1 parquet采用不同压缩方式的压缩比

说明：原始日志大小为214G左右，120多的字段

采用csv（非压缩模式）几乎没有压缩。

采用 parquet 非压缩模式、gzip、snappy格式压缩后分别为17.4G、8.0G、11G，达到的压缩比分别是：12、27、19。

|          | csv  | parquet 非压缩 | parquet gzip | parquet snappy |
| -------- | ---- | -------------- | ------------ | -------------- |
| 存储大小 | 214G | 17.4G          | 8.0G         | 11G            |
| 压缩比例 |      | 12             | 27           | 19             |

若我们在 hdfs 上存储3份，压缩比仍达到4、9、6倍

3.2 分区过滤与列修剪

3.2.1分区过滤

parquet结合spark，可以完美的实现支持分区过滤。如，需要某个产品某段时间的数据，则hdfs只取这个文件夹。

spark sql、rdd 等的filter、where关键字均能达到分区过滤的效果。

使用spark的partitionBy 可以实现分区，若传入多个参数，则创建多级分区。第一个字段作为一级分区，第二个字段作为2级分区。。。。。

3.2.2 列修剪

列修剪：其实说简单点就是我们要取回的那些列的数据。

当取得列越少，速度越快。当取所有列的数据时，比如我们的120列数据，这时效率将极低。同时，也就失去了使用parquet的意义。

3.2.3 分区过滤与列修剪测试如下：


说明：

A、task数、input值、耗时均为spark web ui上的真实数据。

B、之所以没有验证csv进行对比，是因为当200多G，每条记录为120字段时，csv读取一个字段算个count就直接lost excuter了。

C、注意：为避免自动优化，我们直接打印了每条记录每个字段的值。（以上耗时估计有多部分是耗在这里了）

D、通过上图对比可以发现：

当我们取出所有记录时，三种压缩方式耗时差别不大。耗时大概7分钟。
当我们仅取出某一天时，parquet的分区过滤优势便显示出来。仅为6分之一左右。貌似当时全量为七八天左右吧。
当我们仅取某一天的一个字段时，时间将再次缩短。这时，硬盘将只扫描该列所在rowgroup的柱面。大大节省IO。如有兴趣，可以参考 深入分析Parquet列式存储格式

E、测试时请开启filterpushdown功能

## 4、结论

parquet的gzip的压缩比率最高，若不考虑备份可以达到27倍。可能这也是spar parquet默认采用gzip压缩的原因吧。
分区过滤和列修剪可以帮助我们大幅节省磁盘IO。以减轻对服务器的压力。
如果你的数据字段非常多，但实际应用中，每个业务仅读取其中少量字段，parquet将是一个非常好的选择。
