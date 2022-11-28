---
title: "Scala Introduction" # Title of the blog post.
date: 2020-02-08T10:16:17+08:00 # Date of post creation.
description: "Article description." # Description used for search engine.
featured: f # Sets if post is a featured post, making appear on the home page side bar.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: true # Controls if a table of contents should be generated for first-level links automatically.
# menu: main
# featureImage: "/images/path/file.jpg" # Sets featured image on blog post.
# thumbnail: "images/code3.png" # 1-13 Sets thumbnail image appearing inside card on homepage.
# shareImage: "/images/path/share.png" # Designate a separate image for social media sharing.
codeMaxLines: 40 # Override global value for how many lines within a code block before auto-collapsing.
codeLineNumbers: true # Override global value for showing of line numbers within code block.
figurePositionShow: true # Override global value for showing the figure label.
categories:
  - Technology
tags:
  - Scala
  - Java
comments: true # Disable comment if false.
---
Scala combines object-oriented and functional programming in one concise, high-level language. Scala's static types help avoid bugs in complex applications, and its JVM and JavaScript runtimes let you build high-performance systems with easy access to huge ecosystems of libraries.
<!--more-->

## 1. REPL & Scaladoc

Scala解释器读到一个表达式，对它进行求值，将它打印出来，接着再继续读下一个表达式。这个过程被称做Read-Eval-Print-Loop，即：REPL。
从技术上讲，scala程序并不是一个解释器。实际发生的是，你输入的内容被快速地编译成字节码，然后这段字节码交由Java虚拟机执行。正因为如此，大多数scala程序员更倾向于将它称做“REPL”



scala api文档，包含了scala所有的api以及使用说明，class、object、trait、function、method、implicit等

为什么要查阅Scaladoc：如果只是写一些普通的Scala程序基本够用了；但是如果（在现在，或者未来，实际的工作环境中）要编写复杂的scala程序，那么还是需要参考Scaladoc的。（纯粹用scala开发spark应用程序，应该不会特别复杂；用scala构建类似于spark的公司内的分布式的大型系统）

以下是一些Scaladoc使用的tips：

1. 直接在左上角的搜索框中，搜索你需要的寻找的包、类即可
2. C和O，分别代表了类和伴生对象的概念
3. t和O，代表了特制(trait)(类似于Java的接口)
4. 标记为implicit的方法，代表的是隐式转换
5. 举例：搜索StringOps，可以看到String的增强类，StringOps的所有方法说明

## 2. Data Type

### 2.1 Data Type

| 数据类型 | 描述                                                         |
| :------- | :----------------------------------------------------------- |
| Byte     | 8位有符号补码整数。数值区间为 -128 到 127                    |
| Short    | 16位有符号补码整数。数值区间为 -32768 到 32767               |
| Int      | 32位有符号补码整数。数值区间为 -2147483648 到 2147483647     |
| Long     | 64位有符号补码整数。数值区间为 -9223372036854775808 到 9223372036854775807 |
| Float    | 32 位, IEEE 754 标准的单精度浮点数                           |
| Double   | 64 位 IEEE 754 标准的双精度浮点数                            |
| Char     | 16位无符号Unicode字符, 区间值为 U+0000 到 U+FFFF             |
| String   | 字符序列                                                     |
| Boolean  | true或false                                                  |
| Unit     | 表示无值，和其他语言中void等同。用作不返回任何结果的方法的结果类型。Unit只有一个实例值，写成()。 |
| Null     | null 或空引用                                                |
| Nothing  | Nothing类型在Scala的类层级的最底端；它是任何其他类型的子类型。 |
| Any      | Any是所有其他类的超类                                        |
| AnyRef   | AnyRef类是Scala里所有引用类(reference class)的基类           |

### 2.2 val、var & Lazy Value

1. 内容是否可变：val修饰的是不可变的，var修饰是可变的
2. val修饰的变量在编译后类似于java中的中的变量被final修饰
3. lazy修饰符可以修饰变量，但是这个变量必须是val修饰的

ps. lazy相当于延迟加载（懒加载），当前变量使用lazy修饰的时候，只要变量不被调用，就不会进行初始化，什么时候调用，什么时候进行初始化

```scala
lazy val words = scala.io.Source.fromFile("/usr/share/dict/words").mkString
//当val被声明为lazy时，它的初始化将被推迟，直到我们首次对他取值
```

懒值对于开销大的初始化语句十分有用。它还可以用来应对其他初始化问题，比如循环依赖。更重要的是，它是开发懒数据结构的基础。

```scala
val words = ...
//在words被定义时即被取值
lazy val words = ...
//在words被首次使用时取值
def words = ...
//在每一次words被使用时取值
```

## 3. Control and Function

1. if表达式也有值
2. 块也有值：是它最后一个表达式的值
3. Scala的for循环就像是“增强版”的Java for循环
4. 分好在绝大数情况下不是必须的
5. void类型是Unit
6. 避免在函数使用return
7. 注意别再函数式定义中使用return
8. 异常的工作方式和Java或C++基本一样，不同的是你在catch语句中使用“模式匹配”
9. Scala没有受检异常

## 4. Array

1. 若长度固定可用Array，若长度可能有变化则使用ArrayBuffer
2. 提供初始值时不要使用new
3. 用()来访问元素
4. 用for(elem <- arr)来遍历元素
5. 用for(elem <- arr if ...) yield ... 来将原数据转型为新数组
6. Scala数组和Java数组可以相互操作，用ArrayBuffer，使用scala.collection.JavaConversions中的转换函数

## 5. Map and Tuple

1. Scala有十分易用的语法来创建、查询和遍历映射(Map)
2. 你需要从可变的和不可变的映射中做出选择
3. 默认情况下，你得到的是一个哈希映射(Hash Map)，不过你也可以指明要树形映射
4. 你可以很容易地在Scala映射和Java映射之间来回切换
5. 元组可以用来聚集值

## 6. Class

1. 类中的字段自动带有getter方法和setter方法
2. 可以用定制的getter/setter方法替换掉字段的定义，而不必修改使用类的客户端——这就是所谓的“统一访问原则”
3. 用@BeanProperty注解来生成JavaBeans的get\*/set\*方法
4. 每个类都有一个主要的构造器，这个构造器和类定义"交织"在一起。它的参数直接为类的字段。主构造器执行类体中所有的语句
5. 辅助构造器是可选的。他们叫做this

## 7. Object

1. 对象作为单例或存放工具方法
2. 类可以拥有一个同名的伴生对象
3. 对象可以扩展类或特质
4. 对象的apply方法通常用来构造伴生类的新实例
5. 如果不想显示定义main方法，可以用扩展App特质的对象
6. 可以通过扩展Enumeration对象来实现枚举

## 8. Package

1. 包也可以像内部类那样嵌套
2. 包路径不是绝对路径
3. 包声明链x.y.z并不自动将中间包x和x.y变成可见
4. 位于文件顶部不带花括号的包声明在整个文件范围内有效
5. 包对象可以持有函数和变量
6. 引入语句可以引入包、类和对象
7. 引入语句可以出现在任何位置
8. 引入语句可以重命名和隐藏特定成员
9. java.lang、scala和predef总是被引入

## 9. Extends

1. extends、final关键字和Java中相同
2. 重写方法时必须用override
3. 只有主构造器可以用超类的主构造器
4. 可以重写字段

## 10. File&Regex

1. Source.fromFile(...).getLines.toArray将交出文件的所有行
2. Source.fromFile(...).mkString将以字符串形式交出文件内容
3. 将字符串转化为数字，可以用toInt或toDouble方法
4. 使用Java的PrintWriter来写入文本文件
5. "正则".r是一个Regex对象
6. 如果你的正则表达式包含反斜杠的话，用"""..."""
7. 如果正则模式包含分组，你可以用如下语法来提取它们的内容for(regex(变量1,...,变量n) <- 字符串)

## 11. Feature

1. 类可以实现任意数量的特质
2. 特质可以要求实现它们的类具备特定的字段、方法或超类
3. 和Java接口不同，Scala特质可以提供方法和字段的实现
4. 当将多个特质叠加在一起时，顺序很重要——其方法先被执行啊的特质排在更后面

## 12. Advanced function

1. 函数可以直接赋值给变量，就和数字一样
2. 可以创建匿名函数，通常还会把它们交给其他函数
3. 函数参数可以给出需要稍后执行的行为
4. 许多集合方法都接受函数参数，将函数应用到集合中的值
5. 有很多语法上的简写让你以简短且易读的方式表达函数参数
6. 可以创建操作代码块的函数，它们看上去就像是内建的控制语句

## 13. Collection

1. 所有集合都扩展自Iterable特质
2. 集合有三大类，分别为序列、集合映射
3. 对于几乎所有集合类，Scala都同时提供了可变的和不可变的版本
4. Scala列表要么是空的，要么拥有一头一尾，其中尾部本身又是一个列表
5. 集是无先后次序的集合
6. 用LinkedHashSet保留插入顺序，或者用SortedSet按顺序进行迭代
7. +将元素添加到无先后次序的集合中；+:和:+向前或向后追加到序列；++将两个集合串接在一起；-和--移除元素
8. 映射、折叠和拉链操作是很有用的技巧，用来将函数或操作应用到集合中的元素

## 14. Pattern match

1. match表达式是一个更好的switch，不会有意外掉入下一个分支的问题
2. 如果没有模式能够匹配，会抛出MatchError。可以用case _模式来避免
3. 模式可以包含一个随意定义的条件，称作守卫（guard）
4. 可以对表达式的类型进行匹配；优先选择模式匹配而不是isInstanceOf/asInstanceOf
5. 可以匹配数组、元组和样例类的模式，然后将匹配到的不同部分绑定到变量
6. 在for表达式中，不能匹配的情况会被安静地跳过
7. 样例类是是编译器会为之自动产出模式匹配所需要的方法的类
8. 样例类继承层级中的公共超类应该是sealed的
9. 用Option来存放对于可能存在也可能不存在的值——比null更安全

## 15. Annotation

1. 可以为类、方法、字段、局部变量、参数、表达式、类型参数以及各种类型定义添加注解
2. 对于表达式和类型，注解跟在被注解的条目之后
3. 注解的形式有 @Annotation、@Annotation(value)或@Annotation(name = value1, ...)
4. @volatile、@transient、@strictfp和@native分别生成等效的Java修饰符
5. 用@throws来生成与Java兼容的throws规格说明
6. @tailrec注解让你校验某个递归函数使用了尾递归优化
7. assert函数利用了@elidable注解。你可以选择从Scala程序中移除所有断言
8. 用@deprecated注解来标记已过时的特性

## 16. XML

1. XML字面量<like>this</like>的类型为NodeSeq
2. 可以在XML里字面量中嵌套Scala代码
3. Node的child属性交出的是子节点
4. Node的attributes属性交出的是包含节点属性的MetaData对象
5. \和\\操作符执行类XPath匹配