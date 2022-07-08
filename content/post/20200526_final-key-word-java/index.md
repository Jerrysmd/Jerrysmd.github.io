---
title: "The Final Key Word In Java" # Title of the blog post.
date: 2020-05-26T15:56:36+08:00 # Date of post creation.
description: "Article description." # Description used for search engine.
featured: false # Sets if post is a featured post, making appear on the home page side bar.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: true # Controls if a table of contents should be generated for first-level links automatically.
# menu: main
# featureImage: "/images/path/file.jpg" # Sets featured image on blog post.
# thumbnail: "images/code1.png" # Sets thumbnail image appearing inside card on homepage. # analysis cloud code1 code2 code3 data1 data2 distribution file github linux search
# shareImage: "/images/path/share.png" # Designate a separate image for social media sharing.
codeMaxLines: 40 # Override global value for how many lines within a code block before auto-collapsing.
codeLineNumbers: true # Override global value for showing of line numbers within code block.
figurePositionShow: true # Override global value for showing the figure label.
categories:
  - Technology
tags:
  - java
comments: true # Disable comment if false.
---
Final key word no doubt be mentioned most time in Java language. There are some points about final key word. First of all, final key word can modify three objects: first is modify variables, second is modify way, third is modify class.
<!--more-->

## final 关键字修饰变量

在使用final修饰变量时，又可以分为两种情况：一种是基本数据类型的变量，另一种是引用类型的变量。final关键字在修饰基本数据类型时必须对变量赋予初始值，因此final也常常和static关键字一起用来声明常量值。final正好限制了必须赋值，static声明了静态变量。

```java
final static String str = "Hollow world";
```

修饰引用变量时，该引用变量如果已经被赋值则不可以再被赋值，否则也会出现不能编译的情况

```java
//定义一个main对象并实例化
final Main main = new Main();
//被final关键字修饰后，再次对Main对象进行赋值就会报错
main = new Main();
```

## final关键字修饰方法

通过final修饰的方法是不能被子类的方法重写的。一般情况下，一个方法确定好不再修改可以使用final，因为final修饰的方法是在程序编译的时候就被动态绑定了不用等到程序运行的时候被动态绑定，这样就大大提高了执行效率。

```java
public final void method(){
	System.out.println("It is final method");
}
```

## final关键字修饰类

被final修饰的类叫final类，final类是不能被继承的，这也就以为这final类的功能是比较完整的。因此，jdk中有很多类使用final修饰的，它们不需要被继承，其中，最常见的就是String类。

```java
public final class String implements java.io.Serializable, Comparable<String>
```

```java
public final class Integer extends Number implements ...
```

```java
public final class Long extends Number implements ...
```

包括其他的装饰类都是被final关键字修饰的，它自身提供的方法和功能也是非常完备的。

## static关键字的不同

final static 成对出现的频率也是比较高的，使用static修饰的变量只会在类加载的时候被初始化，不会因为对象的再次创建而改变。

```java
static double num = Math.random();
```

