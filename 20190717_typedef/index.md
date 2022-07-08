# The descriptions of typedef

A typedef is a C keyword that defines a new name for a data type, including internal data types (int, char, etc.) and custom data types (struct, etc.). A typedef is itself a type of stored class keyword that cannot appear in the same expression as the keywords auto, extern, static, register, etc.
<!--more-->
## 1. 概述
typedef为C语言的关键字，作用是为一种数据类型定义一个新名字，这里的数据类型包括内部数据类型（int，char等）和自定义的数据类型（struct等）。

typedef本身是一种存储类的关键字，与auto、extern、static、register等关键字不能出现在同一个表达式中。
## 2. 作用及用法
### 2.1 typedef的用法
使用typedef定义新类型的方法：在传统的变量声明表达式里用<mark>（新的）类型名</mark>替换<mark>变量名</mark>，然后把关键字typedef加在该语句的开头就行了。

下面以两个示例，描述typedef的用法步骤。

示例1：

int a; ———— 传统变量声明表达式
typedef int myint_t; ———— 使用新的类型名myint_t替换变量名a。在语句开头加上typedef关键字，myint_t就是我们定义的新类型

示例2：

void (*pfunA)(int a); ———— 传统变量（函数）声明表达式
typedef void (*PFUNA)(int a); ———— 使用新的类型名PFUNA替换变量名pfunA。在语句开头加上typedef关键字，PFUNA就是我们定义的新类型
### 2.2 typedef的作用

typedef的作用有以下几点：
#### 1）typedef的一个重要用途是定义机器无关的类型。例如，定义一个叫REAL的浮点类型，该浮点类型在目标机器上可以获得最高的精度：
```c
typedef long double REAL;
```
如果在不支持 long double 的机器上运行相关代码，只需要对对应的typedef语句进行修改，例如：
```c
typedef double REAL;
```
或者：
```c
typedef float REAL;
```
#### 2）使用typedef为现有类型创建别名，给变量定义一个易于记忆且意义明确的新名字。
例如:
```c
typedef unsigned int UINT
```
#### 3）使用typedef简化一些比较复杂的类型声明。
例如：
```c
typedef void (*PFunCallBack)(char* pMsg, unsigned int nMsgLen);
```
上述声明引入了PFunCallBack类型作为函数指针的同义字，该函数有两个类型分别为char*和unsigned int参数，以及一个类型为int的返回值。通常，当某个函数的参数是一个回调函数时，可能会用到typedef简化声明。

例如，承接上面的示例，我们再列举下列示例：
```c
RedisSubCommand(const string& strKey, PFunCallBack pFunCallback, bool bOnlyOne);
```
`注意：`类型名PFunCallBack与变量名pFunCallback的大小写区别。
RedisSubCommand函数的参数是一个PFunCallBack类型的回调函数，返回某个函数（pFunCallback）的地址。在这个示例中，如果不用typedef，RedisSubCommand函数声明如下：
```c
RedisSubCommand(const string& strKey, void (*pFunCallback)(char* pMsg, unsigned int nMsgLen), bool bOnlyOne); 
```
从上面两条函数声明可以看出，不使用typedef的情况下，RedisSubCommand函数的声明复杂得多，不利于代码的理解，并且增加的出错风险。

所以，在某些复杂的类型声明中，使用typedef进行声明的简化是很有必要的。
## 3. typedef与#define
两者的区别如下：

* #define进行简单的进行字符串替换。 #define宏定义可以使用#ifdef、#ifndef等来进行逻辑判断，还可以使用#undef来取消定义。
* typedef是为一个类型起新名字。typedef符合（C语言）范围规则，使用typedef定义的变量类型，其作用范围限制在所定义的函数或者文件内（取决于此变量定义的位置），而宏定义则没有这种特性。

通常，使用typedef要比使用#define要好，特别是在有指针的场合里。

下面列举几个示例。

3.1 示例1

代码如下：
```c
typedef　char*　pStr1;
#define　pStr2　char*　
pStr1　s1, s2;
pStr2　s3, s4;
```
在上述的变量定义中，s1、s2、s3都被定义为char*类型；但是s4则定义成了char类型，而不是我们所预期的指针变量char*，这是因为#define只做简单的字符串替换，替换后的相关代码等同于为：
```c
char*　s3, s4;
```
而使用typedef为char*定义了新类型pStr1后，相关代码等同于为：
```c
char *s3, *s4;
```
3.1 示例2
代码如下：
```c
typedef char *pStr;
char string[5]="test";
const char *p1=string;
const pStr p2=string;
p1++;
p2++;
```
`error:increment of read-only variable 'p2'`
根据错误信息，能够看出p2为只读的常量了，所以p2++出错了。这个问题再一次提醒我们：typedef和#define不同，typedef不是简单的文本替换，上述代码中const pStr p2并不等于const char * p2，pStr是作为一个类型存在的，所以const pStr p2实际上限制了pStr类型的p2变量，对p2常量进行了只读限制。也就是说，const pStr p2和pStr const p2本质上没有区别（可类比const int p2和int const p2），都是对变量p2进行只读限制，只不过此处变量p2的数据类型是我们自己定义的（pStr），而不是系统固有类型（如int）而已。

所以，const pStr p2的含义是：限定数据类型为char *的变量p2为只读，因此p2++错误。

`注意：`在本示例中，typedef定义的新类型与编译系统固有的类型没有差别。

