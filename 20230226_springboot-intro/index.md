# Spring Boot Introduction


Spring Boot makes it easy to create stand-alone, production-grade Spring based Applications that you can "just run". Spring Boot takes an opinionated view of building production-ready Spring applications. Favors convention over configuration and is designed to get you up and running as quickly as possible.

<!--more-->

## Incremental Example

### 开发过程对比

+ 原生开发 SpringMVC 程序过程

   {{< admonition tip "SpringMVC Example" false>}}

1. 依赖最基本的 API![image-20230621162753089](image-20230621162753089.png " ")

2. WEB 3.0 的配置类

   ![image-20230626102749800](image-20230626102749800.png " ")

3. Spring 的配置类

   ![image-20230626102928960](image-20230626102928960.png " ")

4. 开发 Controller 类

   ![image-20230626103209003](image-20230626103209003.png " ")

{{< /admonition >}}

+ Spring boot 开发程序过程

   {{< admonition tip "Spring Boot Example" true>}}

1. Spring Initializr 创建项目

2. 开发 Controller 类。运行自动生成的 Application 类

   ![image-20230626103209003](image-20230626103209003.png " ")

{{< /admonition >}}

### 程序对比

Spring 程序与 SpringBoot 程序对比

|       类 / 配置文件       |  Spring  | SpringBoot |
| :-----------------------: | :------: | :--------: |
|         pom 坐标          | 手工添加 |  勾选添加  |
|      web 3.0 配置类       | 手工制作 |     无     |
| Spring / SpringMVC 配置类 | 手工制作 |     无     |
|          控制器           | 手工制作 |  手工制作  |

### SpringBoot 项目快速启动

![image-20230628192957700](image-20230628192957700.png " ")

+ 第一步：对 Boot 项目打包，执行 Maven 构建指令 package

+ 第二步：执行启动指令

  `java -jar springboot.jar`

![image-20230628194011356](image-20230628194011356.png " ")

