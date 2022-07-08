# SQL Introduction

In computer programming, create, read, update, and delete (CRUD) are the four basic functions of persistent storage. Alternate words are sometimes used when defining the four basic functions of CRUD, such as retrieve instead of read, modify instead of update, or destroy instead of delete. CRUD is also sometimes used to describe user interface conventions that facilitate viewing, searching, and changing information, often using computer-based forms and reports.
<!--more-->

### 1. 查询语句

|      | select ... | from ... | where ... | group by ... | having ... | order by ... | limit ... |
| ---- | ---------- | -------- | --------- | ------------ | ---------- | ------------ | --------- |
| 次序 | 4          | 1        | 2         | 3            | 5          | 6            | 7         |

### 2. Group by

GROUP BY 语句用于结合聚合函数，根据一个或多个列对结果集进行分组。

实例：

```sql
mysql> SELECT * FROM access_log;
+-----+---------+-------+------------+
| aid | site_id | count | date       |
+-----+---------+-------+------------+
|   1 |       1 |    45 | 2016-05-10 |
|   2 |       3 |   100 | 2016-05-13 |
|   3 |       1 |   230 | 2016-05-14 |
|   4 |       2 |    10 | 2016-05-14 |
|   5 |       5 |   205 | 2016-05-14 |
|   6 |       4 |    13 | 2016-05-15 |
|   7 |       3 |   220 | 2016-05-15 |
|   8 |       5 |   545 | 2016-05-16 |
|   9 |       3 |   201 | 2016-05-17 |
+-----+---------+-------+------------+
9 rows in set (0.00 sec)
```

```sql
SELECT site_id, SUM(access_log.count) AS nums
FROM access_log GROUP BY site_id;
+---------+------+
| site_id | nums |
+---------+------+
|   1     |  275 |
|   2     |   10 |
|   3     |  521 |
|   4     |   13 |
|   5     |  750 |
+---------+------+

```

### 3. 聚集函数

| 1     | 2    | 3    | 4    | 5    | 6            |
| ----- | ---- | ---- | ---- | ---- | ------------ |
| count | sum  | max  | min  | avg  | group_concat |

### 4. Having

HAVING 子句可以让我们筛选分组后的各组数据。

```sql
查询每个班中人数大于2的班级号：
select count(1) as n, classid from stu group by classid having n>2;
or
select classid from stu group by classid having count(1)>2;
```

### 5. Order by

```sql
... order by n, classid;
1.先按n排序
2.在不改n排序的情况下排classid
```

### 6. Limit

```sql
... limit 1, 10;
# 检索记录行 2-10
```

### 7. Join

```sql
stu join class on classid = class.id
# join 会把左表的每一行分别与右表每一行拼接
# on 做筛选
```


