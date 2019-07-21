# 图解 HTTP 笔记
- [图解 HTTP 笔记](#%E5%9B%BE%E8%A7%A3-http-%E7%AC%94%E8%AE%B0)
  - [1 网络基础 TCP/IP 协议族](#1-%E7%BD%91%E7%BB%9C%E5%9F%BA%E7%A1%80-tcpip-%E5%8D%8F%E8%AE%AE%E6%97%8F)
    - [1.1 TCP/IP 分层管理](#11-tcpip-%E5%88%86%E5%B1%82%E7%AE%A1%E7%90%86)
    - [1.2 IP 协议](#12-ip-%E5%8D%8F%E8%AE%AE)
    - [1.3 TCP 协议](#13-tcp-%E5%8D%8F%E8%AE%AE)
    - [1.4 DNS 服务](#14-dns-%E6%9C%8D%E5%8A%A1)
  - [2 简单的 HTTP 协议](#2-%E7%AE%80%E5%8D%95%E7%9A%84-http-%E5%8D%8F%E8%AE%AE)
    - [URI 和 URL](#uri-%E5%92%8C-url)
    - [2.1 HTTP **用于**客户端与服务器之间的通信](#21-http-%E7%94%A8%E4%BA%8E%E5%AE%A2%E6%88%B7%E7%AB%AF%E4%B8%8E%E6%9C%8D%E5%8A%A1%E5%99%A8%E4%B9%8B%E9%97%B4%E7%9A%84%E9%80%9A%E4%BF%A1)
    - [2.2 通过发出请求返回响应完成一次通信](#22-%E9%80%9A%E8%BF%87%E5%8F%91%E5%87%BA%E8%AF%B7%E6%B1%82%E8%BF%94%E5%9B%9E%E5%93%8D%E5%BA%94%E5%AE%8C%E6%88%90%E4%B8%80%E6%AC%A1%E9%80%9A%E4%BF%A1)
    - [2.3 HTTP 是无状态的协议](#23-http-%E6%98%AF%E6%97%A0%E7%8A%B6%E6%80%81%E7%9A%84%E5%8D%8F%E8%AE%AE)
    - [2.4 **请求** URI 的设定](#24-%E8%AF%B7%E6%B1%82-uri-%E7%9A%84%E8%AE%BE%E5%AE%9A)
    - [2.5/2.6 HTTP 定义方法约定请求类型以告知服务器请求意图](#2526-http-%E5%AE%9A%E4%B9%89%E6%96%B9%E6%B3%95%E7%BA%A6%E5%AE%9A%E8%AF%B7%E6%B1%82%E7%B1%BB%E5%9E%8B%E4%BB%A5%E5%91%8A%E7%9F%A5%E6%9C%8D%E5%8A%A1%E5%99%A8%E8%AF%B7%E6%B1%82%E6%84%8F%E5%9B%BE)
    - [2.7 两种技术节省通信量，提高效率](#27-%E4%B8%A4%E7%A7%8D%E6%8A%80%E6%9C%AF%E8%8A%82%E7%9C%81%E9%80%9A%E4%BF%A1%E9%87%8F%E6%8F%90%E9%AB%98%E6%95%88%E7%8E%87)
    - [2.8 状态保存技术 —— Cookie](#28-%E7%8A%B6%E6%80%81%E4%BF%9D%E5%AD%98%E6%8A%80%E6%9C%AF--cookie)
  - [3 HTTP 报文内的 HTTP 信息](#3-http-%E6%8A%A5%E6%96%87%E5%86%85%E7%9A%84-http-%E4%BF%A1%E6%81%AF)
    - [3.1 HTTP报文](#31-http%E6%8A%A5%E6%96%87)
    - [3.2 报文结构](#32-%E6%8A%A5%E6%96%87%E7%BB%93%E6%9E%84)
    - [3.3 提高实体传输效率](#33-%E6%8F%90%E9%AB%98%E5%AE%9E%E4%BD%93%E4%BC%A0%E8%BE%93%E6%95%88%E7%8E%87)
    - [3.4 按传输实体对象类型多部分传输（响应）](#34-%E6%8C%89%E4%BC%A0%E8%BE%93%E5%AE%9E%E4%BD%93%E5%AF%B9%E8%B1%A1%E7%B1%BB%E5%9E%8B%E5%A4%9A%E9%83%A8%E5%88%86%E4%BC%A0%E8%BE%93%E5%93%8D%E5%BA%94)
    - [3.5 请求获取部分内容（请求）](#35-%E8%AF%B7%E6%B1%82%E8%8E%B7%E5%8F%96%E9%83%A8%E5%88%86%E5%86%85%E5%AE%B9%E8%AF%B7%E6%B1%82)
    - [3.6 协商传输内容](#36-%E5%8D%8F%E5%95%86%E4%BC%A0%E8%BE%93%E5%86%85%E5%AE%B9)
  - [4 HTTP状态码](#4-http%E7%8A%B6%E6%80%81%E7%A0%81)
    - [2XX 成功](#2xx-%E6%88%90%E5%8A%9F)
    - [3XX 重定向](#3xx-%E9%87%8D%E5%AE%9A%E5%90%91)
    - [4XX 客户端错误](#4xx-%E5%AE%A2%E6%88%B7%E7%AB%AF%E9%94%99%E8%AF%AF)
    - [5XX 服务端错误](#5xx-%E6%9C%8D%E5%8A%A1%E7%AB%AF%E9%94%99%E8%AF%AF)
  - [5 web 服务器](#5-web-%E6%9C%8D%E5%8A%A1%E5%99%A8)
    - [5.1 单个服务器多域名](#51-%E5%8D%95%E4%B8%AA%E6%9C%8D%E5%8A%A1%E5%99%A8%E5%A4%9A%E5%9F%9F%E5%90%8D)
    - [5.2 转发](#52-%E8%BD%AC%E5%8F%91)
    - [5.3 缓存机制](#53-%E7%BC%93%E5%AD%98%E6%9C%BA%E5%88%B6)
  - [6 HTTP 首部](#6-http-%E9%A6%96%E9%83%A8)
    - [6.1 通用首部字段](#61-%E9%80%9A%E7%94%A8%E9%A6%96%E9%83%A8%E5%AD%97%E6%AE%B5)
    - [6.2 请求首部字段](#62-%E8%AF%B7%E6%B1%82%E9%A6%96%E9%83%A8%E5%AD%97%E6%AE%B5)
---
## 1 网络基础 TCP/IP 协议族

### 1.1 TCP/IP 分层管理

- 应用层（ftp、dns、http）  
  决定了提供应用服务时通信的活动

- 传输层（tcp、udp）  
  提供处于网络中的两台计算机之间的数据传输

- 网络层（ip、arp）  
  处理在网络上流动的数据包

- 数据链路层  
  连接网络的硬件部分

### 1.2 IP 协议

用于把数据包**传送到**指定接收方，基于 ip 地址和 mac 地址寻址定位。  
arp 协议用于 mac 地址和 ip 地址的转换，mac 地址与网卡绑定，基本不变，ip 可变。 IP 包在传输过程中的路由中转由 mac 地址完成。(?)

### 1.3 TCP 协议

目的在于提供**可靠**的字节流服务。

确保通信可靠性的其中一个手段是三次握手:

1. C -> S SYN(synchronize)
2. S -> C ACK(acknowledgement)/SYN
3. C -> S ACK

其他手段：
（待补充）

### 1.4 DNS 服务

domain name system 域名解析系统，负责域名同 ip 地址之间的解析转换。

---
## 2 简单的 HTTP 协议

### URI 和 URL

URI（Uniform resource identifier，统一资源标识符）用于标记互联网资源，URL（Uniform resource locator，统一资源定位符）用于表示互联网资源的地点。

URI 的完整例子：

> http://username:pwd@www.example.com:80/root/dir/idx.html?uid=1#ch1

|项目|内容|
|---:|:---|
|协议名|http:| 
|认证信息|username:pwd|
|服务器地址|www.example.com|
|端口号|80|
|文件路径|/root/dir/dix.html|
|查询字符串|uid=1|
|片段标识符|ch1|

### 2.1 HTTP **用于**客户端与服务器之间的通信

### 2.2 通过发出请求返回响应完成一次通信

- 请求格式（不严谨）
  ```
  POST /from/entry HTTP/1.1
  Host: example.com
  Connection: keep-alive
  Content-Type: application/json

  {"name":"Tom";"age":23}
  
  // 方法 URI 协议版本
  // HEAD 信息
  // (空行CR+LF)
  // 内容实体
  ```
- 响应格式（不严谨）
  ```
  HTTP/1.1 200 OK
  Date: Tue, 8 Feb 2019 12:25:15 UTC+8
  Content-Type: text/html

  <html>
  ...
  </html>
  
  // 协议版本
  // HEAD 信息
  // (空行CR+LF)
  // 内容实体
  ```
### 2.3 HTTP 是无状态的协议

协议对于请求和响应都不会做持久化

### 2.4 **请求** URI 的设定

- 请求首行方法之后指定域名或地址/路径  
  ```
  GET http://www.example.com/path/index.htm HTTP/1.1
  ```
- 在首部字段中指定 host 信息  
  ```
  GET /path/index.htm HTTP/1.1
  Host: www.example.com
  ```
 
### 2.5/2.6 HTTP 定义方法约定请求类型以告知服务器请求意图
|method|intention|remark|
|:---:|:---|---|
|GET|获取资源||
|POST|传输实体主体||
|PUT|传输文件||
|HEAD|取得响应报文首部信息|可以用于确认 URI 的有效性和更新时间|
|DELETE|删除文件||
|OPTIONS|询问支持方法||
|TRACE|追踪路径|Max-Forwords 的设置|
|CONNECT|要求用隧道协议连接代理|SSL(Secure Socket Layer)和TLS(Transport Layer Security)|

### 2.7 两种技术节省通信量，提高效率

- keep-alive 特性（与tcp长连接），1.1版本默认开启，指定首部信息中 `Connect` 字段为 `close` 来关闭。  
  TCP 位于传输层不会在有数据传输时关闭链接，一般有应用层下达关闭链接的指令。但是，长时间闲置的 TCP 链接有保险机制来避免资源浪费。涉及到三个内核参数：
  
  1. net.ipv4.tcp_keepalive_intvl
  2. net.ipv4.tcp_keepalive_probes
  3. net.ipv4.tcp_keepalive_time  

  闲置 time 时间后，服务器会主动发送侦测包，若没有 ack 包回应，间隔 intvl*i 时间后，再次侦测，如此尝试 probes 次后依然没有回应则断开。其中，i 从 1 开始到 probes 为止。  
  链接的概念应该建立在传输层，也就是说 TCP 协议。
  
- 管线化操作，允许并行发送多个请求。

### 2.8 状态保存技术 —— Cookie 
发送请求（无cookie）——> 生成cookie，返回响应（携带cookie）——> 保存cookie，发送请求（携带cookie）

---
## 3 HTTP 报文内的 HTTP 信息

### 3.1 HTTP报文

报文是传输过程中的8位字节流。由报文首部，空行（CR+LF），报文主体

### 3.2 报文结构

- 报文首部
  - **请求行/状态行**
  - 请求首部/响应首部
  - 通用首部
  - 实体首部
  - 其他
- 空行（CR+LF）
- 报文主体 

### 3.3 提高实体传输效率

1. 压缩  
   针对实体经行压缩（实体首部字段和实体主体）。
2. 分块  
   对实体经行分割，分块传输，客户端可以分块加载。十六进制标记块大小，最后一块使用 `0(CR+LF)` 标记。  
   针对分块传输有 Transfer Coding 机制指定编码方式。
   
### 3.4 按传输实体对象类型多部分传输（响应）

多用于图片文件等等数据上传服务中使用。  
指定 `Content-Type` 字段：
- multipart/form-data;boundary=xxxxxx
- multipart/byteranges;boundary=xxxxxxx

指定 `Content-Range` 字段：
- bytes 100-300/800

在多部分实体主体之间和收尾用 --boundary 来分割；各部分内部依然可以指定各自的实体首部字段。

相应返回状态码 `206 Partial Content` 。

### 3.5 请求获取部分内容（请求）

请求首部指定 `Range` 字段；形如 `Range： bytes=501-1000`、`Range: bytes=-500,1001-` ......  
若服务器无法相应部分请求，则返回 `200 OK` 及全部实体内容。

### 3.6 协商传输内容

用于客户端请求的的定制化，分为:
- 客户端驱动（Agent-Driven Negotiation）
- 服务端驱动（Server-Agent Negotiation）
- 透明驱动（Transparent Negotiation）

主要指定字符集、编码、语言等：
- Accept
- Accept-Encoding
- Accept-Charset
- Accept-Language
- Content-Language

---
## 4 HTTP状态码

描述返回结果，RFC2616、4918、5842、6585

常用状态码

### 2XX 成功

- 200 OK  
  表示服务端成功处理了请求
- 204 No Content  
   服务端处理成功，不需要发送实体内容时返回
- 206 Partial Content  
   成功处理，部分内容返回，用于部分请求或者分割返回的场景

### 3XX 重定向

客户端需要在执行某些操作

- 300 Moved Permanently  
  永久重定向，响应首部字段 `Location` 标明新的 URI
- 301 Found  
  临时重定向，该次请求使用新的 URI，不保证下次同样请求 URI 相同
- 303 See Other  
  临时重定向，使用 GET 方法再次请求新的 URI 以完成访问
- 304 Not Modified  
  不匹配，当请求首部中有 `If-Match`、`If-Modified-Since`、`If-None-Match`、`If-Range`、`If-Unmodified-Since` 字段时，服务器处理后不满足则返回该状态码
- 307 Temporary Redirect  
  临时重定向，禁止新请求中将 POST 方法改为 GET 方法

### 4XX 客户端错误

- 400 Bad Request  
  无法理解的请求，需要修改请求内容
- 401 Unauthorized  
  客户端未认证，首次请求时返回响应会要求客户端添加认证信息，随后请求中出现意味着认证失败
- 403 Forbidden  
  禁止访问。可能由于客户端权限限制，禁止的IP源等等
- 404 Not Found
  未找到请求的资源或者服务器不愿给出拒绝的原因时候返回

### 5XX 服务端错误

- 500 Internal Server Error  
  服务端程序内部错误
- 503 Service Unavailable
  服务器正在维护或者超负载无法处理请求，响应首部可添加 `Retry-After` 提醒重试

---
## 5 web 服务器

### 5.1 单个服务器多域名

单个物理服务器通过部署多个虚拟机环境可以提供多个 web 服务，DNS 解析到相同 ip 后，服务器内部可以根据主机名定向到不同的 web 服务。这个实现的前提是 HTTP 请求首部 Host 字段指定出完成的主机名或者域名的 URI。

### 5.2 转发

1. 代理  
   代理服务器接收到请求后会转发给源服务器或者下一接续代理服务器，**转发时**请求首部会增加 `Via` 字段标识代理路径(主机信息)。
2. 网关  
   网关响应 HTTP 请求对于客户端来说是不感知网关之后的事情，这使得原服务器和网关之间的通信协议更加自由  
   网关还可以增加安全性（？） 
3. 隧道  
   隧道的建立使得请求可以加密发送到远端服务器

### 5.3 缓存机制 

- 代理服务器的缓存
- 客户端缓存

均需要注意缓存期限，怀疑超过期限则要向原服务器确认。

---
## 6 HTTP 首部

### 6.1 通用首部字段

|字段名|说明|补充|
|---|:---|:---|
|Cache-Control|缓存机制控制|public 和 private 指令在响应中使用，指明使用缓存的许可对象；<br> no-cache 请求中指明则不使用过期缓存，响应中指明则缓存服务器不进行缓存；<br> no-store 暗示有保密信息，不要经行缓存；<br> max-age 单位秒，表示缓存的有效期，s-maxage 同 max-age 适用于多用户使用缓存服务器情况下，覆盖 max-age 指令；<br> min-fresh 请求中指明表示时间段内缓存会过期的话，请求新资源，max-stale 指明请求时间段内缓存资源，即使过期，must-revalidate 强制验证有效性 ；<br> only-if-cached 明确请求缓存服务器的资源；<br>  no-transform 不能改变实体主体的媒体类型
|Connection|控制不再转发的首部字段<br>管理持久链接|Connection后指令为首都字段名时，在转发请求时会删除对应首部字段<br>close 和 Keep-alive 表明是否建立持久连接|
|Date|报文生成的时间|HTTP/1.1 版本格式 <br>`Tue, 15 Feb 2019 14:59:00 UTC+8`|
|Trailer|**实体**主体之后记录的哪些首部字段||
|Transfer-Encoding|**报文**主体的编码方式|HTTP/1.1 仅仅对 chunked 有效|
|Upgrade|检测是否可用其他版本协议|`Upgrade: HTTP/1.1, TLS/1.0`|
|Via|追踪传输路径|代理服务器会将自己的服务器信息（HTTP版本 域名）填入|
|Warning|携带与缓存有关的告警信息||

### 6.2 请求首部字段

