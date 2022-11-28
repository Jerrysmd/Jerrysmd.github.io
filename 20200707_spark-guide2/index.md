# Spark Guide, Part Ⅱ

Apache Spark has its architectural foundation in the resilient distributed dataset (RDD), a read-only multiset of data items distributed over a cluster of machines, that is maintained in a fault-tolerant way. The Dataframe API was released as an abstraction on top of the RDD, followed by the Dataset API.
<!--more-->

## Advanced Operation

closure

```scala
def test(): Unit = {
    val f = closure()
    f(5)
}
def closure(): Int => Double = {
    val factor = 3.14
    val areaFunction = (r: int) => {
        math.pow(r,2) * factor
    }
    areaFunction
}
```

1. f就是闭包，闭包的本质就是一个函数
2. 在scala中函数是一个特殊的类型，FunctionX
3. 闭包也是一个FunctionX类型的对象
4. 闭包是一个对象

```scala
class MyClass{
    val field = "Hello"
    def doStuff(rdd: RDD[String]): RDD [String] = {
        rdd.map(x => field + x)
        //引用Myclass对象中的一个成员变量，说明其可以访问MyClass这个类的总用域，也是一个闭包。封闭的是MyClass这个作用域。
        //在将其分发的不同的Executor中执行的时候，其依赖MyClass这个类当前的对象，因为其封闭了这个作用域。MyClass和函数都要一起被序列化。发到不同的结点中执行。
        //1. 如果MyClass不能被序列化，将会报错
        //2. 如果在这个闭包中，依赖了一个外部很大的集合，那么这个集合会随着每一个Task分发
    }
}
```

Global accumulator

1. 在任意地方创建long accumulator

2. 累加

3. 结果

   ```scala
   val counter = sc.longAccumulator("counter")
   val result = sc.parallelize(Seq(1,2,3,4,5)).foreach(counter.add(_))
   counter.value
   ```

Broadcast

广播变量允许将一个Read-Only的变量缓存到集群中的每个节点上，而不是传递给每一个Task一个副本

+ 集群中的每个节点指的是一个机器
+ 每一个Task，一个Task是一个Stage中的最小处理单元，一个Executor中可以有多个Stage，每个Stage有多个Task

所以在需要多个Stage的多个Task中使用相同数据的情况下，广播特别有用

```scala
val v = Map("Spark" -> "http[123]", "scala" -> "http[456]")

val config = new SparkConf().setMaster("local[6]").setAppName("bc")
val sc = new SparkContext(config)

//创建广播
val bc = sc.broadcast(v)

val r = sc.parallelize(Seq("Spark", "Scala"))

//使用广播变量代替直接引用集合，只会复制和executor一样的数量
//在使用广播之前，复制map了task数量份
//在使用广播之后，复制次数和executor数量一致
val result = r.map(item => bc.value(item)).collect()
```

## SparkSQL

+ Spark的RDD主要用于处理非结构化数据和半结构化数据
+ SparkSQL主要用于处理结构化数据
+ SparkSQL支持：命令式、SQL

优势：

+ 虽然SparkSQL是基于RDD的，但是SparkSQL的速度比RDD要快很多
+ SparkSQL提供了更好的外部数据源读写支持
+ SparkSQL提供了直接访问列的能力

```scala
case class Person(name: String, age: Int)

val spark: SparkSession = new sql.SparkSession.Builder()
	.appName("hello")
	.master("local[6]")
	.getOrCreate()

impart spark.implicits._

val personRDD: RDD[people] = spark.sparkContext.parallelize(Seq(Person("zs", 10),Person("ls", 15)))
val personDS: Dataset[Person] = PersonRDD.toDS()
val teenagers: Dataset[String] = PersonDS.where('age > 10)
	.where('age < 20)
	.select('name)
	.as[String]
```

**RDD和SparkSQL运行时的区别**

+ RDD的运行流程：

  RDD->DAGScheduler->TaskScheduleri->Worker

  先将RDD解析为由Stage组成的DAG，后将Stage转为Task直接运行

+ SparkSQL的运行流程：
  1. 解析SQL，并且生成AST（抽象语法树）
  2. 在AST中加入元数据信息，做这一步主要是为了一些优化，例如 col = col 这样的条件
  3. 对已经加入元数据的AST，输入优化器，进行优化（例如：谓词下推，列值裁剪）
  4. 生成的AST其实最终还没办法直接运行，这个AST是逻辑计划，结束后，需要生成物理计划，从而生成RDD来运行。

Dataset & DataFrame

**RDD 优点：**

1. JVM对象组成的分布式数据集合

2. 不可变并且有容错能力

3. 可处理机构化和非结构化的数据

4. 支持函数式转换


**RDD缺点：**

1. 没有Schema
2. 用户自己优化程序
3. 从不同的数据源读取数据非常困难
4. 合并多个数据源中的数据也非常困难

**DataFrame:**

1. DataFrame类似一张关系型数据的表
2. 在DataFrame上的操作，非常类似SQL语句
3. DataFrame中有行和列，Schema

**DataFrame的优点：**

1. Row对象组成的分布式数据集

2. 不可变并且有容错能力

3. 处理结构化数据

4. 自带优化器Catalyset,可自动优化程序

5. Data source API

6. DataFrame让Spark对结构化数据有了处理能力

**DataFrame的缺点：**

1. 编译时不能类型转化安全检查，运行时才能确定是否有问题
2. 对于对象支持不友好，rdd内部数据直接以java对象存储，dataframe内存存储的是row对象而不能是自定义对象

**Dataset的优点：**

1. DateSet整合了RDD和DataFrame的优点，支持结构化和非结构化数据
2. 和RDD一样，支持自定义对象存储
3. 和DataFrame一样，支持结构化数据的sql查询
4. 采用堆外内存存储，gc友好
5. 类型转化安全，代码友好

```scala
def dataset1(): Unit = {
    //1.创建SparkSession
    val spark = new sql.SparkSession.Builder()
    	.master("local[6]")
    	.appName("dateset1")
    	.getOrCreate()
    //2.导入隐式转化
    import spark.implicits._
    
    //3.demo
    val sourceRDD = spark.sparkContext.parallelize(Seq(Person("zs", 10),Person("ls", 15)))
    val dataset = sourceRDD.toDS()
    
    //Dataset支持强类型API
    dataset.filter(item => item.age > 10).show()
    //Dataset支持弱类型API
    dataset.filter( 'age > 10 ).show()
    dataset.filter( $"age" > 10 ).show()
    //Dataset可以直接编写SQL表达式
    dataset.filter( "age > 10").show()
```

**DataFrame Practice:**

```scala
def dataframe1(): Unit = {
    //1. 创建SparkSession
    val spark = SparkSession.builder()
    	.master("local[6]")
    	.appName("pm analysis")
    	.getOrCreate()
    //2.读取数据集
    val souceDF = spark.read
    	.option("header", value = true)
    	.csv("dataset/beijingPM.csv")
    //3.处理数据集
    sourceDF.select('year, 'month, 'PM_Dongsi)
    	.where('PM_Dongsi =!= "NA")
    	.groupBy('year, 'month)
    	.count()
    	.show()
    
    spark.stop()
}
```

DataFrame & Dataset 区别：

1. DataFrame是Dataset的一种特殊情况，DataFrame是Dataset[Row]的别名

2. **DataFrame表达的含义是一个支持函数式操作的表，而Dataset表达是一个类似RDD的东西，Dataset可以处理任何对象**

3. **DataFrame中存放的是Row对象，而Dataset中可以存放任何类型的对象**

4. DataFrame是弱类型，Dataset是强类型。DataFrame的操作方式和Dataset是一样的，但是对于强类型的操作而言，他们处理的类型是不同的

   DataFrame在进行强类型操作的时候，例如map算子，所处理的数据类型永远是Row

   而Dataset，其中是什么类型，他就处理什么类型。

```scala
val df: DataFrame = personList.toDF()
df.map( (row: Row) => Row(row.get(0), row,getAs[Int](1) * 2))(RowEncoder.apply(df.schema))

val ds: Dataset[person] = personList.toDS()
ds.map((person: Person => Person(person.name, person.age * 2)))
```

5. DataFrame只能做到运行时类型检查，Dataset能做到编译和运行都有类型检查

   DataFrame弱类型是编译时不安全(df.groupBy("name, school"))

   Dataset所代表的操作，是类型安全的，编译时安全的(ds.filter(person => person.name))

Row

DataFrame就是Row集合加上Schema信息

```scala		
case class Person(name: String, age: Int)
def row(): Unit = {
    //1.Row如何创建，是什么
    //row对象必须配合Schema对象才会有列名
    val person = Person("zs", 15)
    val row = Row("zs", 15)
    
    //2.如何从Row中获取数据
    row.getString(0)
    row.getInt(1)
    
    //3.Row也是样例类
    row match{
        case Row(name, age) => println(name, age)
    }
}
```

Reader

```scala
def reader1(): Unit = {
    //1.create SparkSession
    val spark = SparkSession.builder()
    	.master("local[6]")
    	.appName("reader1")
    	.getOrCreate()
    
   //2.firstWay
    spark.read
    	.format("csv")
    	.option("header", value = true)
    	.option("inferSchema", value = true)
    	.load("dataset/bjPM.csv")
    	.show(10)
    
    //3.sencendWay
    spark.read
    	.option("header", value = true)
    	.option("inferSchema", value = true)
    	.csv("dataset/bjPM.csv")
    	.show(10)
}
```

Writer

```scala
def writer1(): Unit = {
    System.setProperty("hodoop.home.dir","c:\\winutils")
    //1.create SparkSession
    val spark = SparkSession.builder()
    	.master("local[6]")
    	.appName("reader1")
    	.getOrCreate()
    //2.read data
    val df = spark.read.option("header", true).csv("dataset/bjPM.csv")
    //3.writer
    df.write.json("dataset/bjPM.json")
    
    df.write.format("json").save("dataset/bjPM2.json")
    
}
```

Parquet

Parquet属于Hadoop生态圈的一种**新型列式存储**格式，既然属于Hadoop生态圈，因此也兼容大多圈内计算框架（Hadoop、Spark），另外Parquet是平台、语言无关的，这使得它的适用性很广，只要相关语言有对应支持的类库就可以用；

Parquet的优劣对比：

- 支持嵌套结构，这点对比同样是列式存储的OCR具备一定优势；
- 适用于OLAP场景，对比CSV等行式存储结构，列示存储支持**映射下推**和**谓词下推**，减少磁盘IO；
- 同样的压缩方式下，列式存储因为每一列都是同构的，因此可以使用更高效的压缩方法；

```scala
def parquet(): Unit = {
    //read
    val df = spark.read.option("header", true).csv("dataset/bjPM.csv")
    //把数据写为parquet格式
    df.write
    	.format("parquet")
    	.mode(Savemode.Overwrite)
    	.save("dataset/bj_PM")
    //读取Parquet格式文件
    spark.read
    	.load("dataset/bj_PM")
    	.show()
}
```

Partition

表分区的概念不仅在parquet上有，其他格式的文件也可以指定表分区

```scala
def parquetPartions(): Unit ={
    val df = spark.read
    	.option("header",value = true)
    	.csv("dataset/BJPM.csv")
    
    //分区表形式写文件
    df.write
    .partitionBy("year", "month")
    .save(dataset/bjPM4)
    
    //读文件
    //写分区的时候，分区列不会包含在生成的文件中
    //直接通过文件来进行读取的话，分区信息会丢失
    //spark SQL自动发现分区
    spark.read
    	.parquet("dataset/bjPM4")
    	.printSchema()
}
```

JSON

+ toJSON: 把Dataset[Object]转为Dataset[JsonString]
+ 可以直接从RDD读取JSON的DataFrame，把RDD[JsonString]转为Dataset[Object]

Hive 

整合什么内容

> + MetaStore，元数据存储
>
>   SparkSql内置的有一个MetaStore。更成熟，功能更强，而且可以使用Hive的元信息
>
> + 查询引擎
>
>   SparkSQL内置了HiveSQL的支持

Hive的MetaStore

> Hive的MetaStore是Hive的一个组件。Hive中主要的组件组件就三个：
>
> 1. HiveServer2负责接收外部系统的查询请求，列如JDBC，HiveServer2接收查询请求后，交给Driver处理
> 2. Driver会首先询问MetaStore表在哪存，后Driver程序通过MR程序来访问HDFS从而获取结果返回给查询请求者
> 3. MetaStore对SparkSQL的意义重大，如果SparkSQL可以直接访问Hive的MetaStore，则理论上可以做和Hive一样的事情，例如通过Hive表查询数据
>
> 而Hive的MetaStore的运行模式有三种：
>
> + 内嵌Derby数据库模式
>
>   单链接，不支持并发
>
> + local模式
>
>   local和remote都是访问MySQL数据库作为存储元数据的地方，但是local模式的MetaStore没有独立进程，依附于HiveServer2的进程
>
> + Remote模式
>
>   和Local模式一样，访问MySQL数据库存放元数据，但是Remote的MetaStore运行在独立的进程中

Hive开启MetaStore

> 1. 修改hive-sito.xml
>
> 2. 启动Hive MetaStore
>
>    nohup /export/servers/hive/bin/hive --service metastore 2>&1 >> /var/log.log &

SparkSQL整合Hive的MetaStore

> 即使不去整合MetaStore，spark也有一个内置的MetaStore，使用Derby数据库保存数据，但这种方式不适合生产环境。

通过SparkSQL查询Hive的表

> 查询hive找那个的表可以通过spark。sql()来进行，可以直接在其中访问hive的MetaStore，前提是一定要将hive的配置文件拷贝到spark的conf目录
>
> ```scala
> spark.sql("use spark_integrition")
> val resultDF = spark.sql("select * from student limit 10")
> resultDF.show
> ```
>
> 

**Spark访问Hive中的表**

在Hive中创建表

> 1. 将文件上传到集群hdfs上
>
>    ```scala
>    hdfs dfs -mkdir -p /dataset
>    hdfs dfs -put studenttabl10k /dataset/
>    ```
>
> 2. 使用hive或者beeline执行sql
>
>    ```sql
>    create database if not exists spark_integrition;
>    use spark_integrition;
>    create external table student
>    {
>    	name String,
>    	age INT,
>    	gpa String
>    }
>    Row format delimited
>    	fields terminated by '\t'
>    	lines terminated by '\n'
>    stored as textfile
>    location '/dataset/hive'
>                   
>    load Data INPATH '/dataset/studenttab10k' OVERWRITE INTO TABLE student;
>    ```

JDBC

MySQL的访问方式有两种：使用本地运行，提交到集群中运行

```SCALA
//读数据
val spark = SparkSession
	.builder()
	.appName("jdbc example")
	.master("local[6]")
	.getOrCreate()
val schema = StructType(
	List(
    	StructField("name", StringType),
        StructField("age", IntegerType),
        StructField("gpa", FloatType),
    )
)
val studentDF = spark.read
	.option("delimiter", "\t")//读取文件的分隔符是制表符
	.schema(schema)
	.csv("dataset/studenttab10k")

//处理数据
val resultDF = studentDF.where("age<30")

//写数据
resultDF.write.format("jdbc").mode(SaveMode.Overwrite)
	.option("url", "jdbc:mysql://node01:3306/spark_test")
	.option("dbtable", "student")
	.option("user", "spark")
	.option("password", "Spark123!")
	.save()
```

## Data Type Transformation

flatMap,map,mapPartitions,transform,as:

```scala
class TypedTransformation{
    //1.创建sparksession
    val spark = SparkSession.builder().master("local[6]").appName("typed").getOrCreate()
    import spark.implicits._
    
    @Test
    def trans():Unit = {
        //flatmap
        val ds = Seq("hello spark", "hello hadoop").toDS
        ds.flatMap(item => item.split(" ")).show()
        //map
        val ds2 = Seq(Persion("zs",15),Persion("lisi",20)).toDS()
        ds2.map(person => Person(person.name, person.age*2)).show()
        //mappartitions
        ds2.mapPartitions{
            //iter 不能大到每个Executor的内存放不下，不然就会OOM
            //对每个元素进行转换，后生成一个新的集合
            iter =>{
                val result = iter.map(person => Person(person.name, person.age * 2))
                result
            }
        }
    }
}

def trans1(): Unit = {
    val ds = spark.rage(10) //0-10
    ds.transform(dataset => dataset.withColumn("doubled", 'id * 2'))
      .show()
}
```

DF转成DS

```scala
rdd.toDF -> DataFrame //toDF把rdd转成DF
dataFrame -> Dataset //DataFrame就是Dataset[Row]

case class Student(name:String, age:Int, gpa:Float)

//读取
val schema = StructType(
	Seq(
    	StructField("name",StringType),
        StructField("age",IntegerType),
        StructField("gpa",FloatType)
    )
)

val df = spark.read
	.schema(schema)
	.option("delimiter","\t")
	.csv("dataset/studenttab10k")
//转换
//本质上dataset[Row].as[Student] => Dataset[Student]
val ds: Dataset[Student] = df.as[Student]

//输出
ds.show()
```

Filter

```scala
def filter(): Unit = {
    val ds = Seq(Person("zs",15),Person("ls",20)).toDS()
    ds.filter(person => person.age > 15).show()
}
```

Group

groupByKey:

```scala
val ds = Seq(Person("zs",15),Person("ls",20)).toDS()
val grouped: KeyValueGroupedDataset[String, Person] = ds.groupByKey(person => person.name)
val result: Dataset[(String, Long)] = grouped.count()

result.show()

```

Split

```scala
val ds = spark.range(15)
//randomSplit, the number of part, weight
val datasets: Array[Dataset[lang.Long]] =ds.randomSplit(Array(5,2,3))
datasets.foeach(_.show())

//split
ds.sample(withReplacement = false, fraction = 0.4).show()
```

Sort

```scala
val ds = Seq(Person("zs",15),Person("ls",20),Person("zs",8)).toDS()
ds.orderBy('name.desc).show()
ds.sort('name.asc).show()
```

Distinct

distinct,dropDuplicates:

```scala
def dropDuplicates(): Unit = {
    val ds = Seq(Person("zs",15),Person("ls",20),Person("zs",8)).toDS()
    //重复列完全匹配
    ds.distinct().show()
    //指定列去重
    ds.dropDuplicates("age").show()
}
```

Collection

差集、交集、并集、limit

```scala
def collection(): Unit ={
    val ds1 = spark.range(1,10)
    val ds2 = spark.range(5,15)
    
    ds1.except(ds2)
    ds1.intersect(ds2)
    ds1.union(ds2)
    ds1.limit(3)
}
```

## Data Typeless Transformation

select

```scala
val ds = Seq(Person("zs",15),Person("ls",20),Person("zs",8)).toDS()
ds.sort()
  ....
  .secect('name).show()

ds.selectExpr("sum(age)").show()

import org.apache.spark.sql.funcitons._

ds.select(exper("sum(age)")).show()
```

Column

```scala
val ds = Seq(Person("zs",15),Person("ls",20),Person("zs",8)).toDS()

import org.apache.spark.sql.funcitons._
//如果想使用函数的功能
//1.使用functions.xx
//2.使用表达式，可以使用expr("...")随时编写表达式
ds.withColumn("random",expr("rand()")).show()
ds.withColumn("name_new",'name + ...).show()
ds.withColumn("name_jok",'name === "").show()
ds.withColumnRenamed("name","new_name").show()
```

Drop

```scala
val ds = Seq(Person("zs",15),Person("ls",20),Person("zs",8)).toDS()
ds.drop('age).show()
```

GroupBy

```scala
val ds = Seq(Person("zs",15),Person("ls",20),Person("zs",8)).toDS()
//为什么groupByKey是有类型的，最主要的原因是因为groupByKey所生成的对象中的算子是有类型的
ds.groupByKey(item => item.name).mapValues()
//为什么groupBy是无类型的，因为groupBy所生成的对象中的算子是无类型的，针对列进行处理
ds.groupBy('name).agg(mean("age")).show()
```

## Column

Creation

```scala
class Column{
    val spark = SparkSession.builder()
    	.master("local[6]")
    	.appName("column")
    	.getOrCreate()
    def creation():Unit = {
        val ds = Seq(Person("zs",15),Person("ls",20),Person("zs",8)).toDS()
        val df = Seq(("zs",15),("ls",20),("zs",8)).toDF("name","age")
        //1. ' 必须导入spark的隐式转化才能使用str.intern()
        val column: Symbol = 'name
        
        //2. $ 必须导入spark的隐式转化才能使用
        val column1: ColumnName = $"name"
        
        //3. col 必须导入functions
        import org.apache.spark.sql.functions._
        val column2:sql.Column = col("name")
        
        //4. column 必须导入functions
        val column3:sql.Column = column("name")
        
        //Dataset可以，DataFrame可以使用column对象
        ds.select(column).show()
        df.select(column).show()
        
        //column有四种创建方式
        //column对象可以用作于Dataset和DataFrame中
        //column可以和命令式的弱类型的API配合使用:select where
        
        //5. dataset.col
        //使用dataset来获取column对象，会和某个dataset进行绑定，在逻辑计划中，就会有不同的表现
        val column4 = ds.col("name")
        val column5 = ds1.col("name")
        ds.select(column5).show()
        //为什么要和dataset来绑定呢？
        ds.join(ds1, ds.col("name") === ds1.col("name"))
        
        //6. dataset.apply
        val column6 = ds.apply("name")
        val column7 = ds("name")
    }
}
```

Type

```scala
ds.select('name as "new_name").show()
ds.select('age.as[Long]).show()
```

API

```scala
//添加新列
df.withColun("age", 'age * 2).show()
//模糊查询
ds.where('name like "zhang%").show()
//排序
ds.sort('age asc).show()
//枚举判断
ds.where('name isin ("zs","wu","ls")).show()
```

## N/A

缺失值的处理：

 1. 丢弃缺失值的行
 2. 替换初始值

DataFrameNaFunctions

1. 创建

   ```scala
   val naf: DataFrameNaFunctions = df.na
   ```

2. 功能

   > naf.drop...	naf.fill ...

   ```scala
   df.na.drop.show()
   df.na.fill.show()
   
   class NullProcessor {
       @Test
       def nullAndNaN(): Unit = {
           //ss
           val spark = SparkSession.builder()
           	.master("local[6]")
           	.appName("null processor")
           	.getOrCreate()
           //导入
           
           //读取
           //	1.通过spark-csv自动的推断类型来读取，推断数字的时候会将NaN推断为字符串
           spark.read
           	.option("header", true)
           	.option("inferSchema",true)
           	.csv(dataset/ds)
           //	2.直接读取字符串，在后续的操作中使用map算子转换类型
           spark.read.csv().map(row => row...)
           //	3.指定Schema,不要自动推断
           val schema = structType(
           	list(
                   StructField("id",LongType),
                   StructField("year",IntegerType),
                   StructField("day",IntegerType),
                   StructField("season",IntegerType),
                   StructField("pm",DoubleType)
               )
           )
           val sourceDF = spark.read
           	.option("header", value = true)
           	.schema(schema)
           	.csv("dataset/data.csv")
           	.show()
           //丢弃
           //	规则：
           //		1.any：只要有一个NaN就丢弃
           sourceDF.na.drop("any").show()
           sourceDF.na.drop().show()
           //		2.all: 所有数据NaN才丢弃
           sourceDF.na.drop("all").show()
           //		3.某些列
           sourceDF.na.drop("any",List("year","month","day")).show()
           //填充
           //	规则：
           //		1.针对所有列默认值填充
           sourceDF.na.fill(0).show()
           //		2.针对特定列填充
           sourceDF.na.fill(0,List("year", "month")).show()
       }
   }
   ```
   
   SparkSQL处理异常字符串:
   
   ```scala
   def strProcessor(): Unit = {
       //1.丢弃
       import spark.implicits._
       sourceDF.where('PM_dongsi =!= "NA").show()
       //2.替换
       import org.apache.spark.sql.functions._
       sourceDF.select(
       	'No as "id", 'year, 'month, 'day,
           when('PM_Dongsi === "NA", Double.NaN)
           .otherwise('PM_Dongsi cast DoubleType)
           .as("pm")
       ).show()
       
       sourceDF.na.replace("PM_Dongsi", Map("NA" -> "NaN", "NULL" -> "null")).show()
   }
   
   ```

## groupBy

**groupBy**

```scala
//分组
val groupedDF = cleanDF.groupBy($"year",$"month")
//使用functions函数来完成聚合
import org.apache.spark.sql.functions._
groupedDF.agg(avg($"pm") as "pm_avg")
	.orderBy($"pm_avg".desc)

//分组第二种方式
groupedDF.avg("pm")
	.select($"avg(pm)" as "pm_avg")
	.orderBy("pm_avg")
```

**多维聚合**

```scala
//requirement 1:不同年，不同来源PM值的平均数
val postAndYearDF = pmFinal.groupBy('source,'year)
	.agg(avg($pm) as "pm")

//requirement 2:按照不同的来源统计PM值的平均数
val postDF = pmFinal.groupBy($source)
	.agg(avg($pm) as "pm")
	.select($source, lit(null) as "year", $pm)

//合并在同一个结果集中
postAndYearDF.union(postDF)
	.sort($source, $year asc_nulls_last, $pm)
```

**rollup**

滚动分组：rollup(A, B)，生成三列：AB分组，A null分组，null(全局)的分组

```scala
//requirement 1: 每个城市，每年的销售额
//requirement 2: 每个城市，一共的销售额
//requirement 3: 总体销售额
val sales = Seq(
    ("Bj", 2016, 100),
    ("Bj", 2017, 200),
    ("shanghai", 2015, 50),
    ("shanghai", 2016, 150),
    ("Guangzhou", 2017, 50),
).toDF("city", "year", "amount")

sales.rollup($city, $year)
	.agg(sum($amount) as "amount")
	.sort($city asc asc_nulls_last, $year.asc_nulls_last)
```

**cube**

rollup对参数顺序有要求，cube是对rollup的弥补

rollup(A, B)，生成四列：AB分组，A null分组，null B分组，null(全局)的分组

```scala
import org.apache.spark.sql.functions._
pmFinal.cube($source, $year)
	.agg(avg($pm) as "pm")
	.sort($source.asc_nulls_last, $year.asc_nulls_last)
```

**RelationalGroupedDataset**

groupBy, rollup, cube后的数据类型都是RelationalGroupedDataset

RelationalGroupedDataset并不是DataFrame，所以其中并没有DataFrame的方法，只有如下一些聚合相关的方法，下列方法调用后会生成DataFrame对象，然后就可以再次使用DataFrame的算子进行操作

| 操作符 | 解释                                                         |
| ------ | ------------------------------------------------------------ |
| avg    | average                                                      |
| count  | count                                                        |
| max    | max                                                          |
| min    | min                                                          |
| mean   | average                                                      |
| sum    | sum                                                          |
| agg    | 聚合，可以使用sql.funcitons中的函数来配合进行操作<br>`pmDf.groupBy($year).agg(avg($pm) as "pm_avg")` |

## Table Join

**Join**

```scala
class JoinProcessor{
    //create Spark
    //import implicits._
    @Test
    def introJoin(): Unit = {
        val person = Seq((0, "Lu", 0), (1, "Li", 0), (2,"Tim", 0))
        	.toDF("id", "name", "cityID")
        val cities = Seq((0, "BJ"), (1, "SH"), (2,"GZ"))
        	.toDF("id", "name")

        val df = person.join(cities, person.col("cityID") === cities.col("id"))
        	.select(person.col("id"),person.col("name"),cities.col("name"))
        
        df.createOrReplaceTempView("user_city")
    }
}
```

**cross**

交叉连接，笛卡尔积

```scala
def crossJoin(): Unit = {
    person.crossJoin(cities)
    	.where(person.col("cityId") === cities.col("id"))

    spark.sql("select u.id, u.name, from person u cross join cities c" + "where u.cityId = c.id") 
}
```

**inner**

交集

```sql
select * from person inner join cities on person.cityId = cities.id
```

```scala
person.join(right = cities,
           joinExprs = person("cityId") === citeis("id"),
           joinType = "inner")
```

**outer**

全外连接

内连接的结果只有连接上的数据，而全外连接可以包含没有连接上的数据。

**leftouter**

左外连接

全外连接含没有连接上的数据，左外连接只包含左边没有连接上的数据。

**semi&anti**

Semi-join
通常出现在使用了exists或in的sql中，所谓semi-join即在两表关联时，当第二个表中存在一个或多个匹配记录时，返回第一个表的记录；
与普通join的区别在于semi-join时，第一个表里的记录最多只返回一次；

Anti-join
而anti-join则与semi-join相反，即当在第二张表没有发现匹配记录时，才会返回第一张表里的记录；
当使用not exists/not in的时候会用到，两者在处理null值的时候会有所区别

1. 使用not in且相应列有not null约束
2. not exists，不保证每次都用到anti-join代

## UDF

自定义列操作函数

## Over Rank

```scala
//1定义窗口
val window = Window.partitionBy($category)
	.orderBy($revenue.desc)

//2处理数据
import org.apache.spark.sql.functions._
source.select($production, $category, dense_rank() over window as "rank")
	.where($rank <= 2)
	.show()
```

