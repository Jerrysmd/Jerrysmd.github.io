---
title: "Unveiling the Top Frequency Leetcode and Crafting Effective Solutions"
# subtitle: ""
date: 2023-01-01T10:41:45+08:00
draft: false
# author: ""
# authorLink: ""
# description: ""
# license: ""
# images: []

tags: ["Java", "Algorithm"]
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

<!--more-->

## 146.LRU缓存机制

### 关键字

| 关键字                        | 对应信息                                    |
| ----------------------------- | ------------------------------------------- |
| 键值对                        |                                             |
| put 和 get 的时间复杂度为O(1) | 哈希表，而且可以通过 O(1) 时间通过键找到值  |
| 有出入顺序                    | 首先想到 栈，队列 和 链表。哈希表无固定顺序 |

### 补充

哈希链表 `LinkedHashMap` 直接满足要求

### 解题

+ 哈希表可以满足 O(1) 查找；

+ 链表有顺序之分，插入删除快，但是查找慢。

于是就有了哈希链表数据结构：

![img](1647580694-NAtygG-4.jpg " ")

> **为什么使用双链表而不使用单链表？**
>
> 删除操作也可能发生在链表的中间位置。如果使用单链表，删除节点时需要额外找到被删除节点的前驱节点，这会增加时间复杂度。

> 哈希表中已经存了 `key`，为什么链表中还要存 `key` 和 `val` 呢，只存 `val` 不就行了？
