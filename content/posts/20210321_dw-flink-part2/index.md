---
title: "Data Warehouse: Real-Time, part Ⅱ" # Title of the blog post.
date: 2021-03-21T10:04:49+08:00 # Date of post creation.
description: "" # Description used for search engine.
featured: false # Sets if post is a featured post, making appear on the home page side bar.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: true # Controls if a table of contents should be generated for first-level links automatically.
# menu: main
usePageBundles: true # Set to true to group assets like images in the same folder as this post.
# featureImage: "/images/path/file.jpg" # Sets featured image on blog post.
# featureImageAlt: 'Description of image' # Alternative text for featured image.
# featureImageCap: 'This is the featured image.' # Caption (optional).
# thumbnail: "images/.png" # Sets thumbnail image appearing inside card on homepage.
# shareImage: "/images/path/share.png" # Designate a separate image for social media sharing.
codeMaxLines: 40 # Override global value for how many lines within a code block before auto-collapsing.
codeLineNumbers: true # Override global value for showing of line numbers within code block.
figurePositionShow: true # Override global value for showing the figure label.
categories:
  - Technology
tags:
  - DataWarehouse
  - Flink

---

Data warehouse is a system that pulls together data derived from operational systems and external data sources within an organization for reporting and analysis. A data warehouse is a central repository of information that provides users with current and historical decision support information.

<!--more-->

## DWM 数据中间层

### 业务数据写入DWM

#### 数据流和程序流程

```
数据流：：web/app -> Nginx -> SpringBoot -> Mysql -> FlinkApp -> Kafka(ods) -> FlinkApp -> Kafka/Hbase(dwd-dim) -> [FlinkApp -> Kafka(dwm)]

程序：mocklog -> Mysql -> FlinkCDC -> KafkaZ(zk) -> BaseLogApp -> Kafka/Phoneix(zk/hdfs/hbase) -> [UniqueVisitApp -> Kafka]
```

#### 代码实现 - 用户第一次访问

```java
//UniqueVisitApp
// 1.获取执行环境
StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
env.setParallelism(1);
// 2.读取 kafka dwd_page_log 主题的数据
env.addSource(MyKafkaUtil.getKafkaConsumer(sourceTopic, groupId));
// 3.将每行数据转换为 JSON 对象
jsonObjDS = KafkaDS.map(JSON::parseObject);
// 4.过滤数据、状态编程、只保留每天第一个数据
keyedStream = jsonObjDS.keyBy(jsonObj -> jsonObj.getJSONObject("common")).getString("mid");
uvDS = keyedStream.filter(new RichFilterFunction<JSONObject>(){
    private ValueState<String> dataState;
    private SimpleDateFormat simpleDateFormat;
    
    @Override
    public void open(Configuration parameters) throws Exception {
        valueStateDescriptor = new ValueStateDescriptor<>("data-state", String.class);
        dataState = getRuntimeContext().getState(valueStateDescriptor);
        simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd");
    }
    
    @Override
    public boolean filter(JSONObject value) throws Exception{
        return {...};
    }
});
// 5.将数据写入 Kafka
uvDS.map(JSONAware::toJSONString).addSink(MyKafkaUtil.getKafkaProducer(sinkTopic));
// 6.启动
env.execute("UniqueVisitApp");
```

#### 代码实现 - 用户跳出页面

```java
//UserJumpDetailApp
// 1.获取执行环境
// 2.读取 kafka 主题数据创建流
// 3.将每行数据转换为 JSON 对象，提取时间戳
// 4.定义模式序列
// 5.将模式序列作用到流上
// 6.提取匹配上的超时事件, UNION 两种事件
// 7.将数据写入 Kafka
// 6.启动
```

### Flink Stream Join

#### Window Join

```java
stream.join(otherStream)
      .where(<KeySelector>)
      .equalTo(<KeySelector>)
      .window(<WindowAssigner>)
      .apply(<JoinFunction>)
```

Tumbing Window Join

滚动窗口：和 SparkStreaming 直接 Join 一样

Sliding Window Join

滑动窗口：有可能数据重复 Join

Session Window join

会话窗口：两个流的数据一段时间都没有数据，两个流开始 Join

#### Interval Join

对被Join的流有 lower bound 和 upper bound 范围选择（范围选择则要用到状态编程、当前仅支持状态时间，需提取出状态时间）

#### 代码实现 - 订单明细表双流 Join

```java
//OrderWideApp
//1.获取执行环境
//2.读取 Kafka 主题的数据，转化为 JavaBean 对象并且提取时间戳生成 WaterMark
//3.双流 Join
//4.关联维度信息
//5.写入Kafka
//6.启动任务
```

### 维度表关联

#### 优化1：加入旁路缓存

维度关联时查询维度表，先查 Redis，再查 HBASE。

Redis 作为旁路缓存，订单宽表查询维度数据时先查旁路缓存。没有再查询维度数据，同时同步到旁路缓存。

{{< admonition warning 注意问题>}}

1.缓存要设过期时间，不然冷数据会常驻缓存浪费资源。

2.要考虑维度数据是否会发生变化，如果发生变化要主动清楚缓存。

{{< /admonition >}}

{{< admonition abstract 缓存选型>}}

两种：堆缓存 或者 独立缓存服务(Redis, memcache)

**堆缓存**，性能好，管理性差。

**独立缓存服务**，有创建连接、网络 IO 等消耗。管理性更强，更容易扩展。

**联合使用**(LRU Cache，最近最少使用)

{{< /admonition >}}

代码实现

```java
public class RedisUtil{...}

public class DimUtil{//维度表关联
    //查询 HBASE 表之前先查询 Redis
    Jedis jedis = RedisUtil.getJedis();
    String dimInfoJsonStr = jedis.get(redisKey);
    // RedisKey 不用 hash 的原因：
    //    1.用户数据量大，使用大量数据可能到一条 hash 上，造成热点问题。
    //    2.需要设置过期时间。
    // RedisKey 不用 Set 的原因：
    //    1.查询不方便
    //    2.需要设置过期时间。
    if(dimInfoJsonStr != null){
         //归还连接
    	jedis.close();
    	//重置过期时间
    	jedis.expire(redisKey, 24 * 60 * 60);
    	//返回结果
    	return JsonObject.parseObject(dimInfoJsonStr);
    }
    //从 HBASE 拿数据
    ....
    //将数据写入 Redis
    jedis.set();
    jedis.expire();
    jedis.close();
    
    return dimInfoJson;
}
```

#### 优化2：异步查询

异步查询把查询操作托管给单独的线程池完成，这样不会因为某个查询造成阻塞，单个并行可以连续发送多个请求，提高并发效率。

代价：消耗更多的 Tasks，threads、Flink-internal network connections

数据流和程序流程

```
数据流：web/app -> Nginx -> SpringBoot -> Mysql -> FlinkApp -> Kafka(ods) -> FlinkApp -> Kafka/Hbase(dwd-dim) -> [FlinkApp(redis)] -> Kafka(dwm)

程序：mocklog -> Mysql -> FlinkCDC -> KafkaZ(zk) -> BaseLogApp -> Kafka/Phoneix(zk/hdfs/hbase) -> [OrderWideApp(Redis) -> Kafka]
```

代码实现

```java
public class DimAsyncFunction<T> extends RichAsyncFunciton<T, T>{
    @Override
    public void open(){}
    @Override
    public void asyncInvoke(){}
    @Override
    public void timeout(){}
}

public class ThreadPoolUtil{
    private static ThreadPoolExecutor threadPoolExecutor = null;
    private ThreadPoolUtil(){   
    }
    public static ThreadPoolExecutor getThreadPool{
        //懒汉式-单例模式
        if(threadPoolExecutor == null){
            synchronized(ThreadPoolUtil.class){
                if(threadPoolExecutor == null){
                    threadPoolExecutor = new ThreadPoolExecutor(corePoolSize = 8,maximumPoolSize = 16,keepAliveTime = 1L,TimUnit.MiNUTES,new LinkedBlockingDeque<>());
                }
            }
        }
        return threadPoolExecutor;
    }
}
```

### 主流数据丢失

使用 intervalJoin 来管理流的状态时间，保证当支流数据到达时主流数据还保存在状态中。

### 业务数据写入DWM

#### 代码实现 - 支付宽表

```java
PaymentWideApp;
//1.获取执行环境
//2.读取 kafka 主题数据创建流
//3.双流 Join
//4.写入Kafka
//5.启动任务
```

## DWS 数仓汇总层

轻度聚合，因为 DWS 层要应对很多实时查询，如果完全的明细那么查询的压力是非常大的。

### 主题宽表写入DWS

#### 数据流和程序流程

```
数据流：web/app -> Nginx -> SpringBoot -> Mysql -> FlinkApp -> Kafka(ods) -> FlinkApp -> Kafka/Hbase(dwd-dim) -> FlinkApp(redis) -> Kafka(dwm) -> [FlinkApp -> ClickHouse]

程序：mocklog -> Mysql -> FlinkCDC -> KafkaZ(zk) -> BaseLogApp -> Kafka/Phoneix(zk/hdfs/hbase) -> OrderWideApp(Redis) -> Kafka -> [uv/uj -> kafka -> VisitorStatsApp -> ClickHouse]
```

#### 代码实现 - 访客主题宽表

```java
VisitorStatsApp;
//1.获取执行环境
//2.读取 kafka 数据创建流
//3.将每个流处理成相同的数据类型
//4.Union 所有流
//5.提取时间戳生成 WaterMark
//6.按照维度信息分组
//7.开窗聚合 10s 的滚动窗口
WindowedStream<VisitorStats, Tuple4, TimeWindow> windowedStream = keyedStream.window(TumblingEventTimeWindows.of(Time.seconds(10)));
	// reducefunction 增量聚合，效率高
	// windowsfunction 全量聚合，包含窗口信息
	// reduce + window
windowedStream.reduce(new ReduceFunction<VisitorStats>(){}, new WindowFunction<VisitorStats, VisitorStats, Tuple4, TimeWindow(){})
//8.数据写入 ClickHouse
//9.启动任务
```

{{< admonition info >}}

维度聚合采用方式：`uv, 0, 0, 0 ,0` union `0, pv, 0, 0, 0` union `0, 0, sv, 0, 0` ... 先union再根据主键聚合

{{< /admonition >}}

{{< admonition question >}}

uv pv sv uj dur 不同流的数据进行维度聚合时，出现有流数据( uj )会丢失一直显示是 0 的情况，为什么？

+ 计算完 uj 表输入流，滚动窗口设置的 10 秒已经关闭。

{{< mermaid >}}

flowchart LR;

  pv --> dwd-page-log

dwd-page-log --> |consume|visitors-topic & uj

uj --> |consume|visitors-topic

{{< /mermaid >}}

+ dwd-page-log 第一条数据到达，visitors-topic 开窗[ts + 0, ts + 10)秒的窗口来接收dwd-page-log这10秒的全部数据
+ 但 visitors-topic 同时使用 dwd-page-log 和 uj 两个流的数据，uj 需要10秒后才输出流，visitors-topic 开窗已经关闭

解决方法：

+ 方法一：数据本身时间切换成处理的时间。不建议，数据时间不统一，不具有幂等性
+ 方法二：增加延迟时间

{{< /admonition >}}

