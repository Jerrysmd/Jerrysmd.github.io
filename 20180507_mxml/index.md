# The realization of the MXML

MXML (Minimal XML) is a small, fast and versatile library that reads a whole XML file and puts it in a DOM tree.
<!--more-->
## 1.XML
XML特点和作用 :
  * XML 指可扩展标识语言（ eXtensible Markup Language）
  * XML 的设计宗旨是传输数据， 而非显示数据
  * XML 标签没有被预定义。 您需要自行定义标签。
  * 作为一种通用的数据存储和通信格式被广泛应用。
  * 描述的数据作为一棵树型的结构而存在。
```xml
<?xml version="1.0" encoding="utf-8"?>
<books>
    <book id="001">
        <author>wanger</author>
    </book>
</books>
```
## 2.mxml写入操作
<mark>mxml既可以创建写入xml文件，也可以解析xml文件数据</mark>
写入示例:
```c
#include"mxml.h"
int main()
{
    // create a new xml
    mxml_node_t *xml = mxmlNewXML("1.0");
    //add a node name books
    mxml_node_t *books = mxmlNewElement(xml,"books");
    //add a node under books name book
    mxml_node_t *book = mxmlNewElement(books,"book");
    //set attr
    mxmlElementSetAttr(book,"id","001");
    mxml_node_t *author = mxmlNewElement(book,"author");
    mxmlNewText(author,0,"wanger");

    FILE* fp = fopen("book.xml","wb");
    mxmlSaveFile(xml,fp,MXML_NO_CALLBACK);
    fclose(fp);
    mxmlDelete(xml);
    return 0;
}
```
## 3.mxml解析操作
解析步骤：
步骤：
 1. 打开一个xml文件
 2. 把文件加载到内存中，mxml_node_t mxmlLoadFile(mxml_node_t *top, FILE *fp,mxml_type_t (*cb)(mxml_node_t ));
 3. 查找待提取的节点标签：mxml_node_t *mxmlFindElement(mxml_node_t *node, mxml_node_t *top,const char *name, const char *attr,const char *value, int descend);
 4. 获取标签属性：const char *mxmlElementGetAttr(mxml_node_t *node, const char *name);
 5. 获取标签的文本内容： const char *mxmlGetText(mxml_node_t *node, int *whitespace);
 6. 释放节点，关闭文件
示例：
解析的文本：
```xml
<?xml version="1.0" encoding="utf-8"?>

<books>
  <book id="001">
    <author>wanger</author>
  </book>
</books>
```
代码：
```c
#include"mxml.h"
#include<stdio.h>

int main()
{
    FILE* fp = fopen("book.xml","r");
    // jiazai xml
    mxml_node_t* xml = mxmlLoadFile(NULL,fp,MXML_NO_CALLBACK);
    mxml_node_t* book = NULL;
    mxml_node_t* author = NULL;
    // find note
    book = mxmlFindElement(xml,xml,"book","id",NULL,MXML_DESCEND);
        //get attr
    author = mxmlFindElement(book,xml,"author",NULL,NULL,MXML_DESCEND);
    if(author == NULL)
    {
        printf("author error\n");
    }
    else
    {
        printf("book id is:%s\n",mxmlElementGetAttr(book,"id"));
        printf("author is:%s\n",mxmlGetText(author,NULL));
        book = mxmlFindElement(xml,xml,"book","id",NULL,MXML_DESCEND);
    }
    mxmlDelete(xml);
    fclose(fp);
    return 0;
}
```
结果：
```c
book id is:001
author is:wanger
```
## 4.mxml for循环解析长文件
xml文件:
```xml
<?xml version="1.0" encoding="utf-8"?>
<proto-meta-dump>
	<proto name="AH">
		<proto-class>crypto</proto-class>
		<proto-suit>TCP/IP</proto-suit>
		<proto-desc></proto-desc>
		<dump-name></dump-name>
		<meta-data name="">
			<dump-on></dump-on>
			<dump-format></dump-format>
			<dump-name>totMeta</dump-name>
		</meta-data>
		<meta-data name="ah.spi">
			<dump-on></dump-on>
			<dump-format></dump-format>
			<dump-name>SPI</dump-name>
		</meta-data>
		<meta-data name="ah.sequence">
			<dump-on></dump-on>
			<dump-format></dump-format>
			<dump-name>seqNum</dump-name>
		</meta-data>
		<meta-data name="ah.length">
			<dump-on></dump-on>
			<dump-format></dump-format>
			<dump-name>payLen</dump-name>
		</meta-data>
		<meta-data name="ah.icv">
			<dump-on></dump-on>
			<dump-format></dump-format>
			<dump-name>ICV</dump-name>
		</meta-data>
	</proto>
	...
</proto-meta-dump>
```
解析代码：
```c
//open xml file
FILE* fp = fopen(fileName,"r");

//create mxml tree head node
mxml_node_t* tree = mxmlLoadFile(NULL,fp,MXML_NO_CALLBACK);

//build head node:proto_meta_dump
//第一层
mxml_node_t* proto = NULL;
//第二层
mxml_node_t* class = NULL;
mxml_node_t* suit = NULL;
mxml_node_t* desc = NULL;
mxml_node_t* name = NULL;
//第三层
mxml_node_t* meta_data = NULL;
mxml_node_t* dump_on = NULL;
mxml_node_t* dump_format = NULL;
mxml_node_t* dump_name = NULL;

//遍历第一层proto，mxmlFindElement函数：寻找下一个proto节点
for(proto = mxmlFindElement(tree,tree,"proto","name",NULL,MXML_DESCEND);proto!=NULL;proto = mxmlFindElement(proto,tree,"proto","name",NULL,MXML_DESCEND)){
	class = mxmlFindElement(proto,tree,"proto-class",NULL,NULL,MXML_DESCEND);
	suit = mxmlFindElement(proto,tree,"proto-suit",NULL,NULL,MXML_DESCEND);
	desc = mxmlFindElement(proto,tree,"proto-desc",NULL,NULL,MXML_DESCEND);
	name = mxmlFindElement(proto,tree,"dump-name",NULL,NULL,MXML_DESCEND);
	//拿到第一层数据
	printf("|proto:%s\n",mxmlElementGetAttr(proto,"name"));
	printf("    |----class:%s\n",mxmlGetText(class,NULL));
	printf("    |----suit:%s\n",mxmlGetText(suit,NULL));
	printf("    |----desc:%s\n",mxmlGetText(desc,NULL));
	printf("    |----name:%s\n",mxmlGetText(name,NULL));
	//遍历第二层meta-data
	for(meta_data = mxmlFindElement(proto,proto,"meta-data","name",NULL,MXML_DESCEND);meta_data!=NULL;meta_data = mxmlFindElement(meta_data,proto,"meta-data","name",NULL,MXML_DESCEND)){
		//拿到第二层数据
 		dump_on = mxmlFindElement(meta_data,proto,"dump-on",NULL,NULL,MXML_DESCEND);
		dump_id = mxmlFindElement(meta_data,proto,"dump-id",NULL,NULL,MXML_DESCEND);
		dump_format = mxmlFindElement(meta_data,proto,"dump-format",NULL,NULL,MXML_DESCEND);
		dump_name = mxmlFindElement(meta_data,proto,"dump-name",NULL,NULL,MXML_DESCEND);
			printf(...,mxmlGetText(...));
			...
	}
    }
mxmlDelete(tree);
fclose(fp);
```

