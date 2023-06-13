# Mastering Maven: Advanced Techniques and Best Practices


This article delves into advanced techniques and best practices for using Maven, a popular build automation tool for Java projects. Topics covered include module development and design, dependency management, aggregation and inheritance, property management, and multi-environment configuration and deployment. Whether you're a seasoned Maven user or just getting started, this article will provide valuable insights to streamline your development process and improve your project's overall quality.

<!--more-->

## 分模块开发与设计

### 分模块开发意义

![image-20230612175146310](image-20230612175146310.png " ")

![image-20230612175345645](image-20230612175345645.png " ")

![image-20230612175744597](image-20230612175744597.png " ")

### 分模块开发与设计

#### 目前 SSM 目录

+ 📂src.main.java.com.jerry
  + 📂config
    + ☕JdbcConfig
    + ☕MyBatisConfig
    + ☕ServletConfig
    + ☕SpringConfig
    + ☕SpringMvcConfig
    + ☕SpringMvcSupport
  + 📂controller
    + ☕BookController
    + ☕Code
    + ☕ProjectExceptionAdvice
    + ☕Result
  + 📂dao
    + 📂impl
    + ☕BookDao
  + 📂domain
    + ☕Book
  + 📂exception
  + 📂service
    + 📂impl
    + ☕BookService

#### 分模块需求

业务扩张，domain 需要拆分成新的 Module

(所有的功能都可以拆分成新 Module，这里以 domain 为例)

#### 分模块步骤

1. 创建新的 Pojo Module, 并将 **SSM Module** 的 domain 文件迁移到新 **Pojo Module**

   + Pojo(Plain Old Java Object): 轻量级的 Java Bean，通常只包含私有属性、getter 和 setter 方法以及无参构造函数
   + 在 SSM 架构中，通常将 POJO 用作数据传输对象（DTO）或持久化对象（PO）
   + 与 POJO 相对应的是领域对象（domain object），也称为实体对象（entity），它代表应用程序的业务实体，通常包含业务逻辑和状态信息 

2. 此时 SSM 项目在所有用到 domain 对象的地方都报错，如：`public boolean save(Book book)`, 需要在 SSM Module 的 pom 文件中引入 Pojo Module

   + 在 SSM pom 文件中引入 Pojo 作为依赖

     ```xml
     <!--SSM pom 依赖-->
     <dependency>
         <groupId>com.jerry</groupId>
         <artifactId>pojo_module</artifactId>
         <version>1.0-SNAPSHOT</version>
     </dependency>
     ```

## 依赖管理

### 依赖传递

![image-20230613164639347](image-20230613164639347.png " ")

![image-20230613163454510](image-20230613163454510.png " ")

+ 目前项目中，在 SSM，Pojo 和 Dao 三个Module POM 文件中，SSM 依赖了 Pojo 和 Dao
+ 而 Dao 本身也依赖了 Pojo
+ 根据依赖传递，SSM POM 文件中可以不写 Pojo 依赖

![image-20230613170907554](image-20230613170907554.png " ")

### 可选依赖

### 排除依赖

## 聚合与继承

## 属性管理

## 多环境配置与应用

## 私服

