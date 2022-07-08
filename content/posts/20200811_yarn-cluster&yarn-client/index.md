---
title: "Spark On Yarn: yarn-cluster, yarn-client" # Title of the blog post.
date: 2020-08-11T10:42:19+08:00 # Date of post creation.
description: "Article description." # Description used for search engine.
featured: true # Sets if post is a featured post, making appear on the home page side bar.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: true # Controls if a table of contents should be generated for first-level links automatically.
# thumbnail: "images/distribution.png" # Sets thumbnail image appearing inside card on homepage.
# featureImage: "/images/path/file.jpg" # Sets featured image on blog post.
# featureImageAlt: 'Description of image' # Alternative text for featured image.
# featureImageCap: 'This is the featured image.' # Caption (optional).
codeLineNumbers: true # Override global value for showing of line numbers within code block.
codeMaxLines: 40 # Override global value for how many lines within a code block before auto-collapsing.
codeLineNumbers: true # Override global value for showing of line numbers within code block.
figurePositionShow: true # Override global value for showing the figure label.
usePageBundles: true # Set to true to group assets like images in the same folder as this post.
categories:
  - Technology
tags:
  - Distribution
  - Spark
comments: true # Disable comment if false.
---

YARN is a generic resource-management framework for distributed workloads; in other words, a cluster-level operating system. Although part of the Hadoop ecosystem, YARN can support a lot of varied compute-frameworks (such as Tez, and Spark) in addition to MapReduce.

<!--more-->

Spark支持可插拔的集群管理模式(Standalone、Mesos以及YARN )，集群管理负责启动executor进程，编写Spark application 的人根本不需要知道Spark用的是什么集群管理。Spark支持的三种集群模式，这三种集群模式都由两个组件组成:master和slave。Master服务(YARN ResourceManager,Mesos master和Spark standalone master)决定哪些application可以运行，什么时候运行以及哪里去运行。而slave服务( YARN NodeManager, Mesos slave和Spark standalone slave)实际上运行executor进程。

　　当在YARN上运行Spark作业，每个Spark executor作为一个YARN容器(container)运行。Spark可以使得多个Tasks在同一个容器(container)里面运行。这是个很大的优点。

> 注意这里和Hadoop的MapReduce作业不一样，MapReduce作业为每个Task开启不同的JVM来运行。虽然说MapReduce可以通过参数来配置。详见`mapreduce.job.jvm.numtasks`

**从广义上讲**，yarn-cluster适用于生产环境；而yarn-client适用于交互和调试，也就是希望快速地看到application的输出。

> Application Master。在YARN中，每个Application实例都有一个Application Master进程，它是Application启动的第一个容器。它负责和ResourceManager打交道，并请求资源。获取资源之后告诉NodeManager为其启动container。

**从深层次的含义讲**，yarn-cluster和yarn-client模式的区别其实就是Application Master进程的区别，yarn-cluster模式下，driver运行在AM(Application Master)中，它负责向YARN申请资源，并监督作业的运行状况。当用户提交了作业之后，就可以关掉Client，作业会继续在YARN上运行。然而yarn-cluster模式不适合运行交互类型的作业。而yarn-client模式下，Application Master仅仅向YARN请求executor，client会和请求的container通信来调度他们工作，也就是说Client不能离开。（上图是yarn-cluster模式，下图是yarn-client模式）：

![spark-yarn-f31](spark-yarn-f31.png "spark-yarn-f31")

![spark-yarn-f22](spark-yarn-f22.png "spark-yarn-f22")
