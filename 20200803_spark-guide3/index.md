# Spark Guide, Part Ⅲ

Apache Spark has its architectural foundation in the resilient distributed dataset (RDD), a read-only multiset of data items distributed over a cluster of machines, that is maintained in a fault-tolerant way. The Dataframe API was released as an abstraction on top of the RDD, followed by the Dataset API.
<!--more-->

## Project

**业务场景**

统计出租车利用率(有乘客乘坐的时间和无乘客空跑的时间比例)

**技术要点**

1. 数据清洗
2. Json解析
3. 地理位置信息处理
4. 探索性数据分析
5. 会话分析

**数据读取**

```scala
class TaxiAnalysisRunner{
    def main(args: Array[String]): Unit = {
        //1创建SparkSession
        val spark = SparkSession.builder()
        	.master("local[6]")
        	.appName("taxi")
        	.getOrCreate()
        
        //2导入隐式转换和函数
        import spark.implicits._
        import org.apache.spark.sql.functions._
        
        //3数据读取
        val taxiRaw: Dataset[Row] = spark.read
        	.option("header", value = true)
        	.csv("dataset/half_trip.csv")
    }
}
```

**抽象数据类**

```scala
//dataframe是ROW类型的dataset
//读取的dataframe是row类型的，如果是dataset[trip]把类型抽象，对数据方便处理
case class Trip(
	license: String,
    pickUpTime: Long,
    dropOffTime: Long,
    pickUpX: Double,
    pickUpy: Double,
    dropOffX: Double,
    dropOffY: Double
)
```

**转换DF类型、清洗异常数据**

```scala
//dataframe[Row] => dataset[]
val taxiParsed:RDD[Either[Trip,(Row,Exception)]] = taxiRaw.rdd.map(safe(parse))
//异常数据
val exceptionResult = taxiParsed.filter(e => e.isRight)
	.map(e => e.right.get._1)
val taxi Good: Dataset[Trip] = taxiParsed.map(either => either.left.get).toDS()


def parse(row: Row): Trip = {
    val richRow = new richRow(row)
    val license = richRow.getAs[String]("hack_license").orNull
    val pickUpTime = parseTime(richRow, "...")
    val dropOffTime = parseTime(richRow, "...")
    val pickUpX = parseLocation(richRow, "...")
    val pickUpy = parseLocation(richRow, "...")
    val dropOffX = parseLocation(richRow, "...")
    val dropOffY = parseLocation(richRow, "...")
    Trip(license, pickUpTime, dropOffTime, pickUpX, pickUpy, dropOffX, dropOffY)
}

class RichRow(row: Row){
    def getAs[T](field: String): Option[T] = {
        if(row.isNullAt(row.fieldIndex(field))){
            None
        }else{
            Some(row.getAs[T](field))
        }
    }
}
def parseTime(row: RichRow, field: String): Long = {
    //规定格式
    val pattern = "yyyy-MM-dd HH:mm:ss"
    val formatter = new SimpleDateFormat(pattern, locale.ENGLISH)
    //执行转换
    val time = row.getAs[String](field)
    val timeOption = time.map(time => formatter.parse(time).getTime)
    //Option代表某个方法，结果可能为空，使得方法调用出必须处理为null的情况
    //Option对象本身提供了一些对于null的支持
    timeOption.getOrElse(0L)
}

def parseLocation(row: RickRow, field: String): Double = {
    val location = row.getAs[String](fiecld)
    val locationOption = location.map(loc => loc.toDouble)
    locationOption.getOrElse(0D)
}

//parse异常处理
//出现异常->返回异常信息，和当前调用
def safe[P, R](f: P => R): P => Either[R,(P,Exception)]={
    new Function[P, Either[R,(P,Exception)]] with Serializable {
        override def apply(param: P): Either[R, (P, Exception)] = {
            try{
                Left(param)
            }catch{
                case e: Exception => Right((param, e))
            }
        }
    }
}
```

**统计分布**

```scala
//编写udf，将毫秒转为小时单位
val hours = (pickUpTime: Long, dropOffTime: Long) => {
    val duration = dropOffTime - pickUpTime
    val hours = TimeUnit.HOURS.convert(duration, TimeUnit.MILLISECONDS)
    hours
}
val hoursUDF = udf(hours)
//统计
taxiGood.groupBy(hoursUDF($"pickUpTime",$"dropOffTime") as "duration")
	.count()
	.sort("duration")
	.show()
//直方图
spark.udf.register("hours", hours)
val taxiClean = taxiGood.where("hours(pickUpTime, dropOffTime) BETWEEN 0 AND 3")
```

**JSON地理信息**

```scala
case class FeatureCollection(features: List[Feature])

case class Feature(Properties: Map[String, String], geometry: JObject) {
    def getGeometry(): Geometry = {
        import org.json4s._
        import org.json4s.jackson.JsonMethods._
        val mapGeo = GeometryEngine.geoJsonToGeometry(compact(render(geometry)), 0, Geometry.Type.Unknown)
        mapGeo.getGeometry
    }
}

object FeatureExtraction{
    
    //JSON解析
    def parseJson(json: String): FeatureCollection = {
        //1导入一个formats隐式转换
        implicit val formats = Serialization.formats(NoTypeHints)
        //2JSON -> Obj
        import org.json4s.jackson.Serialization.read
        val featureCollection = read[FeatureCollection](json)
        featureCollection
    }
}
```

```scala
//链接行政区信息
//1读取数据
val geoJson = Source.fromFile("dataset/districts.geojson").mkString
val featureColleciton = FeatureExtraction.parseJson(geoJson)
//2排序
//理论上大的区域数量多，把大的区域放在前面，减少搜索次数
val sortedFeatures = featureCollection.features.sortBy(feature => {
    (feature.properties("boroughCode"), - feature.getGeometry().calculateArea2D())
})
//3广播
val featuresBC = spark.sparkContext.broadcast(sortedFeatures)
//4UDF
val boroughLookUp = (x: Double, y: Double) => {
    //1搜索经纬度所在的区域
    val featureHit: Option[Feature] = featuresBC.value.find(feature => {
        GeometryEngine.contains(feature.getGeometry(), new Point(x, y), SpatialReference.create(4326))
    })
    //2转为区域信息
    val borough = featureHit.map(feature => feature.properties("borought")).getOrElse("NA")
    borough
}
//5统计信息
val broughUDF = udf(boroughLookUp)
taxiClean.groupBy(broughUDF('dropOffX,'dropOff))
```

**会话统计**

```scala
//过滤没有经纬度的数据
val sessions = taxiClean.where("dropOffX != 0 and dropOffY != 0 and pickUp...")
	.repartition('license)
	.sortWithinPartitions('license, 'pickUpTime)

//求得时间差
def boroughDuration(t1: Trip, t2: Trip): (String, Long) = {
    val borough = boroughLookUp(t1.dropOffX, t1.dropOffY)
    val duration = (t2.pickUpTime - t1.dropOffTime)/1000
    (borough, duration)
}

val boroughtDuration = sessions.mapPartitions(trips => {
    trips.sliding(2)//长度为2的窗口，移动
    	.filter(_.size == 2)
    	.filter(p => p.head.license == p.last.license)
    viter.map(p => boroughDuration(p.head, p.last))
}).toDF("borough", "seconds")

boroughtDuration.where("seconds > 0")
	.groupBy("borough")
	.agg(avg('seconds), stddev('seconds))
```

## Spark Streaming

Spark Streaming 的特点

> + Spark Streaming 并不是实时流，而是按时间切分小批量，一个一个的小批处理
> + Spark Streaming 对数据是按照时间切分为一个又一个的RDD，然后针对RDD进行处理

处理架构

> 批处理：HDFS
>
> 流处理：Kafka
>
> 混合处理：流式计算和批处理结合

Netcat

> Netcat以在两台设备上面相互交互，即侦听模式/传输模式
>
> > 功能：Telnet功能、获取banner信息、传输文本信息、传输文件/目录、加密传输文件，默认不加密、远程控制、加密所有流量、流媒体服务器、远程克隆硬盘

 ```scala
 object StreamingWordCount {
     def main(args: Array[String]): Unit = {
         val sparkConf = new SparkConff().setAppName("stream word count").setMaster("local[6]")
         val ssc = new StreamingContext(sparkConf, Seconds(1))//批次时间，每1秒收集一次数据
         //在创建Streaming Context的时候也要用到conf，说明Spark Streaming是基于Spark Core的
         //在执行master的时候，不能指定一个线程：因为在Streaming运行的时候，需要开一个新的线程去一直监听数据的获取
         //socketTextStream方法会创建一个DStream，监听Socket输入，当做文本处理
         //DStream可以理解是一个流式的RDD
         val lines: ReceiverInputDStream[String] = ssc.socketTextStream(
         	hostnmae = "192.168.169.101",
             port = 9999,
             storageLevel = StoreageLevel.MEMORY_AND_DISK_SER
         )
         
         //2数据处理
         //	1拆分单词
         val words = lines.flatMap(_.split(" "))
         //	2转换单词
         val tuples = words.map((_, 1))
         //	3词频reduce
         val counts = tuples.reduceByKey(_ + _)
         
         ssc.start()
         
         // main方法执行完毕后整个程序就会退出，所以需要阻塞主线程
         ssc.awaitTermination()
     }
 }
 ```

**容错**

> 热备
>
> + 当Receiver获取数据，交给BlockManager存储
> + 如果设置了StorageLevel.MEMORY_AND_DISK_SER，则意味着BlockManager 不仅会在本机存储，也会发往其它的主机存储，本质就是冗余备份
> + 如果某一个计算失败了，通过冗余的备份，再次进行计算即可
>
> 冷备
>
> + WAL 预写日志
> + 当数据出错时，根据Redo log去重新处理数据
>
> 重放
>
> + 有一些上游的外部系统是支持重放的，如 Kafka
> + Kafka 可以根据Offset来获取数据
> + 出错时，只需通过Kafka再次读取即可

## Structured Streaming

**编程模型演进**

RDD：

+ 针对自定义的数据对象进行处理，可以处理任意类型的对象，比较符合面向对象
+ RDD处理数据速较慢
+ RDD无法感知数据的结构，无法针对数据结构进行编程

DataFrame：

+ 保留元信息，针对数据结构进行处理，例如根据某一列进行排序或者分组
+ DF在执行的时候会经过catalyst进行优化，并且序列化更加高效，性能会更好
+ DF无法处理非结构化数据，因为DF内部使用Row对象保存数据
+ DF的读写框架更加强大，支持多种数据源

DataSet：

+ DS结合了RDD和DF的特点，可以处理结构化数据，也可以处理非结构化数据

**序列化**

将对象的内容变成二进制或存入文件中保存

数据场景：

+ 持久化对象数据
+ 网络中不能传输Java对象，只能将其序列化后传输二进制数据

**序列化应用场景**

+ Task分发：Master的driver往Worker的Executor任务分发
+ RDD缓存：序列化后分布式存储
+ 广播变量：序列化后分布式存储
+ Shuffle过程
+ Spark Streaming 的 Receiver：kafka传入的数据是序列化的数据

**RDD的序列化**

Kryo是Spark引入的一个外部的序列化工具，可以增快RDD的运行速度

因为Kryo序列化后的对象更小，序列化和反序列化速度非常快

```scala
val conf = new SparkConf()
	.setMaster("local[2]")
	.setAppName("KyroTest")

conf.set("spark.serializer", "org.apache.spark.serializer.KryoSerializer")
conf.registerKryoClasses(Array(classOf[Person]))

val sc = new SparkContext(conf)
rdd.map(arr => Person(arr(0), arr(1), arr(2)))
```

**StructuredStreaming区别**

1. StructuredStreaming相比于SparkStreaming的进步类似于RDD到Dataset的进步
2. StructuredStreaming支持连续流模型，类似于Flink那样的实时流

**StructuredStreaming Project**

需求

+ 对流式数据进行累加词频统计

整体结构

1. Socket Server 发送数据， Structured Streaming 程序接受数据
2. Socket Server 使用 Netcat nc 来实现

```scala
//1.创建sparkSession
//2.数据读取
val source: DataFrame = spark.readStream
	.format("socket")
	.option("host", "192.168.168.101")
	.option("port", 9999)
	.load()
val sourceDS: Dataset[String] = source.as[String]
//3.数据处理
val words = sourceDS.flatMap(_.split(" "))
	.map((_, 1))
	.groupByKey(_._1)
	.count()
//4.结果生成
words.writeStream
	.outputMode(OutputMode.Complete())
	.format("console")
	.start()
	.awaitTermination()
```

```shell
# 开启Netcat
nc -lk 9999
```

StreamExecution 分为三个重要的部分

+ Source 从外部数据源读取数据，例如kafka
+ LogicalPlan 逻辑计划，在流上查询计划，根据源头DF处理生成逻辑计划
+ Sink 写入结果

**StateStore**

+ Structured Streaming 虽然从API角度上模拟出来的是一个无线扩展的表，但其内部还是增量处理。
+ 每一批次处理完成，会将结果写入状态。每一批次处理之前，拉出来最新的状态，合并到处理过程中

## Structured Streaming HDFS

**场景**

+ Sqoop

  > MySQL -> Sqoop -> HDFS[增量数据1，增量数据2，... ] -> Structured Streaming -> Hbase

+ Ngix

  > Ngix[log1, log2，... ] -> Flume -> HDFS[增量数据1，增量数据2，... ] -> Structured Streaming -> Hbase

+ 特点

  + 会产生大量小文件在HDFS上

**Project**

> 1. Python程序生成数据到HDFS
> 2. Structured Streaming 从HDFS中获取数据
> 3. Structured Streaming 处理数据

```python
# Python程序生成数据到HDFS
import os
for index in range(100):
    #1.文件内容
    content = """
    {"name": "Michael"}
    {"name": "Andy", "age": 30}
    {"name": "Justin", "age": 19}
    """
    
    #2.文件路径
    file_name = "/export/dataset/text{0}.json".format(index)
    
    #3.打开文件，写入内容
    with open(file_name, "w") as file:
        file.write(content)
	
    #4.执行HDFS命令，创建HDFS目录，上传文件到HDFS中
    os.system("/export/servers/haddop/bin/hdfs dfs -mkdir -p /dataset/dataset/")
    os.system("/export/servers/haddop/bin/hdfs dfs -put {0} /dataset/dataset".format(file_name))
```

```scala
//Structured Streaming 从HDFS中获取数据
object HDFSSource{
    def main(args: Array[String]): Unit = {
        System.setProperty("hadoop.home.dir", "C:\\winutil")
        
        //1.创建SparkSession
        val spark = SparkSession.builder()
        	.appName("hdfs_souce")
        	.master("local[6]")
        	.getOrCreate()
        //2.数据读取
        val schema = new StructType()
        	.add("name", "string")
        	.add("age", "integer")
        
        val souce = spark.readStream
        	.scheme(schema)
        	.json("hdfs://node01:8020/dataset/dataset")
        
        //3.输出结果
        source.writeStream
        	.outputMode(OutputMode.Append())
        	.format("console")
        	.start()
        	.awaitTermination()
    }
}
```

## Structured Streaming Kafka

**Kafka是一个 Pub/Sub 系统**

>+ Publisher / Subscriber 发布订阅系统
>
> ```
> 发布者  -->  kafka  -->  订阅者
> ```
>+ 发布订阅系统可以有多个Publisher对应一个Subscriber，例如多个系统都会产生日志，一个日志处理器可以简单的获取所有系统产生的日志
>
> ```
> 用户系统  -->
> 订单系统  -->  kafka  -->  日志处理器
> 内容系统  -->
> ```
> 
>+ 发布订阅系统也可以一个Publisher对应多个Subscriber， 这样就类似于广播了，例如通过这样的方式可以非常轻易的将一个订单的请求分发给所有感兴趣的系统，减少耦合性
>
> ```
>                       -->  日志处理器
>  用户系统  -->  kafka  -->  日志处理器
>                       -->  日志处理器
> ```
> 
>+ 大数据系统中，消息系统往往可以作为整个数据平台的入口，左边对接业务系统各个模块，右边对接数据系统各个计算工具
>
> ```
>   业务系统                     数据系统
>  [用户系统]  -->         -->  [HDFS]
>  [订单系统]  -->  kafka  -->  [Structured Streaming]
>  [服务系统]  -->         -->  [MapReduce]
> ```

**Kafka 的特点**

> Kafka 非常重要的应用场景就是对接业务系统和数据系统，作为一个数据管道，其需要流通的数据量惊人，所以 Kafka 一定有：
>
> + 高吞吐量
> + 高可靠性

**Topic 和 Partitions**

> + 消息和事件经常是不同类型的，例如用户注册是一种消息，订单创建也是一种消息
>
>   ```
>   创建订单事件  -->
>                     kafka  -->  structured Streaming
>   用户注册事件  -->
>   ```
>
> + Kafka 中使用 Topic 来组织不同类型的消息
>
>   ```
>   创建订单事件  -->  Topic Order
>                                  -->  structured Streaming
>   用户注册事件  -->  Topic Order
>   ```
>
> + Kafka 中的 Topic 要承受非常大的吞吐量，所以 Topic 应该是可以分片的，应该是分布式的
>
>   ```
>   Anatomy of a Topic
>         
>   Partition 0 [0][1][2][3]
>   Partition 1 [0][1]
>   Partition 3 [0][1][2]
>         
>   Old  -->  New
>   ```

**Kafka 和 Structured Streaming 整合的结构**

> + Structured Streaming 中使用 Source 对接外部系统，对接 Kafka 的 Source 叫做 KafkaSource
> + KafkaSource 中会使用 KafkaSourceRDD 来映射外部 Kafka 的 Topic，两者的 Partition 一一对应
> + Structured Streaming 会并行的从 Kafka 中获取数据

**Structured Streaming 读取 Kafka 消息的三种方式**

> + Earlist 从每个 Kafka 分区最开始处开始获取
> + Assign 手动指定每个 Kafka 分区中的 Offset
> + Latest 不再处理之前的消息，只获取流计算启动后新产生的数据

**PROJECT**

需求

> 1. 模拟物联网系统的数据统计
> 2. 使用生产者在 Kafka 的 Topic：Streaming-test 中输入 JSON 数据
> 3. 使用 Structured Streaming 过滤出来家里有人的数据

创建 Topic 并输入数据到 Topic

> 1. 使用命令创建 Topic
>
>    ```shell
>    bin/kafka-topics.sh --create streaming-test --replication-factor 1 --partitions 3 --zookeeper node01:2181
>    ```
>
> 2. 开启 Producer
>
>    ```shell
>    bin/kafka-console-producer.sh --broker-list node01:9092,node02:9092,node03:9092 -topic streaming-test
>    ```
>
> 3. 把 Json 转为单行输入

Spark 读取 kafka 的 Topic

```scala
object KafkaSource{
    def main(args: Array[String]): Unit = {
        //1.创建 SparkSession
        
        //2.读取 Kafka 数据
        val source: Dadaset[String] = spark.readSteam
        	.format("kafka")
        	.option("kafka.bootstrap.servers", "node01:9092,node02:9092,node03:9092")
        	.option("subscribe", "streaming_test_1")
        	.option("startingOffsets", "earliest")
        	.load()
        	.selectExpr("CAST(value AS STRING) as value")
        	.as[String]
        
        //3.处理数据，Dataset(String) -> Dataset(id, name, category)
        //1::Toy Story (1995)::Animation|Children's|Comedy
        source.map(item => {
            val arr = item.split("::")
            (arr(0).toInt, arr(1).toString, arr(2).toString)
        }).as[(Int, String, String)].toDF("id", "name", "category")
        
        //4.Sink to HDFS
        result.writeStream
        	.format("parquet")
        	.option("path", "/dataset/streaming/movies/")
        	.option("checkpointLocation", "checkpoint")
        	.start()
        	.awaitTermination()
        
        //4.Sink to Kafka
        result.writeStream
        	.format("kafka")
        	.outputMode(OutputMode.Append())
        	.option("checkpointLocation", "checkpoint")
        	.option("kafka.bootstrap.servers", "node01:9092, node2:9092")
        	.option("topic", "streaming_test_3")
        	.start()
        	.awaitTermination()
        
        //4.Sink to Mysql
        //使用foreachWriter
    }
}
```

**Sink Trigger**

+ 微批次

  默认一秒间隔

+ 连续流

  Trigger.Continuous("1 second")，只支持Map类的类型操作，不支持聚合，Source和Sink只支持Kafka


