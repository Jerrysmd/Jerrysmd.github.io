# Spring Framework Introduction


Spring makes programming Java quicker, easier, and safer. Spring’s focus on speed, simplicity, and productivity has made it the world's most popular Java framework. Spring works on microservices, reactive, cloud, web apps, serverless, event driven, and batch services.

<!--more-->

## Spring

### Framework

![spring-overview](spring-overview.png "spring-overview")

> 上层依赖于下层

| Core Container            | 核心容器，管理对象 |
| ------------------------- | ------------------ |
| AOP                       | 面向切面编程       |
| Aspects                   | AOP 思想实现       |
| Data Access / Integration | 数据访问 / 集成    |
| **Transactions**          | **事务**           |

### 核心容器

#### IoC & DI

> IoC (Inversion of Control) 控制反转
>
> DI (Dependency Injection) 依赖注入

+ 场景：

```java
//业务层实现
public class ServiceImpl implements Service{
    //数据层更新，业务层也需更新。然后重新编译，重新测试，重新部署，重新发布。
    private Dao dao = new DaoImpl();
    public void save(){
        bookDao.save();
    }
}
```

```java
//数据层实现
public class DaoImpl implements Dao{
    public void save(){
        //...method1
    }
}

public class DaoImpl2 implements Dao{
    public void save(){
        //...method2
    }
}
```

+ 现状：耦合度高。数据层更新，业务层也需更新。然后重新编译，重新测试，重新部署，重新发布。
+ 解决方案：
+ **IoC (Inversion of Control) 控制反转**
  + 使用对象时，在程序中不要主动使用 new 产生对象，转换由**外部**提供对象。此思想称为控制反转 IoC。
+ Spring 对 IoC 思想进行了实现：
  + Spring 提供了一个容器，称为 **IoC 容器**，用来作为提供对象的**"外部"**。就是 Spring Framework 中的核心容器。
  + IoC 容器负责对象的创建，初始化等一系列工作，被创建或被管理的对象在 IoC 容器中统称为 **Bean**。
+ **DI (Dependency Injection) 依赖注入**
  + 在容器中建立 bean 与 bean 之间的依赖关系的整个过程，称为依赖注入。

总结

+ 目标：充分解耦
  + 使用 IoC 容器管理 bean （IoC）
  + 在 IoC 容器内将有依赖关系的 bean 进行关系绑定（DI）
+ 最终效果
  + 使用对象时不仅可以直接

##### IoC Intro Case

1. IoC 管理什么？（Service、Dao、Service和Dao 关系）
2. 如何将被管理的对象告知 IoC 容器？（配置）
3. 被管理的对象交给 IoC 容器，如何获取到 IoC 容器？（接口）
4. IoC 容器得到后，如何从容器中获取 bean？（接口方法）

> **IoC Intro Case 步骤（XML）**
>
> 第一步：导入 spring-context
>
> ```xml
> <!--Mavern文件：pom.xml-->
> <dependency>
>     <groupId>org.springframework</groupId>
>     <artifactId>spring-context</artifactId>
>     <version>*.*.*.RELEASE</version>
> </dependency>
> ```
>
> 第二步：定义 Spring 管理的类和接口
>
> ```java
> public interface BookService{
>     public void save();
> }
> public class BookServiceImpl implements BookService{
>     private BookDao bookDao = new BookDaoImpl();
>     public void save(){
>         bookDao.save();
>     }
> }
> ```
>
> 第三步：创建 Spring 配置文件，配置对应类作为 Spring 管理的 bean
>
> ```xml
> <!--配置文件：applicationContext.xml-->
> <!--第三步：新建 applicationContext.xml 文件，配置 bean:
> bean 标签标识配置 bean
> id 属性标示 bean 的名字
> class 属性标示给 bean 定义类型-->
> <bean id="bookDao" class="com.jerry.dao.impl.BookDaoImpl"/>
> <bean id="bookService" class="com.jerry.service.impl.BookServiceImpl"/>
> ```
>
> 第四步：初始化 IoC 容器（Spring 容器），通过容器获取 bean
>
> ```java
> //App2.java
> package com.jerry;
> public class App2{
>     public static void main(String[] args){
>         // 获取 IoC 容器，根据配置文件创建 IoC
>         ApplicationContext ctx = new ClassPathXmlApplicationContext("applicationContext.xml");
>         // 获取 bean，与配置文件的 id 对应      
>         BookService bookService = (BookService) ctx.getBean("bookService");
>         bookService.save();// Service层是由一个或多个Dao层操作组成的。
>     }
> }
> ```

##### DI Intro Case

1. 基于 IoC 管理 bean（基于 IoC Intro Case）
2. Service 中使用 new 形式创建 Dao 对象？（否，使用 new 耦合性仍然很高）
3. Service 中需要的 Dao 对象如何进入到 Service 中？（提供方法）
4. Service 与 Dao 间的关系如何描述，Spring 如何知道该关系？（配置）

> **DI Intro Case 步骤（XML）**
>
> 第一步：删除业务层中使用 new 的方式创建的 dao 对象，提供依赖对象对应的 setter 方法
>
> ```java
> public class BookServiceImpl implements BookService{
>     // 5.删除业务层中使用 new 的方式创建的 dao 对象
>     private BookDao bookDao;
>     public void save(){
>         bookDao.save();
>     }
>     // 6.提供对应的 set 方法
>     public void setBookDao(bookDao bookDao){
>         this.bookDao = bookDao;
>     }
> }
> ```
>
> 第二步：配置 service 与 dao 之间的关系
>
> ```xml
> <bean id="bookDao" class="com.jerry.dao.impl.BookDaoImpl"/>
> <bean id="bookService" class="com.jerry.service.impl.BookServiceImpl">
>     <!--7.配置 server 与 dao 的关系-->
>     <!--name 属性表示配置哪一个具体的属性-->
>     <!--ref 属性表示参照哪一个 bean，与 bean id 对应-->
>     <property name="bookDao" ref="bookDao"></property>
> </bean>
> ```

#### Bean

##### Bean 配置

bean 基础配置

| 类别     | 描述                                                         |
| -------- | ------------------------------------------------------------ |
| 属性列表 | id：使用容器可以通过 id 获取对应的 bean<br />class：bean 的类型，即配置 bean 的全路径类名 |
| 范例     | \<bean id="bookDao" class="com.jerry.dao.impl.BookDaoImpl"/><br/>\<bean id="bookService" class="com.jerry.service.impl.BookServiceImpl"/> |

bean 作用范围配置

| 类别 | 描述                                                         |
| ---- | ------------------------------------------------------------ |
| 属性 | scope                                                        |
| 功能 | 定义 bean 的作用范围，可选范围如下<br /> 1. singleton：单例（默认）<br /> 2. prototype：非单例 |
| 范例 | \<bean id="bookDao" class="com.jerry.dao.impl.BookDaoImpl"/> |

+ 为什么 bean 默认为单例？

  > 这些对象复用没有问题，所以默认为单例，节省内存。

+ 适合交给容器进行管理的 bean

  | 适合交给容器管理的 bean | 不适合交给容器管理的 bean              |
  | ----------------------- | -------------------------------------- |
  | 表现层对象              | 封装实体的域对象（记录成员变量的对象） |
  | 业务层对象              |                                        |
  | 数据层对象              |                                        |
  | 工具类对象              |                                        |

  

##### Bean 实例化

Bean 的四种实例化

**方法一：构造方法实例化（常用）**

+ 提供可访问的构造方法

  ```java
  public class BookDaoImpl implements BookDao{
      public BookDaoImpl(){
          print("book constructor is running");
      }
      public void save(){
          print("book dao save");
      }
  }
  ```

+ 配置

  ```xml
  <bean id="bookDao" class="com.jerry.dao.impl.BookDaoImpl"></bean>
  ```

+ 无参构造方法如果不存在，将抛出异常 **BeanCreateionException**


**方法二：静态工厂实例化**

+ 静态工厂

  ```java
  public class OrderDaoFactory{
      public static OrderDao getOrderDao(){
          return new OrderDaoImpl();
      }
  }
  ```

+ 配置

  ```xml
  <bean id="orderDao" class="com.jerry.factory.OrderDaoFactory" factory-method="getOrderDao"></bean>
  ```

+ 使用

  ```java
  main(){
      UserDaoFactory userDaoFactory = new UserDaoFactory();
      UserDao userDao = userDaoFactory.getUserDao();
      userDao.save();
  }
  ```

**方法三：使用实例工厂实例化**

+ 实例工厂

  ```java
  public class UserDaoFactory{
      public UserDao getUserDao(){
          return new UserDaoImpl();
      }
  }
  ```

+ 配置

  ```xml
  <bean id="userFactory" class="com.jerry.factory.UserDaoFactory"></bean>
  <bean id="userDao" factory-method="getUserDao" factory-bean="userFactory"></bean>
  ```

**方法四：使用 FactoryBean 实例化 bean（重要）**

+ FactoryBean 

  ```java
  public class UserDaoFactoryBean implements FactoryBean<UserDao>{
      //代替原始实例工厂中创建对象的方法
      public UserDao getObject() throws Exception{
          return new UserDaoImpl();
      }
      public Class<?> getObjectType(){
          return UserDao.class;
      }
      public boolean isSingleton(){
          return true;
      }
  }
  ```

+ 配置

  ```xml
  <bean id="userDao" class="com.jerry.factory.UserDaoFactoryBean"></bean>
  ```

##### Bean 的生命周期

###### bean 生命周期控制方法

方法一：配置文件管理控制方法

```xml
<bean id="bookDao" class="com.jerry.dao.impl.BookDaoImpl" init-method="init" destroy-method="destory"></bean>
```

方法二：使用接口控制（了解）

```java
//实现 InitializingBean，DisposableBean 接口
public class BookServiceImpl implements BookService, InitializingBean, DisposableBean{
    public void save(){}
    public void afterPropertiesSet() throws Exception{}
    public void destroy() throws Exception{}
}
```

###### 生命周期

+ 初始化容器
  1. 创建对象（内存分配）
  2. 执行构造方法
  3. 执行属性注入（set 操作）
  4. **执行 bean 初始化方法**
+ 使用 bean
  + 执行业务操作
+ 销毁容器
  + **执行 bean 销毁方法**

###### 关闭容器

+ ConfigurableApplicationContext
  + close()
  + registerShutdownHook()

##### 依赖注入方式

+ 向一个类中传递数据的方式有几种？
  + 普通方法（set 方法）
  + 构造方法
+ 依赖注入描述了在容器中建立 bean 与 bean 之间依赖关系的过程，如果 bean 运行需要的是数字或字符串呢？
  + 引用类型
  + 简单类型（基本数据类型与 String）
+ 依赖注入方式
  + setter 注入
    + 简单类型
    + **引用类型**
  + 构造器注入
    + 简单类型
    + 引用类型

**Setter 注入 - 引用类型**

+ 在 bean 中定义引用类型属性并提供可访问的 set 方法

  ```java
  public class BookServiceImpl implements BookService {
      private BookDao bookDao;
      public void setBookDao(BookDao bookDao){
          this.bookDao = bookDao;
      }
  }
  ```

+ 配置中使用 property 标签 ref 属性注入引用类型对象

  ```xml
  <bean id="bookDao" class="com.jerry.dao.impl.BookDaoImpl"/>
  <bean id="bookService" class="com.jerry.service.impl.BookServiceImpl">
      <!--配置 server 与 dao 的关系-->
      <!--name 属性表示配置哪一个具体的属性-->
      <!--ref 属性表示参照哪一个 bean，与 bean id 对应-->
      <property name="bookDao" ref="bookDao"></property>
  </bean>
  ```

**Setter 注入 - 简单类型**

+ 配置文件注入值

  ```xml
  <bean id="userkDao" class="com.jerry.dao.impl.UserDaoImpl"/>
  <bean id="bookDao" class="com.jerry.dao.impl.BookDaoImpl">
      <property name="databaseName" value="mysql"></property>
      <property name="connectionNum" value="10"></property>
  </bean>
  
  <bean id="bookService" class="com.jerry.service.impl.BookServiceImpl">
      <property name="bookDao" ref="bookDao"></property>
      <property name="userDao" ref="userDao"></property>
  </bean>
  ```

+ 在 bean 中定义引用类型属性并提供可访问的 set 方法

  ```java
  public class BookDaoImpl implements BookDao{
      private int connectionNum;
      private String databaseName;
      
      public void setConnectionNum(int connectionNum){
          this.connectionNum = connectionNum;
      }
      public void setDatabaseName(String databaseName){
          this.databaseName = databaseName;
      }
      public void save(){
          System.out.println("book dao save" + databaseName + connectionNum);
      }
  }
  ```


**构造器注入 - 引用类型（了解）**

+ 在 bean 中定义引用类型属性并提供可访问的构造方法
+ 配置中使用 constructor-arg 标签 ref 属性注入引用类型对象

**依赖注入方式选择**

1. 使用 setter 注入进行，灵活性强
2. 如果受控对象没有提供 setter 方法就必须使用构造器注入
3. **自己开发的模块推荐使用 setter 注入**

##### 依赖自动装配

+ IoC 容器根据 bean 所依赖的资源在容器中自动查找并注入到 bean 的过程称为自动装配
+ 自动装配方式
  + 按类型（常用）
  + 按名称
  + 按构造方法
  + 不启用自动装配

+ 配置中使用 bean 标签 autowire 属性设置自动装备的类型

  ```xml
  <bean id="bookDao" class="com.jerry.dao.impl.BookDaoImpl"></bean>
  <bean id="bookService" class="com.jerry.service.impl.BookServiceImpl" autowire="byType"></bean>
  ```

**依赖自动装配特征**

+ 自动装配用于引用类型依赖注入，不能对简单类型进行操作
+ 使用按类型装配时（byType）必须保障容器中相同类型的 bean 唯一（推荐使用）
+ 使用按名称装配时（byName）必须保障容器中具有指定名称的 bean，因为变量名与配置耦合（不推荐使用）
+ 自动装配优先级低于 setter 注入与构造器注入，同时出现时自动装配配置失效

##### 集合注入

```xml
<bean id="bookDao" class="com.jerry.dao.impl.BookDaoImpl">
    <!--array,list,set-->
    <property name="array"> <!--list, set 同理-->
        <array>
            <value>100</value>
            <value>200</value>
        </array>
    </property>
    <!--map-->
    <property name="map">
        <map>
            <entry key="country" value="China"></entry>
            <entry key="province" value="Shanghai"></entry>
        </map>
    </property>
    <!--properties-->
    <property name="properties">
        <props>
            <prop key="country">China</prop>
            <prop key="province">Shanghai</prop>
        </props>
    </property>
</bean>
```

##### 加载 properties 文件

1. 在 applicationContext.xml 中新建 context 命名空间
2. 使用 context 空间加载 properties 文件
3. 使用属性占位符${}读取 properties 文件中的属性

```xml
<beans xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="
                           http://www.springframework.org/schema/context
                           http://www.springframework.org/schema/context/spring-context.xsd"></beans>
<context:property-placeholder location="classpath*:*.properties" system-properties-mode="NEVER"/>
<property name="username" value="${jdbc.username}"
```

#### 核心容器总结

容器相关：

+ BeanFactory 是 IoC 容器的顶层接口，初始化 BeanFactory 对象时，加载的 bean 延迟加载
+ ApplicationContext 接口是 Spring 容器的核心接口，初始化时 bean 立即加载
+ ApplicationContext 接口提供基础的 bean 操作相关方法，通过其他接口扩展其功能
+ ApplicationContext 接口常用初始化类
  + ClassPathXmlApplicationContext
  + FileSystemXmlApplicationContext

Bean 相关：

| <bean          | />                                      |
| -------------- | --------------------------------------- |
| id             | bean 的 id                              |
| name           | bean 别名                               |
| class          | bean 类型，静态工厂类，FactoryBean 类   |
| scope          | 控制 bean 的实例数量                    |
| init-method    | 生命周期初始化方法                      |
| destroy-method | 生命周期销毁方法                        |
| autowire       | 自动装配类型                            |
| factory-method | bean 工厂方法，应用于静态工厂或实例工厂 |
| factory-bean   | 实例工厂 bean                           |
| lazy-init      | 控制 bean 延迟加载                      |

### 注解

```java
@Component("bookDao")
public class BookDaoImpl implements BookDao{
    public void save(){
        print("boook dao save");
    }
}
```

```xml
<context:component-scan base-package="com.jerry"/> <!--扫描 com.jerry 下的所有的包-->
```

@Component 注解代表了原来使用 applicationContext.xml 中的

```xml
<bean id="bookDao" class="com.jerry.dao.impl.BookDaoImpl"/>
```

#### 衍生注解定义 bean

Spring 提供 @Component 注解的三个衍生注解，和 @Component 功能一样，只是方便理解。

+ @Controller：用于表现层 bean 定义
+ @Service：用于业务层 bean 定义
+ @Repository：用于数据层 bean 定义

#### 纯注解开发

+ Spring 3.0 开始了纯注解开发模式，使用 Java 类替代配置文件，开启了 Spring 快速开发

+ Java 类代替 Spring 核心配置文件

  ```java
  @Configuration
  @ComponentScan("com.jerry")
  public class SpringConfig{...}
  ```

  两个注解完全代替了原本的 applicationContext.xml 文件，不需再使用配置文件

+ 读取 Spring 核心配置文件初始化容器对象切换为读取 Java 配置类初始化容器对象

  ```java
  ApplicationContext ctx = new ClassPathXmlApplicationContext("applicationContext.xml");
  ApplicationContext ctx = new AnnotationConfigApplicationContext(SpringConfig.class);
  ```

##### Bean 的作用范围

使用 @Scope 定义 bean 作用范围

使用 @PostConstruct、@PreDestroy 定义 bean 生命周期

```java
@Repository
@Scope("singletion")
public class BookDaoImpl implements BookDao{
    public BookDaoImpl(){print("...")}
    @PostConstruct
    public void init(){print("...")}
    @PreDestroy
    public void destroy(){print("...")}
}
```

##### 依赖注入

使用 @Autowired 注解开启自动装配模式（按类型）

```java
@Service
public class BookServiceImpl implements BookService{
    ////////////////////////////////
    @Autowired
    private BookDao bookDao;
    //@Autowired 代替了 setter 方法
    //public void setBookDao(BookDao bookDao){
    //    this.bookDao = bookDao;
    //}
    ////////////////////////////////
    public void save(){
        bookDao.save();
    }
}
```

注意：

+ 自动装配基于反射设计创建对象并暴力反射对应属性为私有属性初始化数据，因此无需提供 setter 方法
+ 自动装配建议使用无参构造方法创建对象（默认），如果不提供对应构造方法，请提供唯一的构造方法

使用 @Qualifier 注解开启指定名称装配 bean

```java
@Autowired
@Qualifier("bookDao")
private BookDao bookDao;
```

使用 @Value 实现简单类型注入

```java
@Repository("bookDao")
public class BookDaoImpl implements BookDao{
    @Value("100")
    private String connectionNum;
}
```

```java
@Repository("bookDao")
public class BookDaoImpl implements BookDao{
    @Value("${connectionNum}")
    private String connectionNum;
}
```

##### 第三方 bean 管理

将独立的配置类加入核心配置

+ 导入式

```java
public class JdbcConfig{
    @Bean
    public DataSource dataSource(){
        DruidDataSource ds = new DruidDataSource();
        //相关配置
        return ds;
    }
}
```

> 使用 @Import 注解手动加入配置类到核心配置，此注解只能添加一次，多个数据使用数组格式

```java
@Configuration
@Import(JdbcConfig.class)
public class SpringConfig{}
```

##### 第三方 bean 依赖注入

+ 简单类型依赖注入

```java
public class JdbcConfig{
    @Value("com.mysql.jdbc.Driver")
    private String driver;
    @Value("jdbc:mysql://localhost:3306/spring_db")
    private String url;
    //...
    @Bean
    public DataSource dataSource(){
        DruidDataSource ds = new DruidDataSource();
        ds.setDriverClassName(driver);
        ds.setUrl(url);
        return ds;
    } 
}
```

+ 引用类型依赖注入

```java
@Bean
 public DataSource dataSource(BookService bookService){
     print(bookService);
     DruidDataSource ds = new DruidDataSource();
     //属性设置
     return ds;
 }
```

> 引用类型注入只需要为 bean 定义方法设置形参即可，容器会根据类型自动装备对象。

#### 注解总结

+ XML 配置对比注解配置

  | 功能            | XML 配置                                                     | 注解                                                         |
  | --------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
  | 定义 bean       | bean 标签<br />* id 属性<br />* class 属性                   | @Component<br />* @Controller<br />* **@Service** <br />* @Repository<br />**@ComponentScan** |
  | 设置依赖注入    | setter 注入（set 方法）<br />* 引用 / 简单<br />构造器注入（构造方法）<br />* 引用 / 简单<br />自动装配 | **@Autowired** <br />* @Qualifier<br />@Value                |
  | 配置第三方 bean | bean 标签<br />静态工厂、实例工厂、FactoryBean               | **@Bean**                                                    |
  | 作用范围        | scope 属性                                                   | @Scope                                                       |
  | 生命周期        | 标准接口<br />* init-method<br />* destroy-method            | @PostConstructor<br />@PreDestroy                            |

  

### Spring 整合 MyBatis

> MyBatis is a popular, open-source persistence framework for Java that simplifies the process of working with databases.

+ MyBatis 程序核心对象分析

```java
//1. 创建 SqlSessionFactoryBuilder 对象
SQLSessionFactoryBuilder sqlSessionFactoryBuilder = new SqlSessionFactoryBuilder();
//2. 加载 SqlMapConfig.xml 配置文件
InputStream inputStream = Resources.getResourceAsStream("SqlMapConfig.xml");
//3. 创建 SqlSessionFactory 对象
SqlSessionFactory sqlSessionFactory = sqlSeeesionFactoryBuilder.build(inputStream);
//4. 获取 SqlSession
SqlSession sqlSession = sqlSessionFactory.openSession();
//5. 执行 SqlSession 对象执行查询，获取结果 User
AccountDao accountDao = sqlSession.getMapper(AccountDao.class);
Account ac = accountDao.findById(2);
println(ac);
//6. 释放资源
sqlSession.cloase();
```

1. 使用 bean 替换原始的 mybatis-config.xml 中的环境配置

```java
@Bean
public SqlSessionFactoryBean sqlSessionFactory(DataSource dataSource){
    SqlSesssionFactoryBean ssfb = new SqlSessionFactoryBean();
    ssfb.setTypeAliasesPackage("com.jerry.domain");
    ssfb.setDataSource(dataSource);
    return ssfb;
}
```

2. 使用 bean 替换原始的 mybatis-config.xml 中的 mapper 配置

```java
@Bean
public MapperScannerConfigurer mapperScannerConfigurer(){
    MapperScannerConfigurer msc = new MapperScannerConfigurer();
    msc.setBasePackage("com.jerry.dao");
    return msc;
}
```

### Spring 整合 JUnit

+ 使用 Spring 整合 JUnit 专用的类加载器

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = SpringConfig.class)
public class BookServiceTest{
    @Autowired
    private BookService bookService;
    
    @Test
    public void testSave(){
        bookService.save();
    }
}
```

### AOP

+ AOP(Aspect Oriented Programming)面向切面编程，一种编程范式，指导开发者如何组织程序结构
+ 作用：在不惊动原始设计的基础上为其进行功能增强
+ Spring 理念：无侵入式

AOP 核心概念

+ **连接点**（JoinPoint）：程序执行过程中的任意位置，粒度为执行方法、抛出异常、设置变量等
  + 在 SpringAOP 中，理解为方法的执行
+ **切入点**（Pointcut）：匹配连接点的式子
  + 在 SpringAOP 中，一个切入点可以只描述一个具体方法，也可以匹配多个方法
    + 一个具体方法：com.jerry.dao 包下的 BookDao 接口中的无形参无返回值的 save 方法
    + 匹配多个方法：所有的 save 方法，所有的 get 开头的方法，所有以 Dao 结尾的接口中的任意方法，所有带一个参数的方法
+ **通知**（Advice）：在切入点处执行的操作，也就是共性功能
  + 在 SpringAOP 中，功能最终以方法的形式呈现
+ **通知类**：定义通知的类
+ **切面**（Aspect）：描述通知与切入点的对应关系

#### 实例

+ 案例设定：测定接口执行效率
+ 简化设定：在接口执行前输出当前系统时间
+ 开发模式：XML 或 注解
+ 思路分析：
  1. 导入坐标（pom.xml）
  2. 制作连接点方法（原始操作，Dao 接口与实现类）
  3. 制作共性功能（通知类与通知）
  4. 定义切入点
  5. 绑定切入点与通知关系（切面）

```java
public class MyAdvice{
    @Pointcut("execution(void com.jerry.dao.BookDao.update())")
    private void pt(){}
    
    @Before("pt()")
    public void before(){
        println("before the func");
    }
}
```

#### AOP 工作流程

1. Spring 容器启动
2. 读取所有切面配置中的切入点
3. 初始化 bean，判定 bean 对应的类中的方法是否匹配到任意切入点
   + 匹配失败，创建对象
   + 匹配成功，创建原始对象（**目标对象**）的**代理**对象
4. 获取 bean 执行方法
   + 获取 bean，调用方法并执行，完成操作
   + 获取的 bean 是代理对象时，根据代理对象的运行模式运行原始方法与增强的内容，完成操作

> SpringAOP本质：代理模式

#### AOP 切入点表达式

#### AOP 通知类型

AOP 通知共分为 5 种类型

+ 前置通知
+ 后置通知
+ 环绕通知（重点）
+ 返回后通知（了解）
+ 抛出异常后通知（了解）

#### Demo

统计一个方法万次执行时间

```java
@Aspect
public class ProjectAdvice{
    @Pointcut("execution(* com.jerry.service.*Service.*(..))")
    private void servicePt(){}
    
    @Around("servicePt()")
    public void runSpeed(ProceedingJoinPoint pjp) throws Throwable{
        //获取执行签名信息
        Signature signature = pjp.getSignature();
        //通过签名获取执行类型（接口名）
        String className = signature.getDeclaringTypeName();
        //通过签名获取执行操作名称（方法名）
        String methodName = signature.getName();
        
        long start = System.currentTimeMillis();
        for(int i = 0; i < 10000; i++){
            pjp.proceed();
        }
        long end = System.currentTimeMillis();
        println("业务层接口万次执行时间："+ className + methodName + "：" + (end - start) + "ms");
    }
}
```


