---
title: "Static Keyword in Java" # Title of the blog post.
date: 2020-01-22T11:20:11+08:00 # Date of post creation.
description: "Article description." # Description used for search engine.
featured: false # Sets if post is a featured post, making appear on the home page side bar.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: true # Controls if a table of contents should be generated for first-level links automatically.
# menu: main
# featureImage: "/images/path/file.jpg" # Sets featured image on blog post.
# thumbnail: "images/code2.png" # Sets thumbnail image appearing inside card on homepage.
# shareImage: "/images/path/share.png" # Designate a separate image for social media sharing.
codeMaxLines: 40 # Override global value for how many lines within a code block before auto-collapsing.
codeLineNumbers: true # Override global value for showing of line numbers within code block.
figurePositionShow: true # Override global value for showing the figure label.
comments: true # Disable comment if false.
categories:
  - Technology
tags:
  - Java
---
The static keyword can be used for variables, methods, code blocks, and inner classes to indicate that a particular member belongs only to a class itself, and not to an object of that class.
<!--more-->

## 1. Static Variable

静态变量也叫类变量，它属于一个类，而不是这个类的对象。

```java
public class Writer {
    private String name;
    private int age;
    public static int countOfWriters;

    public Writer(String name, int age) {
        this.name = name;
        this.age = age;
        countOfWriters++;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public int getAge() {
        return age;
    }
    public void setAge(int age) {
        this.age = age;
    }
}
```

其中，countOfWriters 被称为静态变量，它有别于 name 和 age 这两个成员变量，因为它前面多了一个修饰符 `static`。

这意味着无论这个类被初始化多少次，静态变量的值都会在所有类的对象中共享。

```java
Writer w1 = new Writer("沉默王二",18);
Writer w2 = new Writer("沉默王三",16);
System.out.println(Writer.countOfWriters);
```

按照上面的逻辑，你应该能推理得出，countOfWriters 的值此时应该为 2 而不是 1。从内存的角度来看，静态变量将会存储在 Java 虚拟机中一个名叫“Metaspace”（元空间，Java 8 之后）的特定池中。

静态变量和成员变量有着很大的不同，成员变量的值属于某个对象，不同的对象之间，值是不共享的；但静态变量不是的，它可以用来统计对象的数量，因为它是共享的。就像上面例子中的 countOfWriters，创建一个对象的时候，它的值为 1，创建两个对象的时候，它的值就为 2。

Summary:

1. 由于静态变量属于一个类，所以不能通过对象引用来访问，而应该直接通过类名来访问；

```java
w1.countOfWriters #不应该通过类实例访问静态成员
```

2. 不需要初始化类就可以访问静态变量。

```java
public static void main(String[] args) {
        System.out.println(Writer.countOfWriters); // 输出 0
    }
```



## 2. Static Method

静态方法也叫类方法，它和静态变量类似，属于一个类，而不是这个类的对象。

```java
public static void setCountOfWriters(int countOfWriters) {
    Writer.countOfWriters = countOfWriters;
}
```

`setCountOfWriters()` 就是一个静态方法，它由 static 关键字修饰。

如果你用过 java.lang.Math 类或者 Apache 的一些工具类（比如说 StringUtils）的话，对静态方法一定不会感动陌生。

Math 类的几乎所有方法都是静态的，可以直接通过类名来调用，不需要创建类的对象。

```java
Math.
    random()
    abs(int a)
    sin(double a)
    cos(double a)
    ...
```

Summary:

1. Java 中的静态方法在编译时解析，因为静态方法不能被重写（方法重写发生在运行时阶段，为了多态）。
2. 抽象方法不能是静态的。

```java
static abstract void paly(); #修饰符abstract 和 static的组合非法
```

3. 静态方法不能使用 this 和 super 关键字。
4. 成员方法可以直接访问其他成员方法和成员变量。
5. 成员方法也可以直接方法静态方法和静态变量。
6. 静态方法可以访问所有其他静态方法和静态变量。
7. 静态方法无法直接访问成员方法和成员变量。

## 3. Static Code Block

静态代码块可以用来初始化静态变量，尽管静态方法也可以在声明的时候直接初始化，但有些时候，我们需要多行代码来完成初始化。

```java
public class StaticBlockDemo {
    public static List<String> writes = new ArrayList<>();

    static {
        writes.add("a");
        writes.add("b");
        writes.add("c");

        System.out.println("第一块");
    }

    static {
        writes.add("d");
        writes.add("e");

        System.out.println("第二块");
    }
}
```

writes 是一个静态的 ArrayList，所以不太可能在声明的时候完成初始化，因此需要在静态代码块中完成初始化。

Summary:

1. 一个类可以有多个静态代码块。
2. 静态代码块的解析和执行顺序和它在类中的位置保持一致。为了验证这个结论，可以在 StaticBlockDemo 类中加入空的 main 方法，执行完的结果如下所示：

```java
第一块
第二块
```

## 4. Static Inner Class

Java 允许我们在一个类中声明一个内部类，它提供了一种令人信服的方式，允许我们只在一个地方使用一些变量，使代码更具有条理性和可读性。

常见的内部类有四种，成员内部类、局部内部类、匿名内部类和静态内部类。

静态内部类：

```java
public class Singleton {
    private Singleton() {}

    private static class SingletonHolder {
        public static final Singleton instance = new Singleton();
    }

    public static Singleton getInstance() {
        return SingletonHolder.instance;
    }
}
```

以上这段代码是不是特别熟悉，对，这就是创建单例的一种方式，第一次加载 Singleton 类时并不会初始化 instance，只有第一次调用 `getInstance()` 方法时 Java 虚拟机才开始加载 SingletonHolder 并初始化 instance，这样不仅能确保线程安全也能保证 Singleton 类的唯一性。不过，创建单例更优雅的一种方式是使用枚举。

Summary:

1. 静态内部类可以访问外部类的所有成员变量，包括私有变量。
2. 外部类不能声明为 static。

