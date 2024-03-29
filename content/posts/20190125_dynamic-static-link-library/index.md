---
title: "Dynamic link library and static link library" # Title of the blog post.
date: 2019-01-25T22:01:19-08:00 # Date of post creation.
description: "Article description." # Description used for search engine.
featured: false # Sets if post is a featured post, making appear on the home page side bar.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: true # Controls if a table of contents should be generated for first-level links automatically.
# menu: main
# featureImage: "/images/path/file.jpg" # Sets featured image on blog post.
# thumbnail: "images/code3.png" # Sets thumbnail image appearing inside card on homepage.
# shareImage: "/images/path/share.png" # Designate a separate image for social media sharing.
codeMaxLines: 40 # Override global value for how many lines within a code block before auto-collapsing.
codeLineNumbers: true # Override global value for showing of line numbers within code block.
figurePositionShow: true # Override global value for showing the figure label.
categories:
  - Technology
tags:
  - C
  - C++
# comment: false # Disable comment if false.
---
In development, we just need to know that lib is needed at compile time and DLL is needed at run time. If you want to compile source code, lib is all you need. If you want dynamically connected programs to run, you need only a DLL. This article will more clearly understand the difference, generation, use of the two. 
<!--more-->

## lib和dll区别

首先介绍静态库（静态链接库）、动态库（动态链接库）的概念，首先两者都是代码共享的方式。

1. 静态库：在链接步骤中，连接器将从库文件取得所需的代码，复制到生成的可执行文件中，这种库称为静态库，其特点是可执行文件中包含了库代码的一份完整拷贝；缺点就是被多次使用就会有多份冗余拷贝。即静态库中的指令都全部被直接包含在最终生成的 EXE 文件中了。在vs中新建生成静态库的工程，编译生成成功后，只产生一个.lib文件。
2. 动态库：动态链接库是一个包含可由多个程序同时使用的代码和数据的库，DLL不是可执行文件。动态链接提供了一种方法，使进程可以调用不属于其可执行代码的函数。函数的可执行代码位于一个 DLL 中，该 DLL 包含一个或多个已被编译、链接并与使用它们的进程分开存储的函数。在vs中新建生成动态库的工程，编译成功后，产生一个.lib文件和一个.dll文件。

静态库和动态库中的lib有什么区别呢？

1. 静态库中的lib：该LIB包含函数代码本身（即包括函数的索引，也包括实现），在编译时直接将代码加入程序当中。
2. 动态库中的lib：该LIB包含了函数所在的DLL文件和文件中函数位置的信息（索引），函数实现代码由运行时加载在进程空间中的DLL提供。

总之，lib是编译时用到的，dll是运行时用到的。如果要完成源代码的编译，只需要lib；如果要使动态链接的程序运行起来，只需要dll。

## 静态链接

### 1. 为什么进行静态链接

在我们的实际开发中，不可能将所有代码放在一个源文件中，所以会出现多个源文件，而且多个源文件之间不是独立的，而会存在多种依赖关系，如一个源文件可能要调用另一个源文件中定义的函数，但是每个源文件都是独立编译的，即每个*.c文件会形成一个*.o文件，为了满足前面说的依赖关系，则需要将这些源文件产生的目标文件进行链接，从而形成一个可以执行的程序。这个链接的过程就是静态链接

### 2. 静态链接的原理

由很多目标文件进行链接形成的是静态库，反之静态库也可以简单地看成是一组目标文件的集合，即很多目标文件经过压缩打包后形成的一个文件。

以下面这个图来简单说明一下从静态链接到可执行文件的过程，根据在源文件中包含的头文件和程序中使用到的库函数，如stdio.h中定义的printf()函数，在libc.a中找到目标文件printf.o(这里暂且不考虑printf()函数的依赖关系)，然后将这个目标文件和我们hello.o这个文件进行链接形成我们的可执行文件。

{{< mermaid >}}
graph TD
A[Christmas] -->|Get money| B(Go shopping)
B --> C{Let me think}
C -->|One| D[Laptop]
C -->|Two| E[iPhone]
C -->|Three| F[fa:fa-car Car]
{{< /mermaid >}}



链接器在链接静态链接库的时候是以目标文件为单位的。比如我们引用了静态库中的printf()函数，那么链接器就会把库中包含printf()函数的那个目标文件链接进来，如果很多函数都放在一个目标文件中，很可能很多没用的函数都被一起链接进了输出结果中。由于运行库有成百上千个函数，数量非常庞大，每个函数独立地放在一个目标文件中可以尽量减少空间的浪费，那些没有被用到的目标文件就不要链接到最终的输出文件中。

### 3. 静态链接的优缺点

 静态链接的缺点很明显，一是浪费空间，因为每个可执行程序中对所有需要的目标文件都要有一份副本，所以如果多个程序对同一个目标文件都有依赖，如多个程序中都调用了printf()函数，则这多个程序中都含有printf.o，所以同一个目标文件都在内存存在多个副本；另一方面就是更新比较困难，因为每当库函数的代码修改了，这个时候就需要重新进行编译链接形成可执行程序。但是静态链接的优点就是，在可执行程序中已经具备了所有执行程序所需要的任何东西，在执行的时候运行速度快。

## 动态链接

### 1. 为什么进行动态链接

动态链接出现的原因就是为了解决静态链接中提到的两个问题，一方面是空间浪费，另外一方面是更新困难。

### 2. 动态链接的原理

动态链接的基本思想是把程序按照模块拆分成各个相对独立部分，在程序运行时才将它们链接在一起形成一个完整的程序，而不是像静态链接一样把所有程序模块都链接成一个单独的可执行文件。下面简单介绍动态链接的过程：

假设现在有两个程序program1.o和program2.o，这两者共用同一个库lib.o,假设首先运行程序program1，系统首先加载program1.o，当系统发现program1.o中用到了lib.o，即program1.o依赖于lib.o，那么系统接着加载lib.o，如果program1.o和lib.o还依赖于其他目标文件，则依次全部加载到内存中。当program2运行时，同样的加载program2.o，然后发现program2.o依赖于lib.o，但是此时lib.o已经存在于内存中，这个时候就不再进行重新加载，而是将内存中已经存在的lib.o映射到program2的虚拟地址空间中，从而进行链接（这个链接过程和静态链接类似）形成可执行程序。

### 3. 动态链接的优缺点

动态链接的优点显而易见，就是即使需要每个程序都依赖同一个库，但是该库不会像静态链接那样在内存中存在多分，副本，而是这多个程序在执行时共享同一份副本；另一个优点是，更新也比较方便，更新时只需要替换原来的目标文件，而无需将所有的程序再重新链接一遍。当程序下一次运行时，新版本的目标文件会被自动加载到内存并且链接起来，程序就完成了升级的目标。但是动态链接也是有缺点的，因为把链接推迟到了程序运行时，所以每次执行程序都需要进行链接，所以性能会有一定损失。

​    据估算，动态链接和静态链接相比，性能损失大约在5%以下。经过实践证明，这点性能损失用来换区程序在空间上的节省和程序构建和升级时的灵活性是值得的。