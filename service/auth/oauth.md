# OAuth
OAuth有1.0和2.0两个版本，但两者完全不同且不兼容，2.0是目前广泛使用的版本，同时我们谈论OAuth也是说的OAuth2.0

## 什么是OAuth
OAuth是一个关于授权（authorization）的开放网络标准

## OAuth的出现是解决什么问题的
* 在OAuth之前，鉴权是通过HTTP Basic Authentication，即输入用户名，密码的形式进行验证，这里就存在许多安全问题
* OAuth的出现就是为了解决访问资源的安全性以及灵活性。

### 如何解决的
* OAuth通过引入授权层来解决这些问题,并将client的角色和资源所有者的角色分开.在OAuth中,client请求资源所有者存放在资源服务器上的数据时,需要被资源所有者授予一组定义的权限.
  
* Client获取access token而不是通过资源所有者提供密钥来访问加密的资源,access token中包含了包括scope,lifetime和其他的访问参数.资源所有者同意后,授权服务器会发放access token给client,client使用access token来访问加密的资源.

## OAuth中心组件
* Scopes and Consent
* Actors
* Clients
* Tokens
* Authorization Server
* Flows


### Scopes
Scopes即Authorizaion时的一些请求权限，即与access token绑定在一起的一组权限。

OAuth Scopes将授权策略（Authorization policy decision）与授权执行分离开来。并会很明确的表示OAuth Scopes将会获得的权限范围。

### Actors & Clients
OAuth的流程中定义了四种角色:
* resource owner(RO): 资源所有者
* resource server(RS): 资源服务器
* client(Client): 请求访问加密资源的客户端,可以是任何形式(包括server, desktop或者其他设备)
* authorization server(AS): 授权服务器,颁发access token的服务

## 协议流程
```
     +--------+                               +---------------+
     |        |--(A)- Authorization Request ->|   Resource    |
     |        |                               |     Owner     |
     |        |<-(B)-- Authorization Grant ---|               |
     |        |                               +---------------+
     |        |
     |        |                               +---------------+
     |        |--(C)-- Authorization Grant -->| Authorization |
     | Client |                               |     Server    |
     |        |<-(D)----- Access Token -------|               |
     |        |                               +---------------+
     |        |
     |        |                               +---------------+
     |        |--(E)----- Access Token ------>|    Resource   |
     |        |                               |     Server    |
     |        |<-(F)--- Protected Resource ---|               |
     +--------+                               +---------------+
```

### Tokens
* Access token: 即客户端用来请求Resource Server(API). Access tokens通常是short-lived短暂的。access token是short-lived, 因此没有必要对它做revoke, 只需要等待access token过期即可。
* Refresh token: 当access token过期之后refresh token可以用来获取新的access token。refresh token是long-lived。refresh token可以被revoke。

Token从Authorization server上的不同的endpoint获取。主要两个endpoint为authorize endpoint和token endpoint. 
* authorize endpoint: 用来获得来自用户的许可和授权(consent and authorization)，并将用户的授权信息传递给token endpoint.
* token endpoint: 对用户的授权信息，处理之后返回access token和refresh token.

OAuth有两个流程，1.获取Authorization，2. 获取Token。这两个流程发送在不同的channel，Authorization发生在Front Channel（发生在用户浏览器）而Token发生在Back Channel。
* Front Channel: 客户端通过浏览器发送Authorization请求，由浏览器重定向到Authorization Server上的Authorization Endpoint，由Authorization Server返回对话框，并询问“是否允许这个应用获取如下权限”。Authorization通过结束后通过浏览器重定向到回调URL（Callback URL）。
* Back Channel: 获取Token之后，token应有由客户端应用程序使用，并与资源服务器（Resource Service）进行交互。

### Flows
* Implicit Flow: 所有OAuth的过程都在浏览器中完成，且access token通过authorization request (front channel only) 直接返回。不支持refresh token。安全性不高。
* Authorization Code: 使用front channel和back channel。front channel负责authorization code grant。back channel负责将authorization code换成（exchange）access token以及refresh token。
* Client Credential Flow: 对于server-to-server的场景。通常使用这种模式。在这种模式下要保证client secret不会被泄露。
* Resource Owner Password Flow: 类似于直接用户名，密码的模式，不推荐使用。

  
## 参考文档
[OAuth 2.0 详解](https://zhuanlan.zhihu.com/p/89020647)