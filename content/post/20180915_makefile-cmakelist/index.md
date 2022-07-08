---
title: "Makefile Guide" # Title of the blog post.
date: 2018-09-15T21:59:46-08:00 # Date of post creation.
description: "Article description." # Description used for search engine.
featured: false # Sets if post is a featured post, making appear on the home page side bar.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: true # Controls if a table of contents should be generated for first-level links automatically.
# menu: main
# featureImage: "/images/path/file.jpg" # Sets featured image on blog post.
# thumbnail: "images/code2.png" # Sets thumbnail image appearing inside card on homepage.
# shareImage: "/images/path/share.png" # Designate a separate image for social media sharing.
codeMaxLines: 40 # Override global value for how many lines within a code block before auto-collapsing.
codeLineNumbers: true # Override global value for showing of line numbers within code block.
figurePositionShow: true # Override global value for showing the figure label.
categories:
  - Technology
tags:
  - c
  - c++
# comment: false # Disable comment if false.
---
Makefiles define a set of rules that specify which files need to be compiled first, which files need to be compiled later, which files need to be recompiled, and even more complex functional operations, because makefiles are like Shell scripts that also execute operating system commands. One of the benefits of Makefiles is that they are "automatically compiled". The entire project is automatically compiled, greatly improving the efficiency of software development. 
<!--more-->

## 关于程序的编译和链接
   无论是C还是C++，首先要把源文件编译成中间代码文件，在Windows下也就是 .obj 文件，UNIX下是 .o 文件，即 Object File，这个动作叫做<font style= "font-weight:bold" color="purple">编译（compile）</font>。然后再把大量的Object File合成执行文件，这个动作叫作<font style= "font-weight:bold" color="purple">链接（link）。</font>


   编译时，编译器需要的是语法的正确，函数与变量的声明的正确。对于后者，通常需要告诉编译器头文件的所在位置（头文件中应该只是声明，而定义应该放在C/C++文件中），只要所有的语法正确，编译器就可以编译出中间目标文件。一般来说，每个源文件都应该对应于一个中间目标文件（O文件或是OBJ文件）。 


   链接时，主要是链接函数和全局变量，所以，我们可以使用这些中间目标文件（O文件或是OBJ文件）来链接我们的应用程序。链接器并不管函数所在的源文件，只管函数的中间目标文件（Object File），在大多数时候，由于源文件太多，编译生成的中间目标文件太多，而在链接时需要明显地指出中间目标文件名，这对于编译很不方便，所以，我们要给中间目标文件打个包，在Windows下这种包叫“库文件”（Library File)，也就是 .lib 文件，在UNIX下，是Archive File，也就是 .a 文件。


   总结一下，源文件首先会生成中间目标文件，再由中间目标文件生成执行文件。在编译时，编译器只检测程序语法，和函数、变量是否被声明。如果函数未被声明，编译器会给出一个警告，但可以生成Object File。而在链接程序时，链接器会在所有的Object File中找寻函数的实现，如果找不到，那到就会报链接错误码（Linker Error），在VC下，这种错误一般是：Link 2001错误，意思说是说，链接器未能找到函数的实现。需要指定函数的ObjectFile.

## Makefile 介绍

make命令执行时，需要一个 Makefile 文件，以告诉make命令需要怎么样的去编译和链接程序。

首先，我们用一个示例来说明Makefile的书写规则。以便给大家一个感兴认识。这个示例来源于GNU的make使用手册，在这个示例中，我们的工程有8个C文件，和3个头文件，我们要写一个Makefile来告诉make命令如何编译和链接这几个文件。我们的规则是：

1. 如果这个工程没有编译过，那么我们的所有C文件都要编译并被链接。
2. 如果这个工程的某几个C文件被修改，那么我们只编译被修改的C文件，并链接目标程序。
3. 如果这个工程的头文件被改变了，那么我们需要编译引用了这几个头文件的C文件，并链接目标程序。

### 1. Makefile 规则

```makefile
target... : prerequisites ...
	command
...
```

target也就是一个目标文件，可以是Object File，也可以是执行文件。还可以是一个标签（Label）

prerequisites就是，要生成那个target所需的文件或是目标。

command也就是make需要执行的命令。(任意的shell命令)

这是一个文件的依赖关系，也就是说，target这一个或多个的目标文件依赖于prerequisites中的文件，其生成规则定义在command中。也就是说，prerequisites中如果有一个以上的文件比target文件要新的话，command所定义的命令就会被执行。

### 2. $@, $^, $< 含义
1. $@--目标文件
2. $^--所有的依赖文件
3. $<--第一个依赖文件

一个示例
如果一个工程有3个头文件，和8个C文件，我们为了完成前面所述的那三个规则，我们的Makefile应该是下面的这个样子的。
```makefile
edit : main.o kbd.o command.o display.o \
       insert.o search.o files.o utils.o
       cc -o edit main.o kbd.o command.o display.o \
           insert.o search.o files.o utils.o

main.o : main.c defs.h
         cc -c main.c

kbd.o : kbd.c defs.h command.h
        cc -c kbd.c

command.o : command.c defs.h command.h
            cc -c command.c

display.o : display.c defs.h buffer.h
            cc -c display.c

insert.o : insert.c defs.h buffer.h
           cc -c insert.c

search.o : search.c defs.h buffer.h
           cc -c search.c

files.o : files.c defs.h buffer.h command.h
          cc -c files.c

utils.o : utils.c defs.h
          cc -c utils.c

clean :
           rm edit main.o kbd.o command.o display.o \
              insert.o search.o files.o utils.o
```
反斜杠（\）是换行符的意思。这样比较便于Makefile的易读。

   在这个makefile中，目标文件（target）包含：执行文件edit和中间目标文件（*.o），依赖文件（prerequisites）就是冒号后面的那些 .c 文件和 .h文件。每一个 .o 文件都有一组依赖文件，而这些 .o 文件又是执行文件 edit 的依赖文件。依赖关系的实质上就是说明了目标文件是由哪些文件生成的，换言之，目标文件是哪些文件更新的。

   在定义好依赖关系后，后续的那一行定义了如何生成目标文件的操作系统命令，一定要以一个Tab键作为开头。记住，make并不管命令是怎么工作的，他只管执行所定义的命令。make会比较targets文件和prerequisites文件的修改日期，如果prerequisites文件的日期要比targets文件的日期要新，或者target不存在的话，那么，make就会执行后续定义的命令。


### 3. make是如何工作的

在默认的方式下，也就是我们只输入make命令。那么，
1. make会在当前目录下找名字叫“Makefile”或“makefile”的文件。
2. 如果找到，它会找文件中的第一个目标文件（target），在上面的例子中，他会找到“edit”这个文件，并把这个文件作为最终的目标文件。
3. 如果edit文件不存在，或是edit所依赖的后面的 .o 文件的文件修改时间要比edit这个文件新，那么，他就会执行后面所定义的命令来生成edit这个文件。
4. 如果edit所依赖的.o文件也存在，那么make会在当前文件中找目标为.o文件的依赖性，如果找到则再根据那一个规则生成.o文件。
5. 当然，C文件和H文件是存在的啦，于是make会生成 .o 文件，然后再用 .o 文件声明make的终极任务，也就是执行文件edit了。

   这就是整个make的依赖性，make会一层又一层地去找文件的依赖关系，直到最终编译出第一个目标文件。在找寻的过程中，如果出现错误，比如最后被依赖的文件找不到，那么make就会直接退出，并报错，而对于所定义的命令的错误，或是编译不成功，make根本不理。make只管文件的依赖性

   于是在我们编程中，如果这个工程已被编译过了，当我们修改了其中一个源文件，比如file.c，那么根据我们的依赖性，我们的目标file.o会被重编译（也就是在这个依性关系后面所定义的命令），于是file.o的文件也是最新的啦，于是file.o的文件修改时间要比edit要新，所以edit也会被重新链接了（详见edit目标文件后定义的命令）。

   而如果我们改变了“command.h”，那么，kdb.o、command.o和files.o都会被重编译，并且，edit会被重链接。

### 4. makefile中使用变量
以edit的规则为例：
```makefile
edit:main.o kbd.o command.o display.o \
	 insert.o search.o files.o utills.o
cc -o edit main.o kbd.o command.o display.o \
		   insert.o search.o files.o utils.o
```
  看到[.o]文件的字符串被重复了两次，如果我们的工程需要加入新的[.o]文件，那么需要在两个地方加。因为此时的makefile并不复杂。当makefile变得复杂我们就有可能忘掉某个地方，而导致编译失败。所以为了makefile的易维护，在makefile中可以使用变量。

  比如我们声明一个变量，objects, OBJECTS,objs,OBJS,或OBJ，表示obj文件。在makefile一开始就定义
```makefile
objects = main.o kbd.o command.o display.o \
		  insert.o search.o files.o utils.o
```
  于是，就可以方便的在makefile中以"$(objects)"的方式来使用这个变量了。改良后的makefile如下：

```makefile
objects = main.o kbd.o command.o display.o \
		insert.o search.o files.o utils.o
edit : $(objects)
		cc -o edit $(objects)
main.o : main.c defs.h
		cc -c main.c
command.o : command.c defs.h command.h
			cc -c command.c
display.o : display.c defs.h buffer.h
           cc -c display.c
insert.o : insert.c defs.h buffer.h
           cc -c insert.c
search.o : search.c defs.h buffer.h
           cc -c search.c
files.o : files.c defs.h buffer.h command.h
           cc -c files.c
utils.o : utils.c defs.h
           cc -c utils.c
clean :
	rm edit $(objects)
```

于是如果有新的 .o 文件加入，只需修改一下 objects 变量就可以了。

### 5. make自动推导

GNU的make很强大，它可以自动推导文件以及文件依赖关系后面的命令，于是我们没有必要在每个[.o]文件写上依赖关系。make会自动识别，并自己推导命令。

只要make找到一个[.o]文件，它就会自动的把[.c]文件加在依赖关系中，如果make找到一个whatever.o，那么whatever.c等whatever.o的依赖文件，并且cc -c whatever.c也会被推导出来。于是makefile可以又一次简化。

```makefile
objects = main.o kbd.o command.o display.o \
		insert.o seaerch.o files.o utils.o
edit : $(objects)
	cc -o edit $(objects)
main.o : defs.h
kbd.o : defs.h command.h
command.o : defs.h command.h
display.o : defs.h buffer.h
insert.o : defs.h buffer.h
search.o : defs.h buffer.h
files.o : defs.h buffer.h command.h
utils.o : defs.h

.PHONY : clean
clean :
		rm edit $(objects)
```

这就是make的“隐晦规则”。

.PHONY表示，clean是个伪目标文件

### 6. makefile的收缩

收拢起来

```makefile
objects = main.o kbd.o command.o display.o \
    	insert.o search.o files.o utils.o
edit : $(objects)
		cc -o edit $(objects)
$(objects) : defs.h
kbd.o command.o files.o : command.h
display.o insert.o search.o files.o : buffer.h

.PHONY : clean
clean:
	rm edit $(objects)
```

虽然makefile变得很简单，但我们的文件依赖关系会显得凌乱，新增.o文件不好管理

### 7. 清空目标文件的规则

每个Makefile中都应该写一个清空目标文件(.o和执行文件)的规则。

一般的风格是：

```makefile
clean:
	rm edit $(objects)
```

更稳健的做法是：

```makefile
.PHONY: clean
clean:
	-rm edit $(objects)
```

.PHONY表示clean是一个“伪目标”，向make说明，不管是否有这个文件，这个目标就是“伪目标”。只要有这个声明，不管是否有“clean”文件，要运行“clean”这个目标，只有“make clean”这样。

而在rm命令前面加了一个减号表示也许某些文件出现问题，但不用管，继续往后执行。

当然，clean的规则不要放在文件的开头，不然，这就会变成make的默认目标。

“clean从来都是放在文件的最后”

## Makefile总述

### 1. Makefile里有什么

Makefile主要包含了五个东西：**<font color = "red">显示规则，隐晦规则，变量定义，文件指示和注释。</font>**

1. 显示规则：显示规则说明了如何生成一个或多个的目标文件。这是由Makefile书写者明显指出要生成的文件、文件的依赖文件、生成的命令。
2. 隐晦规则：由于我们的make有自动推导功能，所以隐晦的规则可以让我们比较粗糙地简略书写Makefile，这是make支持的。
3. 变量的定义：在Makefile中我们要定义一系列的变量，变量一般都是字符串，这个有点像C语言中的宏，当Makefile被执行时，其中的变量都会被扩展到相应的引用位置上。
4. 文件指示：其中包括三个部分，一个是在Makefile中引用另一个Makefile，就像C中的#include一样；另一个是指根据某些情况指定Makefile中的有效部分，就像C语言中的预编译#if一样；还有就是定义一个多行的命令。
5. 注释：Makefile中只有行注释，和UNIX的Shell脚本一样，其注释是用“#”字符，这个就像C/C++中的“//”一样。如果要在Makefile中使用“#”字符，可以用反斜框进行转义，如：“\#”。

最后，在Makefile中的命令，必须要以[Tab]键开始。

### 2. Makefile的文件名

 默认的情况下，make命令会在当前目录下按顺序找寻文件名为**“GNUmakefile”、“makefile”、“Makefile”**的文件，找到了解释这个文件。在这三个文件名中，最好使用“Makefile”这个文件名，因为，这个文件名第一个字符为大写，这样有一种显目的感觉。最好不要用“GNUmakefile”，这个文件是GNU的make识别的。有另外一些make只对全小写的“makefile”文件名敏感，但是基本上来说，大多数的make都支持“**makefile”和“Makefile”**这两种默认文件名。

 当然，可以使用别的文件名来书写Makefile，比如：“Make.Linux”，“Make.Solaris”，“Make.AIX”等，如果要***\*指定特定的Makefile，可以使用make的“-f”和“--file”参数\****，如：make -f Make.Linux或make --file Make.AIX。

### 3. 引用其他的Makefile

在Makefile使用include关键字可以把别的Makefile包含进来，这很像C语言的#include，被包含的文件会原模原样的放在当前文件的包含位置。include的语法是：

```makefile
 include filename
 #filename可以是当前操作系统Shell的文件模式（可以保含路径和通配符）
```

**在include前面可以有一些空字符，但是绝不能是[Tab]键开始。include和可以用一个或多个空格隔开。**

举个例子，有这样几个Makefile：a.mk、b.mk、c.mk，还有一个文件叫foo.make，以及一个变量$(bar)，其包含了e.mk和f.mk，那么，下面的语句：

```makefile
include foo.make *.mk $(bar)
#等价于：
include foo.make a.mk b.mk c.mk e.mk f.mk
```

make命令开始时，会把找寻include所指出的其它Makefile，并把其内容安置在当前的位置。就好像C/C++的#include指令一样。如果文件都没有指定绝对路径或是相对路径的话，make会在当前目录下首先寻找，如果当前目录下没有找到，那么，make还会在下面的几个目录下找：

1. 如果make执行时，有“-I”或“--include-dir”参数，那么make就会在这个参数所指定的目录下去寻找。
2. 如果目录/include（一般是：/usr/local/bin或/usr/include）存在的话，make也会去找。

 如果有文件没有找到的话，make会生成一条警告信息，但不会马上出现致命错误。它会继续载入其它的文件，一旦完成makefile的读取，make会再重试这些没有找到，或是不能读取的文件，如果还是不行，make才会出现一条致命信息。如果想让make不理那些无法读取的文件，而继续执行，可以在include前加一个减号“-”。如：

```makefile
-include<filename>
```

其表示，无论include过程中出现什么错误，都不要报错继续执行。和其它版本make兼容的相关命令是sinclude，其作用和这一个是一样的。这个变量中的值是其它的Makefile，用空格分隔。只是，它和include不同的是，从这个环境变量中引入的Makefile的“目标”不会起作用，如果环境变量中定义的文件发现错误，make也会不理。

### 4. 环境变量Makefiles

如果当前环境中定义了环境变量Makefiles，那么make会把这个变量中的值做一个类似于include的动作。这个变量中的值是其它的Makefile，用空格分隔。只是，它和include不同的是，从这个环境变中引入的Makefile的“目标”不会起作用，如果环境变量中定义的文件发现错误，make也会不理。

但还是建议不要使用这个环境变量，因为只要这个变量一旦被定义，那么当使用make时，所有的Makefile都会受到它的影响，这绝不是想看到的。在这里提这个事，只是为了告诉大家，也许有时候Makefile出现了怪事，那么可以看看当前环境中有没有定义这个变量。

### 5. make的工作方式

GNU的make工作时执行步骤如下：

1. 读入所有的makefile
2. 读入被include的其他makefile
3. 初始化文件中的变量
4. 推导隐晦规则，并分析所有规则
5. 为所有的目标文件创建依赖关系链
6. 根据依赖关系，决定哪些目标文件重新生成
7. 执行生成命令

1-5步为第一个阶段，6-7为第二个阶段。

第一个阶段中，如果定义被使用了，那么make会把其展开在使用的位置。但make并不会完全马上展开，如果变量出现在依赖关系的规则中，那么仅当这条依赖被决定要使用了，变量才会在内部展开

## Makefile书写规则

### 1. Makefile规则

规则包含两个部分，一个是**依赖关系**，一个是**生成目标的方法**。

**在Makefile中，规则的顺序是很重要的**，因为，**Makefile中只应该有一个最终目标**，其它的目标都是被这个目标所连带出来的，所以一定要让make知道你的最终目标是什么。一般来说，定义在Makefile中的目标可能会有很多，但是第一条规则中的目标将被确立为最终的目标。如果第一条规则中的目标有很多个，那么，第一个目标会成为最终的目标。make所完成的也就是这个目标。

规则举例

```makefile
 foo.o: foo.c defs.h       # foo模块
        cc -c -g foo.c
```

foo.o是我们的目标，foo.c和defs.h是目标所依赖的源文件，而只有一个命令“cc -c -g foo.c”（以Tab键开头）

1.  文件的依赖关系，foo.o依赖于foo.c和defs.h的文件，如果foo.c和defs.h的文件日期要比foo.o文件日期要新，或是foo.o不存在，那么依赖关系发生。
2. 如果生成（或更新）foo.o文件。也就是那个cc命令，其说明了，如何生成foo.o这个文件。（当然foo.c文件include了defs.h文件）

### 2. 规则的语法

```makefile
targets : prerequisites
		command
#或：
targets : prerequisites ; command
		command
```

* targets是文件名，以空格分开，可以使用通配符。一般来说，我们的目标基本上是一个文件，但也有可能是多个文件。

* command是命令行，如果其不与“target:prerequisites”在一行，那么，必须以[Tab键]开头，如果和prerequisites在一行，那么可以用分号做为分隔
* prerequisites也就是目标所依赖的文件（或依赖目标）。如果其中的某个文件要比目标文件要新，那么，目标就被认为是“过时的”，被认为是需要重生成的。
* 如果命令太长，你可以使用反斜框（‘\’）作为换行符。make对一行上有多少个字符没有限制。规则告诉make两件事，文件的依赖关系和如何成成目标文件。
* 一般来说，make会以UNIX的标准Shell，也就是/bin/sh来执行命令。

### 3. 在规则中使用通配符

make支持三各通配符：“*”，“?”和“[...]”。这是和Unix的B-Shell是相同的。

1. “~”：波浪号（“~”）字符在文件名中也有比较特殊的用途。如果是“~/test”，这就表示当前用户的$HOME目录下的test目录。而“~hchen/test”则表示用户hchen的宿主目录下的test目录。（这些都是Unix下的小知识了，make也支持）而在Windows或是MS-DOS下，用户没有宿主目录，那么波浪号所指的目录则根据环境变量“HOME”而定。
2. “\*”：通配符代替了你一系列的文件，如“*.c”表示所以后缀为c的文件。一个需要我们注意的是，如果我们的文件名中有通配符，如：“*”，那么可以用转义字符“\”，如“\*”来表示真实的“*”字符，而不是任意长度的字符串。

### 4. 静态模式

静态模式可以更加容易地定义多目标的规则，可以让我们的规则变得更加的有弹性和灵活。语法：

```makefile
<targets...>: <target-pattern>: <prereq-patterns ...>
	<commands>
```

targets定义了一系列的目标文件，可以有通配符。是目标的一个集合。

target-parrtern是指明了targets的模式，也就是的目标集模式。

prereq-parrterns是目标的依赖模式，它对target-parrtern形成的模式再进行一次依赖目标的定义。

说明:

如果我们的<target-parrtern>定义成“%.o”，意思是我们的集合中都是以“.o”结尾的。

而如果我们的<prereq-parrterns>定义成“%.c”，意思是对<target-parrtern>所形成的目标集进行二次定义，其计算方法是，取<target-parrtern>模式中的“%”（也就是去掉了[.o]这个结尾），并为其加上[.c]这个结尾，形成的新集合。

所以，我们的“目标模式”或是“依赖模式”中都应该有“%”这个字符

实例：

```makefile
objects = foo.o bar.o
all: $(objects)
$(objects): %.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@
```

例子中，指明了目标从$objects中获取

“%.o”表明要所有以“.o”结尾的目标，也就是"foo.o bar.o"，也就是变量$object集合的模式

而依赖模式“%.c”则取模式“%.o”的“%”，也就是“foobar”，并为其加下“.c”的后缀，于是，我们的依赖目标就是“foo.c bar.c”

而命令中的“$<”和“$@”则是自动化变量，“$<”表示所有的依赖目标集（也就是“foo.c bar.c”），“$@”表示目标集（也褪恰癴oo.o bar.o”）

上面的规则展开后等价于：

```makefile
foo.o : foo.c
	$(CC) -c $(CFLAGS) foo.c -o foo.o
bar.o : bar.c
	$(CC) -c $(CFLAGS) bar.c -o bar.o
```

## Makefile书写命令

### 1. 显示命令

通常，make会把其要执行的命令行在命令执行前输出到屏幕上。当我们用“@”字符在命令行前，那么，这个命令将不被make显示出来，最具代表性的例子是，我们用这个功能来像屏幕显示一些信息。如：

@echo 正在编译XXX模块......

### 2.赋值命令

```makefile
#  = 是最基本的赋值
# := 是覆盖之前的值
# ?= 是如果没有被赋值过就赋予等号后面的值
# += 是添加等号后面的值
```

### 3. 指定目标

```makefile
1. “all”       这个伪目标是所有目标的目标，其功能一般是编译所有的目标。
2. “clean”     这个伪目标功能是删除所有被make创建的文件。
3. “install”   这个伪目标功能是安装已编译好的程序，其实就是把目标执行文件拷贝到指定的目标中去。
4. “print”     这个伪目标的功能是例出改变过的源文件。
5. “tar”       这个伪目标功能是把源程序打包备份。也就是一个tar文件。
6. “dist”      这个伪目标功能是创建一个压缩文件，一般是把tar文件压成Z文件。或是gz文件。
7. “TAGS”      这个伪目标功能是更新所有的目标，以备完整地重编译使用。
8. “check”和“test”   这两个伪目标一般用来测试makefile的流程。
```
### 4. 自动化变量

1. $@表示规则中的目标文件集。在模式规则中，如果有多个目标，那么，"$@"就是匹配于目标中模式定义的集合。
2. $%仅当目标是函数库文件中，表示规则中的目标成员名。例如，如果一个目标是"foo.a(bar.o)"，那么，"$%"就是"bar.o"，"$@"就是"foo.a"。如果目标不是函数库文件（Unix下是
   [.a]，Windows下是[.lib]），那么，其值为空。
3. $<依赖目标中的第一个目标名字。如果依赖目标是以模式（即"%"）定义的，那么"$<"将是符合模式的一系列的文件集。注意，其是一个一个取出来的。
4. $?所有比目标新的依赖目标的集合。以空格分隔。
5. $^所有的依赖目标的集合。以空格分隔。如果在依赖目标中有多个重复的，那个这个变量会去除重复的依赖目标，只保留一份。
6. $+这个变量很像"$^"，也是所有依赖目标的集合。只是它不去除重复的依赖目标。
7. $\*这个变量表示目标模式中"%"及其之前的部分。如果目标是"dir/a.foo.b"，并且目标的模式是"a.%.b"，那么，"$\*"的值就是"dir /a.foo"。这个变量对于构造有关联的文件名是比
   较有较。如果目标中没有模式的定义，那么"$\*"也就不能被推导出，但是，如果目标文件的后缀是 make所识别的，那么"$\*"就是除了后缀的那一部分。例如：如果目标是"foo.c"
   ，因为".c"是make所能识别的后缀名，所以，"$\*"的值就是"foo"。这个特性是GNU make的，很有可能不兼容于其它版本的make，所以，你应该尽量避免使用"$*"，除非是在隐含规则或是静态模式中。如果目标中的后缀是make所不能识别的，那么"$\*"就是空值。

