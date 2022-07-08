---
title: "Python Introduction" # Title of the blog post.
date: 2019-05-10T09:34:11+08:00 # Date of post creation.
description: "Article description." # Description used for search engine.
featured: false # Sets if post is a featured post, making appear on the home page side bar.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: true # Controls if a table of contents should be generated for first-level links automatically.
# menu: main
# featureImage: "/images/path/file.jpg" # Sets featured image on blog post.
# thumbnail: "images/code2.png" # 1-13 Sets thumbnail image appearing inside card on homepage.
# shareImage: "/images/path/share.png" # Designate a separate image for social media sharing.
codeMaxLines: 40 # Override global value for how many lines within a code block before auto-collapsing.
codeLineNumbers: true # Override global value for showing of line numbers within code block.
figurePositionShow: true # Override global value for showing the figure label.
categories:
  - Technology
tags:
  - Python
comments: true # Disable comment if false.
---
Python is dynamically-typed and garbage-collected. It supports multiple programming paradigms, including structured (particularly, procedural), object-oriented and functional programming. Python is often described as a "batteries included" language due to its comprehensive standard library. 
<!--more-->

## 1. 数据类型转换

|        |      整型       |        浮点         |  bool  |   复数   | string |        list        |       tuple        |           set           |        dict         |
| :----: | :-------------: | :-----------------: | :----: | :------: | :----: | :----------------: | :----------------: | :---------------------: | :-----------------: |
|  整型  |        \        |        加.0         | int(0) |   加0j   |  任意  |         ×          |         ×          |            ×            |          ×          |
|  浮点  |     去小数      |          \          |  0.0   |   加0j   |  数据  |         ×          |         ×          |            ×            |          ×          |
|  bool  | true1<br>false0 | true1.0<br>false0.0 |   \    | true1+0j |  可以  |         ×          |         ×          |            ×            |          ×          |
|  复数  |        ×        |          ×          |   0j   |    \     |  转换  |         ×          |         ×          |            ×            |          ×          |
| string |     纯数字      |       纯数字        |   ''   | 纯数&+0j |   \    | 每个字符转成每个值 | 每个字符转成每个值 | 每个字符转成每个值+去重 |          ×          |
|  list  |        ×        |          ×          |   []   |    ×     |  成为  |         \          |      内容不变      |        随机+去重        | 有2个数据的二级列表 |
| tuple  |        ×        |          ×          |   ()   |    ×     |  str   |      内容不变      |         \          |        随机+去重        | 有2个数据的二级列表 |
|  set   |        ×        |          ×          | set()  |    ×     |  格式  |   内容不变+随机    |   内容不变+随机    |            \            | 有2个数据的二级列表 |
|  dict  |        ×        |          ×          |   {}   |    ×     |  数据  |      仅保留键      |      仅保留键      |        仅保留键         |          \          |

## 2. 身份运算

判断地址是否相同

```python
x is y
x is not y
1.字符串：字符串值相同，ID相同。
2.列表、字典、集合：无论什么情况ID都不同
```

## 3. 成员检测运算

```python
val1 in val2 
val1 not in val2 
//检测一个数据是否在容器中
```

## 4. 流程控制

```python
1.
if ___:
elif ___:
elif ___:
else:
2.
while ___:
else:
3.
for x in 容器:
```

## 5. 函数

| def  | func( | name,     | sex = "male", | *args,          | like = "乒乓",   | **kwargs);                        |
| ---- | ----- | --------- | ------------- | --------------- | ---------------- | --------------------------------- |
|      | ↓     | ↓         | ↓             | ↓               | ↓                | ↓                                 |
|      | func( | "刘佳锐", | "男",         | "乐色", "垃圾", | like = "羽毛球", | skin = "yellow", hobby = "hello") |

```python
print(locals()) //获取当前作用域的局部变量
print(globals()) //获取当前作用域的全局变量
```

## 6. 迭代器

1. 能被next()函数调用并不断返回下一个值的对象
2. 特征：迭代器会生成惰性序列，通过计算把值依次返回
3. 优点：需要数据的时候，一次取一个可以很大节省内存
4. 检测：
   1. from collections import Iterable, Iterator
   2. isinstance()判断数据类型，返回bool值
   3. print(isinstance(list1,list1))
5. Iter：使用iter可把迭代数据变为迭代器

```python
list1 = [1,2,3]
result = iter(list1)
print(next(result))
```

