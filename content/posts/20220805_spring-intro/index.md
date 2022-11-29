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

> IoC Intro Case 步骤
>
> ```xml
> <!--pom.xml-->
> <!--Mavern文件-->
> <!--1.导入 spring-context-->
> ```
>
> 
