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
---
## 1 网络基础 TCP/IP 协议族

### 1.1 TCP/IP 分层管理

* 应用层（ftp、dns、http）  
  决定了提供应用服务时通信的活动

* 传输层（tcp、udp）  
  提供处于网络中的两台计算机之间的数据传输

* 网络层（ip、arp）  
  处理在网络上流动的数据包

* 数据链路层  
  连接网络的硬件部分

### 1.2 IP 协议

用于把数据包传送到指定接收方，基于 ip 地址和 mac 地址寻址定位。  
arp 协议用于 mac 地址和 ip 地址的转换，mac 地址与网卡绑定，基本不变，ip 可变。 IP 包在传输过程中的路由中转由 mac 地址完成。(?)

### 1.3 TCP 协议

目的在于提供可靠的字节流服务。

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

* 请求格式（不严谨）
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
* 响应格式（不严谨）
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

* 请求首行方法之后指定域名或地址/路径  
  ```
  GET http://www.example.com/path/index.htm HTTP/1.1
  ```
* 在首部字段中指定 host 信息  
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

* keep-alive 特性（与tcp长连接），1.1版本默认开启，指定首部信息中 `Connect` 字段为 `close` 来关闭。  
  TCP 位于传输层不会在有数据传输是关闭链接，一般有应用层下达关闭链接的指令。但是，长时间闲置的 TCP 链接有保险机制来避免资源浪费。涉及到三个内核参数：
  
  1. net.ipv4.tcp_keepalive_intvl
  2. net.ipv4.tcp_keepalive_probes
  3. net.ipv4.tcp_keepalive_time  

  闲置 time 时间后，服务器会主动发送侦测包，若没有 ack 包回应，间隔 intvl*i 时间后，再次侦测，如此尝试 probes 次后依然没有回应则断开。其中，i 从 1 开始到 probes 为止。
* 管线化操作，允许并行发送多个请求。

### 2.8 状态保存技术 —— Cookie 
发送请求（无cookie）——> 生成cookie，返回响应（携带cookie）——> 保存cookie，发送请求（携带cookie）

## 3 HTTP 报文内的 HTTP 信息

### 3.1 HTTP报文

报文是传输过程中的8位字节流。由报文首部，空行（CR+LF），报文主体

### 3.2 报文结构

* 报文首部
  * **请求行/状态行**
  * 请求首部/响应首部
  * 通用首部
  * 实体首部
  * 其他
* 空行（CR+LF）
* 报文主体 

### 3.3 提高实体传输效率

1. 压缩  
   针对实体经行压缩（实体首部字段和实体主体）。
2. 分块  
   对实体经行分割，分块传输，客户端可以分块加载。十六进制标记块大小，最后一块使用 `0(CR+LF)` 标记。  
   针对分块传输有 Transfer Coding 机制指定编码方式。
   
### 3.4 按传输实体对象类型多部分传输（响应）

多用于图片文件等等数据上传服务中使用。  
指定 `Content-Type` 字段：
* multipart/form-data;boundary=xxxxxx
* multipart/byteranges;boundary=xxxxxxx

指定 `Content-Range` 字段：
* bytes 100-300/800

在多部分实体主体之间和收尾用 --boundary 来分割；各部分内部依然可以指定各自的实体首部字段。

相应返回状态码 `206 Partial Content` 。

### 3.5 请求获取部分内容（请求）

请求首部指定 `Range` 字段；形如 `Range： bytes=501-1000`、`Range: bytes=-500,1001-` ......  
若服务器无法相应部分请求，则返回 `200 OK` 及全部实体内容。

### 3.6 协商传输内容

用于客户端请求的的定制化，分为:
* 客户端驱动（Agent-Driven Negotiation）
* 服务端驱动（Server-Agent Negotiation）
* 透明驱动（Transparent Negotiation）

主要指定字符集、编码、语言等：
* Accept
* Accept-Encoding
* Accept-Charset
* Accept-Language
* Content-Language
