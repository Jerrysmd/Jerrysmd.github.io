# The problem about file reading one more line

Getline ()/get()/read() will read one more line. The cause may be a problem with the file itself or the getline() function. You can judge getLine ()/get()/read() while checking, and then process the data if you get it. 
<!--more-->
**Insert Lead paragraph here.**
## 1. 问题原因
### 1. 问题1: 文件末尾存在回车
```c
　　while (!feof(fp))
　　{
　　	fgets(buffer,256,fp);
　　	j++;
　　}
```
feof（）这个函数是用来判断指针是否已经到达文件尾部的。若fp已经指向文件末尾，则feof（fp）函数值为“真”，即返回非零值；否则返回0。

如果文件还有换行或者空格的时候， 他会继续循环。
### 2.问题2: getline(s,1024,'\n')函数
```c
　　while(!feof(s))
　　{
    　　infile.getline(s,1024,'\n');
　　}
```
最后语句<mark>infile.getline(s,1024,'\n')</mark>未读到内容，出错后，变量s的内容并没改变，程序仍可继续执行，使s中的原数据再使用了一次。
## 2. 解决方法
### 1. fgets放到while里判断
```c
　　while (fgets(buffer,256,fp))
　　{
　　	j++;
　　}
```
### 2.getline放到while里判断
```c
　　while(infile.getline(s,1024,'\n'))
　　{
　　　　.......
　　}
```
即infile.getline(s,1024,'\n')正确读到数据后再处理。

同理，对get()/read()等都类似处理。

