---
title: "HugePages" # Title of the blog post.
date: 2019-02-03T13:04:09-08:00 # Date of post creation.
description: "Article description." # Description used for search engine.
featured: false # Sets if post is a featured post, making appear on the home page side bar.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: true # Controls if a table of contents should be generated for first-level links automatically.
# menu: main
# featureImage: "/images/path/file.jpg" # Sets featured image on blog post.
# thumbnail: "images/linux.png" # Sets thumbnail image appearing inside card on homepage.
# shareImage: "/images/path/share.png" # Designate a separate image for social media sharing.
codeMaxLines: 40 # Override global value for how many lines within a code block before auto-collapsing.
codeLineNumbers: true # Override global value for showing of line numbers within code block.
figurePositionShow: true # Override global value for showing the figure label.
categories:
  - Technology
tags:
  - Linux
  - C
# comment: false # Disable comment if false.
---
Reduce page tables by increasing the size of operating system pages to avoid fast table misses. Large page memory optimizer is designed for malloc mechanism, which means allocating large pages to increase TLB hit ratio. 
<!--more-->
## 原理
  大页内存的原理涉及到操作系统的虚拟地址到物理地址的转换过程。操作系统为了能同时运行多个进程，会为每个进程提供一个虚拟的进程空间，在32位操作系统上，进程空间大小为4G，64位系统为2^64（实际可能小于这个值）。事实上，每个进程的进程空间都是虚拟的，这和物理地址还不一样。两个进行访问相同的虚拟地址，但是转换到物理地址之后是不同的。这个转换就通过页表来实现，涉及的知识是操作系统的分页存储管理。

  分页存储管理将进程的虚拟地址空间，分成若干个页，并为各页加以编号。相应地，物理内存空间也分成若干个块，同样加以编号。页和块的大小相同。

  在操作系统中设置有一个页表寄存器，其中存放了页表在内存的始址和页表的长度。进程未执行时，页表的始址和页表长度放在本进程的PCB中；当调度程序调度该进程时，才将这两个数据装入页表寄存器。

当进程要访问某个虚拟地址中的数据时，分页地址变换机构会自动地将有效地址（相对地址）分为页号和页内地址两部分，再以页号为索引去检索页表，查找操作由硬件执行。若给定的页号没有超出页表长度，则将页表始址与页号和页表项长度的乘积相加，得到该表项在页表中的位置，于是可以从中得到该页的物理块地址，将之装入物理地址寄存器中。与此同时，再将有效地址寄存器中的页内地址送入物理地址寄存器的块内地址字段中。这样便完成了从虚拟地址到物理地址的变换。

  由于页表是存放在内存中的，这使CPU在每存取一个数据时，都要两次访问内存。第一次时访问内存中的页表，从中找到指定页的物理块号，再将块号与页内偏移拼接，以形成物理地址。第二次访问内存时，才是从第一次所得地址中获得所需数据。因此，采用这种方式将使计算机的处理速度降低近1/2。

  为了提高地址变换速度，可在地址变换机构中，增设一个具有并行查找能力的特殊高速缓存，也即快表（TLB），用以存放当前访问的那些页表项。具有快表的地址变换机构如图四所示。由于成本的关系，快表不可能做得很大，通常只存放16~512个页表项。
## 大页内存的配置和使用
### 1. 安装libhugetlbfs库
  libhugetlbfs库实现了大页内存的访问。安装可以通过apt-get或者yum命令完成，如果系统没有该命令，还可以git clone, 然后make生成libhugetlbfs.so文件. 直接使用makefile进行编译：make BUILDTYPE=NATIVEONLY一定要加最后的参数 BUILDTYPE=NATIVEONLY否则会遇见各种错误
### 2. 配置grub启动文件
  具体就是在kernel选项的最后添加几个启动参数：transparent_hugepage=never default_hugepagesz=1G hugepagesz=1Ghugepages=123
  这四个参数中，最重要的是后两个，hugepagesz用来设置每页的大小，我们将其设置为1G，其他可选的配置有4K，2M（其中2M是默认）。
```shell
vim /boot/grub/grub.cfg
```
  修改完grub.conf后，重启系统。然后运行命令查看大页设置是否生效
```shell
cat /proc/meminfo|grep Huge
```
### 3. mount
  执行mount，将大页内存映像到一个空目录。可以执行下述命令：
```shell
mount -t hugetlbfs hugetlbfs /mnt/huge
```
### 4. 运行应用程序
  为了能启用大页，不能按照常规的方法启动应用程序，需要按照下面的格式启动：
```shell
HUGETLB_MORECORE=yes LD_PRELOAD=libhugetlbfs.so ./your_program
```
  这种方法会加载libhugetlbfs库，用来替换标准库。具体的操作就是替换标准的malloc为大页的malloc。此时，程序申请内存就是大页内存了。
## 大页内存的使用场景
  任何优化手段都有它适用的范围，大页内存也不例外。只有耗费的内存巨大、访存随机而且访存是瓶颈的程序大页内存才会带来很明显的性能提升。
