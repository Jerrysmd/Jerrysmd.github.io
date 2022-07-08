---
title: "C language realize HashMap" # Title of the blog post.
date: 2018-04-05T21:56:51-08:00 # Date of post creation.
description: "Article description." # Description used for search engine.
featured: true # Sets if post is a featured post, making appear on the home page side bar.
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
  - Hash code
# comment: false # Disable comment if false.

---

Hash table is a very important data structure, which is useful in many application scenarios. This paper will simply analyze the principle of hash table, and use C language to achieve a complete HashMap. 
<!--more-->

## 1. 什么是HashMap？

存储方式主要有两种`线性存储`和`链式存储`，常见的线性存储例如数组，常见的链式存储如链表、二叉树等。哈希表的存储主干为线性存储，这也是它在理想状态(无冲突)下时间复杂度为`O(1)`的关键所在。普通线性存储的存储内容与索引地址之间没有任何的联系，只能通过索引地址推算出存储内容，不能从存储内容推算出索引地址，是一个<mark>单向不可逆</mark>的过程，而HashMap存储的是一个<mark><key, value></mark>的键值对，通过key和索引地址建立了一层关系，这层关系称之为哈希函数(或散列函数)，这样既可以通过key推算出索引地址，也可以通过推算出的索引地址直接定位到键值对，这是一个<mark>双向可逆</mark>的过程。需要注意的一点是HashMap并不直接暴露出键值对的索引地址，但是可以通过哈希函数推算出`HashCode`，其实HashCode就是真实的索引地址。

## 2. 定义键值对结构

```c
typedef struct entry {
    void * key;             // 键
    void * value;           // 值
    struct entry * next;    // 冲突链表
}*Entry;

#define newEntry() NEW(struct entry)
#define newEntryList(length) (Entry)malloc(length * sizeof(struct entry))
```

哈希冲突是指两个不同的key值得到了一个相同的HashCode，这种情况称之为<mark>哈希冲突</mark>，一个好的哈希函数很大程度上决定了哈希表的性能，不存在一种适合所有哈希表的哈希函数，在很多特定的情景下，需要有针对性的设计哈希函数才能达到理想的效果。当然啦，还是有一些优秀的哈希函数可以应对大多数情况的，对于性能要求不是很高的场景用这些就可以了。使用HashMap的时候难免会发生冲突，常用的方法主要分为两类：`再散列法`和`链地址法`。再散列法就是发生冲突时使用另一个哈希函数重新推算，一直到不冲突为止，这种方法有时候会造成数据堆积，就是元素本来的HashCode被其它元素再散列的HashCode占用，被迫再散列，如此恶性循环。链地址法就是在冲突的位置建立一个链表，将冲突值放在链表中，检索的时候需要额外的遍历冲突链表，本文采用的就是链地址法。

## 3. 定义HashMap结构体

HashMap结构的存储本体是一个数组，建立一个<mark>Entry数组</mark>作为存储空间，然后根据传入的key计算出HashCode，当做数组的索引存入数据，读取的时候通过计算出的HashCode可以在数组中直接取出值。

`size`是当前存储键值对的数量，而`listSize`是当前数组的大小，仔细观察键值对结构会发现，数组的每一项其实都是冲突链表的头节点。因为冲突的存在，就有可能导致size大于listSize，当size大于listSize的时候一定发生了冲突，这时候就会扩容。

在结构体中放了一些常用的方法，因为C语言本身并没有类的概念，为了便于内部封装(经常会有一个方法调用另一个方法的时候)，可以让用户自定义一个方法而不影响其它方法的调用。举个简单的例子，put方法中调用了hashCode函数，如果想自定义一个hashCode方法，迫不得已还要再实现一个put方法，哪怕put中只改了一行代码。

结构体定义如下：

```c
// 哈希结构
typedef struct hashMap *HashMap;
#define newHashMap() NEW(struct hashMap)

// 哈希函数类型
typedef int(*HashCode)(HashMap, void * key);

// 判等函数类型
typedef Boolean(*Equal)(void * key1, void * key2);

// 添加键函数类型
typedef void(*Put)(HashMap hashMap, void * key, void * value);

// 获取键对应值的函数类型
typedef void * (*Get)(HashMap hashMap, void * key);

// 删除键的函数类型
typedef Boolean(*Remove)(HashMap hashMap, void * key);

// 清空Map的函数类型
typedef void(*Clear)(HashMap hashMap);

// 判断键值是否存在的函数类型
typedef Boolean(*Exists)(HashMap hashMap, void * key);

typedef struct hashMap {
    int size;           // 当前大小
    int listSize;       // 有效空间大小
    HashCode hashCode;  // 哈希函数
    Equal equal;        // 判等函数
    Entry list;         // 存储区域
    Put put;            // 添加键的函数
    Get get;            // 获取键对应值的函数
    Remove remove;      // 删除键
    Clear clear;        // 清空Map
    Exists exists;      // 判断键是否存在
    Boolean autoAssign;	// 设定是否根据当前数据量动态调整内存大小，默认开启
}*HashMap;

// 默认哈希函数
static int defaultHashCode(HashMap hashMap, void * key);

// 默认判断键值是否相等
static Boolean defaultEqual(void * key1, void * key2);

// 默认添加键值对
static void defaultPut(HashMap hashMap, void * key, void * value);

// 默认获取键对应值
static void * defaultGet(HashMap hashMap, void * key);

// 默认删除键
static Boolean defaultRemove(HashMap hashMap, void * key);

// 默认判断键是否存在
static Boolean defaultExists(HashMap hashMap, void * key);

// 默认清空Map
static void defaultClear(HashMap hashMap);

// 创建一个哈希结构
HashMap createHashMap(HashCode hashCode, Equal equal);

// 重新构建
static void resetHashMap(HashMap hashMap, int listSize);
```

HashMap的所有属性方法都有一个默认的实现，创建HashMap时可以指定哈希函数和判等函数(用于比较两个key是否相等)，传入NULL时将使用默认函数。这些函数都被设置为了static，在文件外不可访问。

## 4. 哈希函数

```c
int defaultHashCode(HashMap hashMap, let key)
{
    IN_STACK;
    string k = (string)key;
    unsigned long h = 0;
    while (*k) {
        h = (h << 4) + *k++;
        unsigned long g = h & 0xF0000000L;
        if (g) {
            h ^= g >> 24;
        }
        h &= ~g;
    }
    OUT_STACK;
    return h % hashMap->listSize;
}
```

key的类型为void *，是一个任意类型，HashMap本身也没有规定key值一定是string类型，上面的哈希函数只针对string类型，可以根据实际需要替换成其他。

## 5. put函数

用于在哈希表中存入一个键值对，首先先推算出HashCode，然后判断该地址是否已经有数据，如果已有的key值和存入的key值相同，改变value即可，否则为冲突，需要挂到冲突链尾部，该地址没有数据时直接存储。实现如下：

```c
void resetHashMap(HashMap hashMap, int listSize) {

    if (listSize < 8) return;

    // 键值对临时存储空间
    Entry tempList = newEntryList(hashMap->size);

    HashMapIterator iterator = createHashMapIterator(hashMap);
    int length = hashMap->size;
    for (int index = 0; hasNextHashMapIterator(iterator); index++) {
        // 迭代取出所有键值对
        iterator = nextHashMapIterator(iterator);
        tempList[index].key = iterator->entry->key;
        tempList[index].value = iterator->entry->value;
        tempList[index].next = NULL;
    }
    freeHashMapIterator(&iterator);

    // 清除原有键值对数据
    hashMap->size = 0;
    for (int i = 0; i < hashMap->listSize; i++) {
        Entry current = &hashMap->list[i];
        current->key = NULL;
        current->value = NULL;
        if (current->next != NULL) {
            while (current->next != NULL) {
                Entry temp = current->next->next;
                free(current->next);
                current->next = temp;
            }
        }
    }

    // 更改内存大小
    hashMap->listSize = listSize;
    Entry relist = (Entry)realloc(hashMap->list, hashMap->listSize * sizeof(struct entry));
    if (relist != NULL) {
        hashMap->list = relist;
        relist = NULL;
    }

    // 初始化数据
    for (int i = 0; i < hashMap->listSize; i++) {
        hashMap->list[i].key = NULL;
        hashMap->list[i].value = NULL;
        hashMap->list[i].next = NULL;
    }

    // 将所有键值对重新写入内存
    for (int i = 0; i < length; i++) {
        Array x = tempList[i].value;
        hashMap->put(hashMap, tempList[i].key, tempList[i].value);
    }
    free(tempList);
}

void defaultPut(HashMap hashMap, let key, let value) {
    if (hashMap->autoAssign && hashMap->size >= hashMap->listSize) {

        // 内存扩充至原来的两倍
        // *注: 扩充时考虑的是当前存储元素数量与存储空间的大小关系，而不是存储空间是否已经存满，
        // 例如: 存储空间为10，存入了10个键值对，但是全部冲突了，所以存储空间空着9个，其余的全部挂在一个上面，
        // 这样检索的时候和遍历查询没有什么区别了，可以简单这样理解，当我存入第11个键值对的时候一定会发生冲突，
        // 这是由哈希函数本身的特性(取模)决定的，冲突就会导致检索变慢，所以这时候扩充存储空间，对原有键值对进行
        // 再次散列，会把冲突的数据再次分散开，加快索引定位速度。
        resetHashMap(hashMap, hashMap->listSize * 2);
    }

    int index = hashMap->hashCode(hashMap, key);
    if (hashMap->list[index].key == NULL) {
        hashMap->size++;
        // 该地址为空时直接存储
        Array x = value;
        hashMap->list[index].key = key;
        hashMap->list[index].value = value;
    }
    else {

        Entry current = &hashMap->list[index];
        while (current != NULL) {
            if (hashMap->equal(key, current->key)) {
                // 对于键值已经存在的直接覆盖
                current->value = value;
                return;
            }
            current = current->next;
        };

        // 发生冲突则创建节点挂到相应位置的next上
        Entry entry = newEntry();
        entry->key = key;
        entry->value = value;
        entry->next = hashMap->list[index].next;
        hashMap->list[index].next = entry;
        hashMap->size++;
    }
}
```

put函数还有一个重要的功能，当size大于listSize时要主动扩容，这个判定条件看似有些不合理，当size大于listSize的时候可能因为冲突的存在，数组并没有存满，这时候就扩容不是浪费存储空间吗？事实确实如此，但这其实是为了加快检索速度一种妥协的办法，上文提到过，当size大于listSize时一定会发生冲突，因为哈希函数为了不越界，都会将计算出的HashCode进行取余操作，这就导致HashCode的个数一共就listSize个，超过这个个数就一定会冲突，冲突的越多，检索速度就越向O(n)靠拢，为了保证索引速度消耗一定的空间还是比较划算的，扩容时直接将容量变为了当前的两倍，这是考虑到扩容时需要将所有重新计算所有元素的HashCode，较为消耗时间，所以应该尽量的减少扩容次数。

## 6. 其它函数

```c
let defaultGet(HashMap hashMap, let key) {
    int index = hashMap->hashCode(hashMap, key);
    Entry entry = &hashMap->list[index];
    while (entry->key != NULL && !hashMap->equal(entry->key, key)) {
        entry = entry->next;
    }
    return entry->value;
}

Boolean defaultRemove(HashMap hashMap, let key) {
    int index = hashMap->hashCode(hashMap, key);
    Entry entry = &hashMap->list[index];
    if (entry->key == NULL) {
        return False;
    }
    Boolean result = False;
    if (hashMap->equal(entry->key, key)) {
        hashMap->size--;
        if (entry->next != NULL) {
            Entry temp = entry->next;
            entry->key = temp->key;
            entry->value = temp->value;
            entry->next = temp->next;
            free(temp);
        }
        else {
            entry->key = entry->value = NULL;
        }
        result = True;
    }
    else {
        Entry p = entry;
        entry = entry->next;
        while (entry != NULL) {
            if (hashMap->equal(entry->key, key)) {
                hashMap->size--;
                p->next = entry->next;
                free(entry);
                result = True;
                break;
            }
            p = entry;
            entry = entry->next;
        };
    }

    // 如果空间占用不足一半，则释放多余内存
    if (result && hashMap->autoAssign &&  hashMap->size < hashMap->listSize / 2) {
        resetHashMap(hashMap, hashMap->listSize / 2);
    }
    return result;
}

Boolean defaultExists(HashMap hashMap, let key) {
    int index = hashMap->hashCode(hashMap, key);
    Entry entry = &hashMap->list[index];
    if (entry->key == NULL) {
        return False;
    }
    if (hashMap->equal(entry->key, key)) {
        return True;
    }
    if (entry->next != NULL) {
        do {
            if (hashMap->equal(entry->key, key)) {
                return True;
            }
            entry = entry->next;

        } while (entry != NULL);
        return False;
    }
    else {
        return False;
    }
}

void defaultClear(HashMap hashMap) {
    for (int i = 0; i < hashMap->listSize; i++) {
        // 释放冲突值内存
        Entry entry = hashMap->list[i].next;
        while (entry != NULL) {
            Entry next = entry->next;
            free(entry);
            entry = next;
        }
        hashMap->list[i].next = NULL;
    }
    // 释放存储空间
    free(hashMap->list);
    hashMap->list = NULL;
    hashMap->size = -1;
    hashMap->listSize = 0;
}

HashMap createHashMap(HashCode hashCode, Equal equal) {
    HashMap hashMap = newHashMap();
    hashMap->size = 0;
    hashMap->listSize = 8;
    hashMap->hashCode = hashCode == NULL ? defaultHashCode : hashCode;
    hashMap->equal = equal == NULL ? defaultEqual : equal;
    hashMap->exists = defaultExists;
    hashMap->get = defaultGet;
    hashMap->put = defaultPut;
    hashMap->remove = defaultRemove;
    hashMap->clear = defaultClear;
    hashMap->autoAssign = True; 
    // 起始分配8个内存空间，溢出时会自动扩充
    hashMap->list = newEntryList(hashMap->listSize);
    Entry p = hashMap->list;
    for (int i = 0; i < hashMap->listSize; i++) {
        p[i].key = p[i].value = p[i].next = NULL;
    }
    return hashMap;
}
```

## 7. Iterator接口

Iterator接口提供了遍历HashMap结构的方法，基本定义如下：

```c
// 迭代器结构
typedef struct hashMapIterator {
    Entry entry;    // 迭代器当前指向
    int count;      // 迭代次数
    int hashCode;   // 键值对的哈希值
    HashMap hashMap;
}*HashMapIterator;

#define newHashMapIterator() NEW(struct hashMapIterator)

// 创建一个哈希结构
HashMap createHashMap(HashCode hashCode, Equal equal);

// 创建哈希结构迭代器
HashMapIterator createHashMapIterator(HashMap hashMap);

// 迭代器是否有下一个
Boolean hasNextHashMapIterator(HashMapIterator iterator);

// 迭代到下一次
HashMapIterator nextHashMapIterator(HashMapIterator iterator);

// 释放迭代器内存
void freeHashMapIterator(HashMapIterator * iterator);
```

实现如下:

```c
HashMapIterator createHashMapIterator(HashMap hashMap) {
    HashMapIterator iterator = newHashMapIterator();
    iterator->hashMap = hashMap;
    iterator->count = 0;
    iterator->hashCode = -1;
    iterator->entry = NULL;
    return iterator;
}

Boolean hasNextHashMapIterator(HashMapIterator iterator) {
    return iterator->count < iterator->hashMap->size ? True : False;
}

HashMapIterator nextHashMapIterator(HashMapIterator iterator) {
    if (hasNextHashMapIterator(iterator)) {
        if (iterator->entry != NULL && iterator->entry->next != NULL) {
            iterator->count++;
            iterator->entry = iterator->entry->next;
            return iterator;
        }
        while (++iterator->hashCode < iterator->hashMap->listSize) {
            Entry entry = &iterator->hashMap->list[iterator->hashCode];
            if (entry->key != NULL) {
                iterator->count++;
                iterator->entry = entry;
                break;
            }
        }
    }
    return iterator;
}

void freeHashMapIterator(HashMapIterator * iterator) {
    free(*iterator);
    *iterator = NULL;
}
```

## 8. 使用测试

```c
#define Put(map, key, value) map->put(map, (void *)key, (void *)value);
#define Get(map, key) (char *)map->get(map, (void *)key)
#define Remove(map, key) map->remove(map, (void *)key)
#define Existe(map, key) map->exists(map, (void *)key)

int main() {

    HashMap map = createHashMap(NULL, NULL);
    Put(map, "asdfasdf", "asdfasdfds");
    Put(map, "sasdasd", "asdfasdfds");
    Put(map, "asdhfgh", "asdfasdfds");
    Put(map, "4545", "asdfasdfds");
    Put(map, "asdfaasdasdsdf", "asdfasdfds");
    Put(map, "asdasg", "asdfasdfds");
    Put(map, "qweqeqwe", "asdfasdfds");

    printf("key: 4545, exists: %s\n", Existe(map, "4545") ? "true" : "false");
    printf("4545: %s\n", Get(map, "4545"));
    printf("remove 4545 %s\n", Remove(map, "4545") ? "true" : "false");
    printf("remove 4545 %s\n", Remove(map, "4545") ? "true" : "false");
    printf("key: 4545, exists: %s\n", Existe(map, "4545") ? "true" : "false");

    HashMapIterator iterator = createHashMapIterator(map);
    while (hasNextHashMapIterator(iterator)) {
        iterator = nextHashMapIterator(iterator);
        printf("{ key: %s, value: %s, hashcode: %d }\n",
            (char *)iterator->entry->key, (char *)iterator->entry->value, iterator->hashCode);
    }
    map->clear(map);
    freeHashMapIterator(&iterator);

    return 0;
}
```

运行结果：

```
key: 4545, exists: true
4545: asdfasdfds
remove 4545 true
remove 4545 false
key: 4545, exists: false
{ key: asdfasdf, value: asdfasdfds, hashcode: 2 }
{ key: asdhfgh, value: asdfasdfds, hashcode: 2 }
{ key: sasdasd, value: asdfasdfds, hashcode: 2 }
{ key: asdfaasdasdsdf, value: asdfasdfds, hashcode: 6 }
{ key: asdasg, value: asdfasdfds, hashcode: 7 }
{ key: qweqeqwe, value: asdfasdfds, hashcode: 9 }
```