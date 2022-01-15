# 单点登录
SSO, 全拼是Single Sign On

## 认证与授权
* 认证(Authentication): 即确认该用户的身份是他所声明的那个人。
* 授权(Authorization): 即根据用户身份授予他访问特定资源的权限。

## 协议
* CAS: Central Authentication Service, 仅用于Authentication的服务, 不能作为一种Authorization的协议。
* OAuth: 业界通常指OAuth 2.0，属于Authorization协议并不是一种Authentication协议
  * Authorization Code Grant: 授权码模式，最为常用，最安全。
  * Implicit Grant: 适用于SPA应用，已经不再推荐使用，被PKCE模式所替代。
  * Resource Owner Password Credentials Grant: 需要把用户的用户名和密码暴露给Client。
  * Client Credential Grant: 整个流程没有用户的概念，适用于服务端->服务端调用的场景。
* OpenID Connect: 简称OIDC, 是基于OAuth2.0扩展出来的一个协议。除了能够OAuth2.0中的Authorization场景，还额外定义了Authentication的场景。
* SAML: 全称为Security Assertion Markup Language，它是一个基于XML的标准协议。

### OAuth 2.0
* 支持Authentication: 否
* 支持Authorization: 是
* 传输方式: HTTP
* 票据格式: access_token,refresh_token, 协议定义为一个opaque的token，没有标准格式，取决于实现者
* 主要应用场景: B/S架构，基于浏览器的授权(通常情况下，授权的前提是需要登录，所以OAuth 2.0可以用来实现SSO)
* 优势: 协议简单实现，能够解决的场景比较多。成熟度高，社区支持广泛。
* 劣势: 各大厂商的实现细节有差异，例如钉钉和企业微信就不同。只定义了Authorization未定义Authentication
  
### OIDC
* 支持Authentication: 是
* 支持Authorization: 是
* 传输方式: HTTP
* 票据格式: access_token,refresh_token,id_token 协议定义为一个opaque的token，没有标准格式，取决于实现者, id_token是一个标准的JWT格式的token，且有标准的claim定义
* 主要应用场景: B/S架构，基于浏览器的SSO和授权场景，PKCE模式可用来实现移动端的SSO场景
* 优势: 协议简单实现，能够解决的场景比较多。成熟度高，社区支持广泛。可同时用来实现Authentication和Authorization
* 劣势: 和OAuth 2.0，有些场景需要服务端(RP) -> 服务端(OP)的调用，实际部署的时候可能存在网络不通的情况
* 推荐: 优先考虑授权码模式。移动端或者SPA应用，推荐使用PKCE模式
关于OIDC更细致的内容，请直接进入[OIDC](/service/auth/oidc.md)页