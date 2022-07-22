# Flink Optimization


Flink optimization includes resource configuration optimization, back pressure processing, data skew, KafkaSource optimization and FlinkSQL optimization.

<!--more-->

## 资源配置调优

### 内存设置

给任务分配资源，在一定范围内，增加资源的分配与性能的提升是正比的（部分情况如资源过大，申请资源时间很长）。

提交方式主要是 yarn-per-job，资源的分配在使用脚本提交 Flink 任务时进行指定。

目前通常使用客户端模式，参数使用 -D<property=value> 指定

```shell
bin/fink run \
-t yarn-per-job \
-d \
-p 5 \ 指定并行度
-Dyarn.application.queue=test \ 指定 yarn 队列
-Djobmanager.memory.process.size=2048mb \ jm 2-4G足够
-Dtaskmanager.memory.process.size=6144mb \ 单个 tm 2-8G 足够
-Dtaskmanager.numberOfTaskSlots=2 \ 与容器核数 1core:1slot 或 1core:2slot
```

### 并行度设置

#### 最优并行度计算

完成开发后，压测，任务并行度给 10 以下，测试单个并行度的处理上限。然后 `总 QPS / 单并行度的处理能力 = 并行度`

不能只根据 QPS 得出并行度，因为有些字段少，逻辑简单任务。最好根据高峰期的 QPS 压测，并行度 * 1.2，富余一些资源。

{{< admonition question 关于各种框架优化的回答>}}

问法：做过什么优化？ 解决过什么问题？遇到哪些问题？

1. 说明业务场景；
2. 遇到了什么问题 --> 往往通过监控工具结合报警系统；
3. 排查问题；
4. 解决手段；
5. 问题被解决。

{{< /admonition >}}

