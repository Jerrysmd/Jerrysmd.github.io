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

###### 第三方 bean 管理

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

+ 使用 @Import 注解手动加入配置类到核心配置，此注解只能添加一次，多个数据使用数组格式

```java
@Configuration
@Import(JdbcConfig.class)
public class Sp
```


