# Elasticsearch Wildcard Search


There is a problem about word segmentation when I use Chinese language in ES. Elasticsearch is the distributed, restful search and analytics engine. You can use Elasticsearch to store, search, and manage data for Logs，Metrics，A search backend，Application monitoring，Endpoint security.

<!--more-->

## 问题描述

{{< admonition question>}}

ES 使用 **wildcard** 进行模糊查询，有些情况模糊查询失败，如："\*日本\*"，但测试别的数据，如 "\*192.168\*" 可以模糊匹配。这是因为 ES 对查询文本分词造成的结果。

{{< /admonition >}}

## match：分词模糊查询

比如“Everything will be OK, All is well”，会被分词一个一个单词（不是单个字母）

```json
{
	"from": 0,
	"size": 20,
	"query": {
		"bool": {
			"should": [{
					"term": {
						"form_name": "will"
					}
				}
			]
		}
	}
}
```



## match_phrase ：短语模糊查询

match_phrase是短语搜索，即它会将给定的短语（phrase）当成一个完整的查询条件。

比如查询 “Everything will”，会当成一个完整的短语进行查询， 会查出含有该查询条件的内容。

```json
GET /basic_index*/_search
{
	"from": 0,
	"size": 20,
	"query": {
		"bool": {
			"should": [{
					"match": {
						"form_name": "Everything will"
					}
				}
			]
		}
	}
}
```

如果是查询单个字母，match就不管用了。



## wildcard：通配符模糊查询

| ?    | 匹配任意字符      |
| ---- | ----------------- |
| *    | 匹配0个或多个字符 |

```json
GET /basic_index*/_search
{
	"size": 20,
	"from": 0,
	"query": {
		"bool": {
			"should": [{
				"wildcard": {
					"form_name": "*very*
				}
			}]
		}
	}
}
```

记录是存在的，但是没有查出来？ 因为分词的影响，添加keyword 进行处理

```json
{
	"wildcard": {
		"form_name.keyword": "*very*"
	}
}
```

Wildcard 性能会比较慢。如果非必要，尽量避免在开头加通配符 ? 或者 *，这样会明显降低查询性能

如果查询的内容非空，怎么处理？ 直接用**

```json
{
	"wildcard": {
		"form_name": "*"
	}
}
```



## 总结

 Es 模糊查询， 分词的用match； 短语的用match_phrase；查询任意的，用wildcard通配符，注意查询的内容是否分词，分词的添加keyword，查询非空的情况，用"**"。

