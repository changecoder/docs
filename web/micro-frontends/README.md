# Micro Frontends
微前端的概念是由ThoughtWorks在2016年提出的，它借鉴了微服务的架构理念，核心在于将一个庞大的前端应用拆分成多个独立灵活的小型应用，每个应用都可以独立开发、独立运行、独立部署，再将这些小型应用融合为一个完整的应用，或者将原本运行已久、没有关联的几个应用融合为一个应用。

微前端既可以将多个项目融合为一，又可以减少项目之间的耦合，提升项目扩展性，相比一整块的前端仓库，微前端架构下的前端仓库倾向于更小更灵活。

## 概念
微前端分为主应用和子应用，主应用也称为基座应用，是其它应用的容器载体，子应用则是被嵌入方

## 业务场景
1. 随着项目迭代应用越来越庞大，难以维护。
2. 跨团队或跨部门协作开发项目导致效率低下的问题。

## iframe
iframe 作为 HTML 标准的组件，自带支持独立的 CSS 样式和 JS 运行环境隔离，用来实现微前端有着天然的优势。

与此同时，强隔离的属性也带来一些弊端：
* 独立的两个页面在相互进行控件布局的时候存在着一定的区域限制，在实现如模态弹框的场景中灵活性非常低
* 无法保存子应用路由状态，重新载入后可能存在状态丢失的问题
* cookie之间相互隔离
* 子父应用之间不能直接保存和传递
* 应用间的通信只能依赖postMessage机制，十分不便。
* 性能低
* 双滚动条，弹窗无法全局覆盖

如果这些缺点都可以接受或者影响不大的情况下， iframe 可以说是接入微前端架构最快的方案了。

## npm包
将子应用封装成npm包，通过组件的方式引入，在性能和兼容性上是最优的方案

缺点是版本发布需要通知接入方同步更新，管理上存在缺陷
## 开源项目
鉴于iframe的缺陷, 业界产生了诸如 single-spa、qiankun、micro-app 等框架提供微前端接入方案，通过在同一页面中载入子、主应用的方式来规避上述的问题、提升用户体验。

* single-spa: 通过监听 url change 事件，在路由变化时匹配到渲染的子应用并进行渲染，这个思路也是目前实现微前端的主流方式。同时single-spa要求子应用修改渲染逻辑并暴露出三个方法：bootstrap、mount、unmount，分别对应初始化、渲染和卸载，这也导致子应用需要对入口文件进行修改。

* qiankun: 基于single-spa进行封装，除了继承single-spa特性外，并且需要对webpack配置进行一些修改。

* micro-app: 类WebComponent + HTML Entry。
  * WebComponent: 拥有两个核心组件CustomElement和ShadowDom，CustomElement用于创建自定义标签，ShadowDom用于创建阴影DOM，阴影DOM具有天然的样式隔离和元素隔离属性。
    * 由于WebComponent是原生组件，它可以在任何框架中使用，理论上是实现微前端最优的方案。但WebComponent有一个无法解决的问题 - ShadowDom的兼容性非常不好，一些前端框架在ShadowDom环境下无法正常运行，尤其是react框架。
  * 类WebComponent: 就是使用CustomElement结合自定义的ShadowDom实现

对比

| 框架          |   载入方式                          |   CSS样式隔离              |   JS运行隔离               |  子应用接入成本 |
| :---          |    :----:                         |   :----:                  |     :----:               |        ---:  |
| single-spa    |   JS Entry                        |        /                  | /                        | 单独打包 |
| qiankun       |   HTML Entry                      |   Scoped / shadowDOM      | Proxy / Snapshot 机制     | 根据 window.__POWERED_BY_QIANKUN__ 字段执行不同初始化方法    |
| micro-app     |   HTML Entry（Custom Elements）    |   Scoped / shadowDOM      | Proxy                    | 无需修改 |

## 载入渲染方式

### JS Entry
在主应用的同一页面载入子应用，可以通过将子应用的所有资源（包括布局、功能逻辑与素材）打包进一个js文件里，并将这个文件作为资源的入口在主应用引入，参考[single-spa](https://github.com/joeldenning/simple-single-spa-webpack-example/blob/master/src/root-application/root-application.js)的实现。

这种方式增加了主子应用的耦合性，且加载子应用的过程中无法并行加载，存在单个资源过大的问题，较难提升整体的效率；但该方案对应用的部署流程较为便捷，且要求较低。

### HTML Entry
主应用在运行时通过提供单独打包好的子应用URL地址，以fetch方式获取子应用的HTML文件，经过处理后在指定的容器中插入HTML内容，这样的方式称为HTML Entry。

相较于JS Entry方式，html Entry有着更低的耦合性和更大的灵活度，支持主应用在fetch后进行二次处理，通过 CSS 增加前缀、JS sandbox 等方式实现样式隔离和 JS 沙箱隔离，且能对静态资源采用并行加载，子应用的更新可以单独发布。

但这种方式必须需要子应用支持跨域。

## 环境隔离

### CSS样式隔离
除了single-spa默认不提供样式隔离功能外，其余主流的微前端框架都实现了基于子应用作用域下的CSS样式隔离（原理类似 Vue 的 style scpoed 实现方式）。核心步骤如下:
* 遍历HTML文档中style标签下的CSS文件
* 解析CSS文件内容
* 为每个样式添加前缀
通过上述的三个步骤，为每个选择器加上子应用框架的名称，从而实现子应用样式的独立。但此方案仍存在问题
* 主应用的样式仍然会影响到子应用，在使用时候应当注意规避样式污染。
进一步处理方案
* 基于Web Components方式实现的微前端框架还可以通过shadowDOM 实现方式达到更好的样式隔离效果
* 但随之带来用户使用过程中（仅现代浏览器支持）、开发过程中（React、Vue3）的兼容性问题也需要注意。

### JS运行环境隔离
现有的一众微前端框架在运行时的状态下要做到模拟多个环境的方案，采用的大多是 sandbox 的思想，不同框架间的区别就是怎么去给子应用构造这套环境。
* qiankun: 在支持JS Proxy的环境下，通过复制window下的属性，并通过Proxy进行代理，达到单独为子应用构造一个独立的window对象环境的目的。
  * 在不支持 Proxy 的浏览器环境中，qiankun 也提供了一套降级方案：snapshotSandBox。核心的思想是对 window 对象在子应用激活的时候进行遍历并快照备份，并在子应用销毁的时候进行 diff ，将修改后的属性进行还原。
* micro-app: [实现](https://github.com/micro-zoe/micro-app/issues/19)的方法与qiankun类似，并对全局方法进行了重写处理

## 应用通信
参考 qiankun 的[initGlobalState API](https://qiankun.umijs.org/zh/api#initglobalstatestate)。
* 主应用向子应用传递数据
  * 大多数的微前端框架都会通过props的形式
* 主应用获取子应用的数据
  * qiankun 在框架层面没有提供一个现成的方法，但我们可以简单通过在子应用注册时的props参数中传递一个钩子函数，子应用在需要向上传递数据的时候调用即可实现这个功能。
  * micro-app在框架层提供了 dispatch 函数供实现子应用向基座应用发送数据的功能，方法大同小异，子应用可以通过名称为 microApp 的被注入的全局对象与基座应用进行数据交互