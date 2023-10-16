---
title: "Unveiling the Top Frequency Leetcode and Crafting Effective Solutions"
# subtitle: ""
date: 2023-01-01T10:41:45+08:00
draft: false
# author: ""
# authorLink: ""
# description: ""
# license: ""
# images: []

tags: ["Java", "Algorithm"]
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

# admonition:
# {{< admonition tip>}}{{< /admonition >}}
# note abstract info tip success question warning failure danger bug example quote
# mermaid:
# {{< mermaid >}}{{< /mermaid >}}
---

<!--more-->

## F1 - 146. LRU缓存机制

https://leetcode.cn/problems/lru-cache

### 关键字

| 关键字                        | 对应信息                                    |
| ----------------------------- | ------------------------------------------- |
| 键值对                        |                                             |
| put 和 get 的时间复杂度为O(1) | 哈希表，而且可以通过 O(1) 时间通过键找到值  |
| 有出入顺序                    | 首先想到 栈，队列 和 链表。哈希表无固定顺序 |

### 补充

哈希链表 `LinkedHashMap` 直接满足要求

### 解题

+ 哈希表可以满足 O(1) 查找；

+ 链表有顺序之分，插入删除快，但是查找慢。

于是就有了哈希链表数据结构：

![img](1647580694-NAtygG-4.jpg " ")

> **为什么使用双链表而不使用单链表？**
>
> 删除操作也可能发生在链表的中间位置。如果使用单链表，删除节点时需要额外找到被删除节点的前驱节点，这会增加时间复杂度。

> 哈希表中已经存了 `key`，为什么链表中还要存 `key` 和 `val` 呢，只存 `val` 不就行了？

```java
public class LRUCache {
    class Node{
        int key;
        int val;
        Node preNode;
        Node nextNode;
        Node(int key, int val){
            this.key = key;
            this.val = val;
        }
    }
    Map<Integer, Node> map = new HashMap<Integer, Node>();
    int size;
    int capasity;
    Node head, tail;
    
    public LRUCache(int capasity){
        this.capasity = capasity;
        size = 0;
        head = new Node(0, 0);
        tial = new Node(0, 0);
        head.nextNode = tail;
        tail.preNode = head;
    }
    
    public int get(int key){
        Node node = map.get(key);
        if(node == null){
            return -1;
        }
        move2first(node);
        return node.val;
    }
    
    public void put(int key, int val){
        Node node = map.get(key);
        if(node != null){
            node.val = val;
            move2first(node);
        } else {
            Node newNode = new Node(key, val);
            map.put(key,newNode);
            addNode(newNode);
            size++;
            if(size > capasity){
                Node deleted = deleteLastNode();
                map.remove(deleted.key);
                size--;
            }
        }
    }
    
    private void move2first(Node node){
        deleteNode(node);
        addNode(node);
    }
    
    private void deleteNode(Node node){
        node.preNode.nextNode = node.nextNode;
        node.nextNode.preNode = node.preNode;
    }
    
    private void addNode(Node node){
        node.nextNode = head.nextNode;
        head.nextNode.preNode = node;
        head.nextNode = node;
        node.preNode = head;
    }
    
    private Node deleteLastNode(){
        Node res = tail.preNode;
        deleteNode(res);
        return res;
    }
}
```



## F2 - 206. 反转链表

https://leetcode.cn/problems/reverse-linked-list

### 解题

+ 方法一：双指针/三指针迭代

![迭代.gif](7d8712af4fbb870537607b1dd95d66c248eb178db4319919c32d9304ee85b602-迭代.gif " ")

1. 初始化节点
   + pre 用来指向 cur 指针前一个节点。初始是 null，因为链表尾节点的下一节点是 null
   + cur 指向当前节点。初始是 head
   + tmp 用来指向 cur 节点的下一个节点。初始是 null
2. `while(cur!=null)`, tmp 指向 cur 节点的下一个节点；修改 cur.next = pre; pre 指向 cur 相当于后移一位；cur 指向 tmp 相当于后移一位

```java
class Solution {
	public ListNode reverseList(ListNode head) {
		ListNode pre = null;
		ListNode cur = head;
		ListNode tmp = null;
		while(cur!=null) {
			tmp = cur.next;
			cur.next = pre;
			pre = cur;
			cur = tmp;
		}
		return pre;
	}
}
```

+ 方法二：递归

![递归.gif](dacd1bf55dec5c8b38d0904f26e472e2024fc8bee4ea46e3aa676f340ba1eb9d-递归.gif " ")

```java
class Solution {
	public ListNode reverseList(ListNode head) {
		if(head==null || head.next==null) {
			return head;
		}
        //这里的cur就是最后一个节点
		ListNode cur = reverseList(head.next);
		head.next.next = head;
		head.next = null;
		return cur;
	}
}
```

+ 方法三：利用外部空间

先申请一个动态扩容的数组或者容器，比如 ArrayList 这样的。 然后不断遍历链表，将链表中的元素添加到这个容器中。 再利用容器自身的 API，反转整个容器，这样就达到反转的效果了。 最后同时遍历容器和链表，将链表中的值改为容器中的值。



## F3 - 3. 无重复字符的最长子串

https://leetcode.cn/problems/longest-substring-without-repeating-characters

### 关键字

| 关键字                           | 模式识别                                                     |
| -------------------------------- | ------------------------------------------------------------ |
| 重复字符（或者说`出现一次以上`） | 一旦涉及出现次数，需要用到 **散列表**<br />构造子串，散列表存下标 |
| 子串                             | 涉及子串，考虑**滑动窗口**，滑动窗口就是队列<br />- 滑动窗口就是窗口扩张和窗口收缩 |

### 解题

```java
class Solution{
    public int lengthOfLongestSubstring(String s){
        int left = 0;
        int max = 0;
        HashMap<Character, Integer> map = new HashMap<Character, Integer>();
        for(int right = 0; right < s.length(); right++){
            if(map,containsKey(s.charAt(right))){
                //碰到了重复字符，使窗口左窗向移动到后面遇到的这个重复字符后面
                left = Math.max(left, map.get(s.charAt(right)) + 1);
            }
            //在碰到重复字符之前，右窗口一直向右移动，并记录最大长度
            map.put(s.charAt(right), right);
            max = Math.max(max, right - left + 1);
        }
        return max;
    }
}
```



## F59 - 239. 滑动窗口最大值

### 解题

**单调队列**

+ 遍历给定数组中的元素，如果队列不为空且当前元素大于等于队尾元素，则将队尾元素移除。直到，队列为空或当前考察元素小于新的队尾元素；
+ 当队首元素的下标小于滑动窗口左侧边界left时，表示队首元素已经不再滑动窗口内，因此将其从队首移除。
+ 由于数组下标从0开始，因此当窗口左边界大于等于0时，意味着窗口形成。此时，队首元素就是该窗口内的最大值。

```java
class Solution {
    public int[] maxSlidingWindow(int[] nums, int k) {
        int[] res = new int[nums.length - k + 1];
        Deque<Integer> queue = new LinkedList<Integer>();
        for(int right = 0; right < nums.length; right++){
            while(!queue.isEmpty() && nums[queue.peekLast()] < nums[right]){
                queue.removeLast();
            }
            queue.addLast(right);
            int left = right - k + 1;
            if(queue.peekFirst() < left){
                queue.removeFirst();
            }
            if(left >= 0){
                res[left] = nums[queue.peekFirst()];
            }
        }
        return res;
    }
}
```



## F105 - 739. 每日温度

### 关键字

| 关键字                                                       | 模式识别                 |
| ------------------------------------------------------------ | ------------------------ |
| "下一个更大元素"<br />"下一个更小元素"<br />"连续子数组"<br />"某种最值" | 单调栈(通常是递增或递减) |

### 解题

+ 遍历每日温度，维护一个单调栈
  + 若栈为空或者当日温度<=栈顶温度则直接入栈
  + 反之 > 的话，说明栈顶元素的升温日找到，将栈顶元素出栈，计算两个日期相差的天数即可。
+ 栈里存日期还是存温度：要求的是升温的天数，而不是温度。所以栈中存下标而非温度

```java
class Solution {
    public int[] dailyTemperatures(int[] temperatures) {
        Deque<Integer> stack = new LinkedList<Integer>();
        int[] answer = new int[temperatures.length];
        for(int i = 0; i < temperatures.length; i++){
            while(!stack.isEmpty() && temperatures[i] > temperatures[stack.peek()]){
                int preHotDay = stack.pop();
                answer[preHotDay] =  i - preHotDay;
            }
            stack.push(i);
        }
        return answer;
    }
}
```



## F199 - 279. 完全平方数

### 关键字

| 关键字                                                 | 模式匹配 |
| ------------------------------------------------------ | -------- |
| 可以拆分成子问题解决<br />如 "从结果倒推" 的爬楼梯问题 | 动态规划 |

### 解题

```java
class Solution {
    public int numSquares(int n) {
        // n + 1长度，0不用，使得 temp[n] 和 n 对其。值均为0
        int[] temp = new int[n + 1];
        for(int i = 1; i < n + 1; i++){
            temp[i] = i;
            for(int j = 1;(i - j * j) >= 0 ; j++){
                temp[i] = Math.min(temp[i], temp[i - j * j] + 1);
            }
        }
        return temp[n];
    }
}
```
