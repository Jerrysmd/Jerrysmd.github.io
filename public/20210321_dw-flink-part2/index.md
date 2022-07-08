# Data Warehouse: Real-Time, part Ⅱ


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

> 注意问题
>
> 1.缓存要设过期时间，不然冷数据会常驻缓存浪费资源。
>
> 2.要考虑维度数据是否会发生变化，如果发生变化要主动清楚缓存。

> 缓存选型
>
> 两种：堆缓存 或者 独立缓存服务(Redis, memcache)
>
> **堆缓存**，性能好，管理性差。
>
> **独立缓存服务**，有创建连接、网络 IO 等消耗。管理性更强，更容易扩展。
>
> **联合使用**(LRU Cache，最近最少使用)

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
WindowedStream<VisitorStats, Tuple4<String, String, String, String>, TimeWindow> windowedStream = keyedStream.window(TumblingEventTimeWindows.of(Time.seconds(10)));
windowedStream.reduce(new ReduceFunction<VisitorStats>()){}
//8.数据写入 ClickHouse
//9.启动任务
```

