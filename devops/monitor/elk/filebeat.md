# Filebeat
轻量型日志采集器,用于转发和汇总日志与文件。

## Beats
Beats程序有多重类型
* Filebeat: 用于采集日志文件
* Packetbeat ：用于采集网络数据包的日志。
* Winlogbeat ：用于采集 Windows 的 event 日志。
* Metricbeat ：用于采集系统或软件的性能指标。
* Auditbeat ：用于采集Linux Audit进程的日志。

作者本人目前仅使用Filebeat采集nginx日志，因此只对Filebeat做详细说明

## 模块介绍
Filebeat 的主要模块:
* input ：输入端。
* output ：输出端。
* harvester ：收割机，负责采集日志。

### 输出端
Filebeat目前支持的输出端包括
* ES
* Logstash
* Kafka
* Redis
* File
* Console

同时只能启用一种输出端

## 工作原理

### 采集日志
* 日志事件(event): Filebeat每采集一条日志文本，都会保存为JSON格式的对象，称为日志事件
* 收割机(harvester): Filebeat会定期扫描（scan）日志文件，如果发现其最后修改时间改变，则创建harvester去采集日志。
  * 对每个日志文件创建一个 harvester ，逐行读取文本，转换成日志事件，发送到输出端。
    * 每行日志文本必须以换行符分隔，最后一行也要加上换行符才能视作一行。
  * harvester开始读取时会打开文件描述符，读取结束时才关闭文件描述符。
    * 默认会一直读取到文件末尾，如果文件未更新的时长超过 close_inactive ，才关闭。
  * 采集每个日志文件时，会记录已采集的字节偏移量（bytes offset）。
    * 每次harvester读取日志文件时，会从offset处继续采集。
    * 如果harvester发现文件体积小于已采集的offset，则认为文件被截断了，会从offset 0处重新开始读取。这可能会导致重复采集。

### 注册表
* Filebeat会通过registry文件记录所有日志文件的当前状态信息（State）。
  * 即使只有一个日志文件被修改了，也会在registry文件中写入一次所有日志文件的当前状态
  * registry 保存在data/registry/目录下
    * 删除该目录就会重新采集所有日志文件，这会导致重复采集。

### 发送日志
* 发布事件(publish event): Filebeat将采集的日志事件经过处理之后，会发送到输出端，该过程称为发布事件
  * event 保存在内存中，不会写入磁盘。
  * 每个event只有成功发送到输出端，且收到确认接收的回复，才视作发送成功
    * 如果发送event到输出端失败，则会自动重试。直到发送成功，才更新记录。
    * 因此，采集到的event至少会被发送一次。但如果在确认接收之前重启Filebeat，则可能重复发送。

#### event内容
* @timestamp: 采集时间（UTC）
* @metadata: 描述beat的信息
* agent: Beats的信息
* log: 采集的日志文件的信息，主要为采集的日志路径和偏移量
* message: 日志的原始内容（数据主体）
* fields: 自定义字段(配置文件中添加)
* tags: 自定义标签(配置文件中添加)

## 目录介绍
* data: 存储Filebeat实例的uuid号，以及日志读取历史记录。
* kibana: 接入kibana时,其提供可视化配置功能。
* logs: Filebeat运行日志
* modules.d: module配置参数，用于快速启动功能
* fields.yml: Filebeat提供针对不同组件，采集的参数名称类型等
* filebeat: 可执行文件
* filebeat.yml: 启动Filebeat时读取的配置文件

## 安装部署

### 基本配置
nginx.conf
```
  log_format access-json escape=json '{"@timestamp": "$time_iso8601",'
      '"ip": "$remote_addr",'
      '"domain": "$http_host",'
      '"request": "$request",'
      '"request-time": "$request_time",'
      '"uri": "$uri",'
      '"referer": "$http_referer",'
      '"x-forwarded": "$http_x_forwarded_for",'
      '"size": "$body_bytes_sent",'
      '"status": "$status",'
      '"cookie": "$http_cookie",'
      '"user-agent": "$http_user_agent",'
      '"upstream-addr": "$upstream_addr",'
      '"upstream-status": "$upstream_status",'
      '"upstream-response_time": "$upstream_response_time"'
  '}';
```
access log可以设置为json格式，并将其内容设置在一行文本方便后续输入存储
error log nginx无法设置为json格式，且拥有默认格式，目前未去做更改

filebeat.yml
```
path.conf: ${path.home} # 配合文件的路径，默认是项目根目录

# 输入设置
filebeat.inputs:
- type: log
  enabled: true
  # json.add_error_key: true # 如果解析出错，则加入 error.message 等字段
  # json.keys_under_root: true # 是否将解析的字典保存为日志的顶级字段
  # json.overwrite_keys: true # 在启用了 keys_under_root 时，如果解析出的字段与原有字段冲突，是否覆盖
  paths:
    - /data/changecoder/web/logs/access.log
  tags: ["access"]

- type: log
  enabled: true
  paths:
    - /data/changecoder/web/logs/error.log
  tags: ["error"]

# 输出处理
processors:
  - drop_fields: # 丢弃一些字段
      ignore_missing: true # 忽略指定不存在的错误
      fields:
        - agent
        - log
        - ecs
        - host
        - input
  - rate_limit: # 限制发送event的速率
      limit: 1000/m # 最大1000个每分钟
      
# 输出选择为redis
output.redis:
  hosts: ["120.78.194.106:6379"]
  key: "web"
  password: "XXX"
  db: 0
  timeout: 10

# 配置kibana信息
setup.kibana:
  host: "120.78.194.106:5601"
  protocol: "http"
  username: "XXX"
  password: "XXX"

```
* 数据源设置: nginx的access.log和error.log文件被我们监听，并且由于access.log作为json格式被读取，设置到root节点上
  * 预期是将log中的@timestamp替换掉event的@timestamp，原因是event的@timestamp是UTC时间，而非本地时间(北京时间)，若在filebeat处无法处理，则需要在logstash处处理
  * 而实际以这种方式替换，需要nginx日期格式与filebeat日期格式一致，目前能解决的就是在nginx处自定义日期格式，但暂不需要
* 输出过滤: 丢弃掉agent, log, ecs, host, input, @metadata字段， 设置event的发送速率，在高并发下有效，目前没什么意义
  * 预期是将@metadata字段也过滤掉，但drop_fields，因此在logstash处做处理
* 输出设置: 存储到reids，让logstash去读取消费内容
* 设置kibana: 预期启动nginx模块，连接到kibana，自动创建dashboard
  * 暂未完成
  
docker-compose.yml
```
version: '3'
services:
  filebeat:
    image: elastic/filebeat:7.16.2
    container_name: filebeat
    volumes:
      - ~/data/filebeat/conf/filebeat.yml:/usr/share/filebeat/filebeat.yml
      - ~/data/filebeat/modules.d:/usr/share/filebeat/modules.d
      - ~/data/changecoder/web/logs:/data/changecoder/web/logs
      - /etc/localtime:/etc/localtime
```