---
title: "HDFS NFS Gateway: Benefits, Configuration, and Usage" # Title of the blog post.
date: 2020-03-26T11:02:36+08:00 # Date of post creation.
description: "Article description." # Description used for search engine.
featured: false # Sets if post is a featured post, making appear on the home page side bar.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: true # Controls if a table of contents should be generated for first-level links automatically.
# menu: main
# featureImage: "/images/path/file.jpg" # Sets featured image on blog post.
# thumbnail: "images/data1.png" # 1-13 Sets thumbnail image appearing inside card on homepage.
# shareImage: "/images/path/share.png" # Designate a separate image for social media sharing.
codeMaxLines: 40 # Override global value for how many lines within a code block before auto-collapsing.
codeLineNumbers: true # Override global value for showing of line numbers within code block.
figurePositionShow: true # Override global value for showing the figure label.
categories:
  - Technology
tags:
  - Hdfs
  - NFS
  - Distribution
comments: true # Disable comment if false.
---
The major difference between the two is Replication/Fault Tolerance. HDFS was designed to survive failures. NFS does not have any fault tolerance built in. Other than fault tolerance, HDFS does support multiple replicas of files. This eliminates (or eases) the common bottleneck of many clients accessing a single file. Since files have multiple replicas, on different physical disks, reading performance scales better than NFS.
<!--more-->

## NFS

**NFS (Network** **File system**): A protocol developed that allows clients to access files over the network. NFS clients allow files to be accessed as if the files reside on the local machine, even though they reside on the disk of a networked machine.

In **NFS**, the data is stored only on one main system. All the other systems in that network can access the data stored in that as if it was stored in their local system. But the problem with this is that, if the main system goes down, then the data is lost and also, the storage depends on the space available on that system. 

## HDFS

**HDFS (Hadoop Distributed File System):** A file system that is distributed amongst many networked computers or nodes. HDFS is fault tolerant because it stores multiple replicas of files on the file system, the default replication level is 3.

In **HDFS,** data is distributed among different systems called datanodes. Here, the storage capacity is comparatively high. **HDFS** is mainly used to store Big Data and enable fast data transaction. 

## Similarities 
两者的文件系统数据均能够在相关系统内的多台机器上进行数据读取和写入，都是分布式文件系统

## Differences
NFS是通过RPC通信协议进行数据共享的文件系统，所以NFS必须在运行的同时确保RPC能够正常工作。在不同的文件进行读取和写入时，实际上是对服务端的共享文件地址进行操作，一旦服务端出现问题，那么其他所有的机器无法进行文件读取和写入，并且数据无法找回。所以NFS系统的文件其实并没有备份，并且其服务端没有做高可用处理。

HDFS是通过数据备份进行的大数据存储文件系统。HDFS有系统备份，并且其namenode有secondnamenode进行备份处理，更加安全可靠。数据在经过多副本存储后，能够抵御各种灾难，只要有一个副本不丢失，数据就不会丢失。所以数据的安全性很高。