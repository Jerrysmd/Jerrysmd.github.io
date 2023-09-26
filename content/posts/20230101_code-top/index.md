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

| 关键字                                                       | 对应信息                                                     |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| 键值对                                                       | 立马想到哈希表，而且可以通过O(1)时间通过键找到值             |
| 有出入顺序<br />(访问，插入数据的时间先后顺序)               | 首先想到 栈，队列 和 链表                                    |
| 更新数据顺序<br />(题目要求 get, put 后数据要被设置为最新数据) | 1.说明要求可以随机访问<br />2.需要把数据插入到头部或者尾部<br />使用哈希表可以实现复杂度为O(1)的随机访问，如果哈希表的值包含链表的位置信息，那么就可以对链表进行O(1)随机访问。链表的顺序可以看做访问时间顺序，所以链表中的元素必须储存键，这样才能通过键找到哈希表的元素进而实现删除要求 |

### 补充
