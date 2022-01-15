# ELK
一个对大量数据（通常是日志）进行采集、存储、展示的系统，又称为 ELK Stack 或 Elastic Stack ，由Elastic公司发布

## ELK系统
ELK系统主要由多个软件组成:
* ElasticSearch: 用于存储数据，并支持查询
* Logstash: 用于收集日志数据，解析成格式化数据之后，发送到ES中存储
* Kibana: 一个基于node.js运行的Web服务器，用于查询、展示ES中存储的数据。

### ELK系统补充
ELK 系统还可以选择加入以下软件：
* Beats: 采用 Golang 开发，用于采集日志数据。比Logstash更轻量级，但功能较少。
* Elastic Agent: v7.8 版本新增的软件，用于采集日志数据。它集成了不同类型的 Beats 的功能。
* Observability: 为Kibana扩展了一些日志可视化的功能，比如实时查看日志、设置告警规则。
* Security: 用于监控一些安全事项。
* APM（Application Performance Monitoring: 用于采集、监控应用程序的性能指标。
* Enterprise Search: 提供搜索功能，可以集成到业务网站的搜索栏中。

## 工作流程
* 在每个主机上部署 Beats 进程，自动采集日志，然后发送到 Logstash。
* Logstash 将日志解析成JSON格式，然后发送到ES中存储。
* 用户使用Kibana ，从ES中查询日志数据并展示。

### 工作流程补充
* 在高并发的场景下，会让Beats将采集的日志先发送到Kafka/Redis缓冲，然后让Logstash从kafka/redis获取数据