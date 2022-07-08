---
title: "C Project performance optimization" # Title of the blog post.
date: 2019-04-09T20:04:00+08:00 # Date of post creation.
description: "Article description." # Description used for search engine.
featured: true # Sets if post is a featured post, making appear on the home page side bar.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: true # Controls if a table of contents should be generated for first-level links automatically.
# menu: main
# featureImage: "/images/path/file.jpg" # Sets featured image on blog post.
# thumbnail: "images/code1.png" # Sets thumbnail image appearing inside card on homepage.
# shareImage: "/images/path/share.png" # Designate a separate image for social media sharing.
codeMaxLines: 40 # Override global value for how many lines within a code block before auto-collapsing.
codeLineNumbers: true # Override global value for showing of line numbers within code block.
figurePositionShow: true # Override global value for showing the figure label.
categories:
  - Technology
tags:
  - c
# comment: false # Disable comment if false.
---
Performance optimization methods and ideas for large C projects. Performance optimization strategies for x86 projects that encounter performance bottlenecks when porting to low performance processors. 
<!--more-->
## 通常优化方法
### 1. 宏定义或内联
  * 短的、调用频繁的函数改为宏定义或内联函数，减少调用层级
  * 可能编译器已经做了部分优化，效果不一定明显
### 2. 固定次数的短循环展开
  * 循环语句如果循环次数已知，且是短循环，可以将语句展开
  * 编译器可能已做优化，效果不一定明显
### 3. 减少内存分配和释放的次数
  * 频繁使用的变量能用全局变量的尽量不用局部变量
  * 函数体内部的局部变量，如果大小不是特别大，尽量不用动态分配空间
  * 数据结构中，尽量不用指针变量
### 4. 移位代替乘除
### 5. 条件语句优化
  * 根据分支被执行的频率将频繁执行的分支放在前面部分
### 6. 数据结构/算法
  * 数据结构中尽量减少需要动态分配空间的指针，改用联合、结构体或固定大小的缓存区
### 7. 使用并行程序
## 代码重构原则
* 维护一套代码，使用宏定义控制
* 小步前进，重构一部分进行充分测试后再重构下一部分

