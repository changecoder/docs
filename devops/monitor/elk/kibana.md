# Kibana

## 一些基础性的介绍
* Kibana 网站是单页面应用，但是加载网页时很慢，刷新首页都需要 5 秒。
* Kibana会将自身的数据存储在ES中名为.kibana的索引中
* 访问/staus可查看Kibana自身的状态

## 主要功能
* 查询ES中的数据，并可以创建仪表盘，便于分析
* 管理ES的索引，进行多种配置
  
## 设置
* 设置Default工作区，只显示Kibana、Observability中需要用到的部分功能。
  * Date format: 显示的日期格式
  * defaultRoute: kibana网站登录之后默认跳转的页面，例如/app/discover
  * Maximum table cell height: Discover 页面每个文档显示的最大高度。建议设置为 0 ，即取消限制。否则一个文档包含的内容过长时，可能显示不全。
  * Number of rows ：Discover页面查询时返回的文档最大数量。
    * 默认值为 500 ，减小该值可以降低查询的耗时，特别是每个文档体积较大时。
    * 查询到文档之后，会先在浏览器中显示一部分文档。当用户向下翻页时，才动态加载后续的文档，直到显示出查询到的所有文档。

## Discover