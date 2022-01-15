# Logstash
Logstash 是一款强大的数据处理工具，它可以实现数据传输，格式处理，格式化输出，还有强大的插件功能，常用于日志处理。

## 工作原理
* Linux系统上通常通过管道符筛选日志，而Logstash处理数据的机制也称为管道（pipeline），每条数据称为一个事件（event）。
* Logstash可以运行多个管道，多个管道可以分为三个阶段
  * input: 输入数据
  * filter: 过滤，修改数据。该阶段可以省略
  * output: 输出数据

### 输入
* file: 从文件系统上的文件读取
* syslog: 在已知端口上侦听syslog消息进行解析
* redis: 使用redis通道和redis列表从redis服务器读取。
* beats: 处理 Beats发送的事件,beats包括filebeat、packetbeat、winlogbeat。
* 消息队列kafaka,rabbitmq等
  
### 过滤
一般会使用以下过滤器
* grok: 解析并构造任意文本。Grok是目前Logstash中将非结构化日志数据解析为结构化和可查询内容的最佳方式。
* mutate: 对事件字段执行常规转换。您可以重命名，删除，替换和修改事件中的字段。
* drop: 完全删除事件，例如调试事件。
* clone: 制作事件的副本，可能添加或删除字段。
* geoip：用于查询IP地址对应地理位置，包括经纬度坐标、国家名、城市名等(查询时的开销比较大)
* json: 用于按JSON格式解析event的一个字段。
* date: 用于解析event的一个字段，获取时间。
### 输出
* elasticsearch: 将事件数据发送给Elasticsearch。
* file: 将事件数据写入磁盘上的文件。
* graphite: 不做介绍
* statsd: 不做介绍
  
## 缺点
有点不想提，就说缺点
* Logstash耗资源较大，运行占用CPU和内存高。另外没有消息队列缓存，存在数据丢失隐患。

## 创建一个管道
redis.pipeline.conf
```

```

## 配置
logstash.yml
```
http.host: "0.0.0.0"
xpack.monitoring.elasticsearch.hosts: [ "http://elasticsearch:9200" ]
## X-Pack security credentials
xpack.monitoring.enabled: true
xpack.monitoring.elasticsearch.username: elastic
xpack.monitoring.elasticsearch.password: XXX
## pipeline
pipeline:
  batch:
    size: 125   # input 阶段每接收指定数量的事件，才打包成一个 batch ，供 filter、output 阶段的一个 worker 处理。增加该值会提高处理速度
    delay: 50   # 收集 batch 时，等待接收新事件的超时时间，单位 ms 。如果等待超时，则立即打包成一个 batch 。每个新事件会单独考虑超时时间
  workers: 2    # 处理 filter、output 阶段的线程数，默认等于CPU核数。可以大于CPU核数，因为输出阶段的worker会等待网络IO而不占用CPU
```
* pipeline在内存中处理的event最大数量为size * workers
* 接收一个batch的最长耗时为size * delay


## 部署
docker-compose.yml
```
version: $VERSION

services:
  logstash:
    image: logstash:$ELASTIC_VERSION
    container_name: logstash
    environment:
      LS_JAVA_OPTS: "-Xmx512m -Xms512m"
    volumes:
      - $LOGSTASH_CONFIG_PATH:/usr/share/logstash/config/logstash.yml
      - $LOGSTASH_PIPELINE_PATH:/usr/share/logstash/pipeline
      - /etc/localtime:/etc/localtime
    ports:
      - 5044:5044
    networks:
      - elk
    depends_on:
      - elasticsearch
```
此处是ELK一起部署的，贴出部分内容需要上下文了解

## config下目录介绍
* conf.d: 存放一些管道的定义文件
* jvm.options: JVM的配置，比如限制内存，目前我在容器环境设置内存限制为512m，但实际确实配置文件中见到的1g
* log4j2.properties: Java 日志的配置
* logstash.yml: logstash 本身的配置
* pipelines.yml: 定义管道
* startup.options: 自定义 logstash 启动命令的配置，供 systemd 读取
PS: 与config目录同级有一个pipeline目录，定义了logstash默认启动的管道

## 插件

### codec
用于按特定的文本格式编码、解码数据，可以用于 pipeline 的 input 或 output 阶段。