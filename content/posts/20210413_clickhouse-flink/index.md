---
title: "Data Warehouse: ClickHouse With Flink"
# subtitle: ""
date: 2021-04-13T17:55:21+08:00
# lastmod: 2022-07-18T17:55:21+08:00
draft: false
# author: ""
# authorLink: ""
# description: ""
# license: ""
# images: []

tags: ["DataWarehouse", "ClickHouse"]
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
#   # ...
---

There are systems that can store values of different columns separately, but that can’t effectively process analytical queries due to their optimization for other scenarios. Examples are HBase and BigTable. You would get throughput around a hundred thousand rows per second in these systems, but not hundreds of millions of rows per second.

<!--more-->

## MergeTree 选型

### ReplacingMergeTree

在 MergeTree 的基础上，添加了 “处理重复数据” 的功能，该引擎和 MergeTree 的不同之处在于它会删除具有相同主键的重复项。使用 `order by` 使用的字段来规定去重字段。

### SummingMergeTree

在 MergeTree 的基础上，添加了 “合并重复数据” 的功能，会把具有相同主键的行合并为一行，该行包含了被合并的行中具有数值数据类型的列的汇总值。

### 选型

{{< admonition info ReplacingMergeTree>}}

+ 使用 SummingMergeTree 不能保证数据准确性，如中断重启数据会重新进来合并。
+ 解决数据合并的方式有很多。

{{< /admonition>}}
