---
title: "Spring Framework Intro"
# subtitle: ""
date: 2022-08-05T11:38:27+08:00
# lastmod: 2022-11-28T11:38:27+08:00
draft: false
# author: ""
# authorLink: ""
# description: ""
# license: ""
# images: []

tags: ["Java", "Spring"]
categories: ["Technology"]

# featuredImage: ""
# featuredImagePreview: ""

hiddenFromHomePage: false
hiddenFromSearch: false
# twemoji: false
# lightgallery: true
# ruby: true
# fraction: true
# fontawesome: true
# linkToMarkdown: true
# rssFullText: false

# toc:
#   enable: true
#   auto: true
# code:
#   copy: true
#   maxShownLines: 50
# math:
#   enable: false
#   # ...
# mapbox:
#   # ...
# share:
#   enable: true
#   # ...
# comment:
#   enable: true
#   # ...
# library:
#   css:
#     # someCSS = "some.css"
#     # located in "assets/"
#     # Or
#     # someCSS = "https://cdn.example.com/some.css"
#   js:
#     # someJS = "some.js"
#     # located in "assets/"
#     # Or
#     # someJS = "https://cdn.example.com/some.js"
# seo:
#   images: []

# admonition:
# {{< admonition tip>}}{{< /admonition >}}
# note abstract info tip success question warning failure danger bug example quote
# mermaid:
# {{< mermaid >}}{{< /mermaid >}}
---

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

### IoC & DI

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

#### IoC Intro Case

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

#### DI Intro Case

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
>
> 
