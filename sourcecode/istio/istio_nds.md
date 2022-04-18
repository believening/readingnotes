# istio Name Discovery Service 分析

>// Nds stands for Name Discovery Service. Istio agents send NDS requests to istiod
>// istiod responds with a list of service entries and their associated IPs (including k8s services)
>// The agent then updates its internal DNS based on this data. If DNS capture is enabled in the pod
>// the agent will capture all DNS requests and attempt to resolve locally before forwarding to upstream
>// dns servers/
>
>`https://github.com/istio/istio/blob/5fc3738721840631e753c06077488c526f9b1a09/pilot/pkg/xds/nds.go#L26-L30`

正如 istio 注释所说的一样，当开启 `DNS capture` 时，istio-agent 进程会充当一个 localdns 服务，劫持 DNS 请求，并尝试从本地的缓存中解析域名，如果失败的再请求上游的 DNS 服务。
istio-agent 进程本地的域名表是通过向 istiod 发起 NDS 请求拿到的，其中包括了所有与请求的 agent 相关(参考 Sidecar 资源)的 ServiceEntries 及这些 ServiceEntry 背后的 IP 地址（还会包括 k8s service）。

## istiod 在 server 侧的处理

### nds 的推送条件

* full push
* 存在发生变更的配置不在 `[黑名单](https://github.com/istio/istio/blob/5fc3738721840631e753c06077488c526f9b1a09/pilot/pkg/xds/nds.go#L37-L49)` 中
* 请求的代理是作为 sidecar 存在的（见下文）

### 构建 name table

1. 判断 agent 的代理类型是否是 sidecar
2. 遍历 agent 可见的所有 istio service,该 service 属于 istio 内置的一个数据模型（从 ServiceEntry 和 k8s service 转换而来）
3. 对每一个 istio service 尝试获获取和 agent 同集群内第一个可用的 address，如果没有的话则会尝试返回 istio 自动生成的一个 vip (需要开启 DNSAutoAllocate) 或者返回 `0.0.0.0`
4. 第 3 步拿到的 address 如果是 `0.0.0.0` 的话:
   1. passthrough 类型的 service，并且存在可用的端口，则会用第一个可用的端口来查所有的 endpoint
   2. 遍历所有的 ep， 直接将 ep 的地址添加到 serivce 的可用地址列表中，并最终构建出该 service 的 DNS 记录
   3. 此外若遍历到 ep 拥有子域名并且和 agent 处于同一个网络内，则会将 ep 的 hostname、subdomain 和 clusterdomain 拼接出一条 DNS 记录保存到 name table 中。若在已有的 name table 中已经出现了该记录对应的域名记录，记录会优先被和 agent 同集群 ep 生成的记录给覆盖掉

> `https://github.com/istio/istio/blob/6ec2a64c0b89f323cfaeb655b3a69ea196faf023/pkg/dns/server/name_table.go#L40`

## istio-agent 处理 dns 请求

首先 istio-agent 根据 server 推送的 nds 响应，构建本地的 dns server cache，同时也会读取 `resolv.conf` 文件的 dns 配置获取 searchNamespaces 和上游的 dns server，之后在 localhost 的 15053 端口监听 DNS 流量。istio-agent 用了 `github.com/miekg/dns` 库提供的 dns server 和 client 实现。

### 流量路径分析

配置 dns 拦截之后，会创建相关的 iptables 规则将 dns 请求重定向 pilot-agent 暴露的 15053 端口，从而触发后续的 localdns 服务。

环境中 iptables 规则示例：

```/etc/resolv.conf
nameserver 10.96.0.10
search {ns}.svc.cluster.local svc.cluster.local cluster.local
options ndots:4
```

``` iptables-save
  1 *nat
  2 :PREROUTING ACCEPT [12147:705609]
  3 :INPUT ACCEPT [12147:705609]
  4 :OUTPUT ACCEPT [561:56251]
  5 :POSTROUTING ACCEPT [609:60067]
  6 :ISTIO_INBOUND - [0:0]
  7 :ISTIO_IN_REDIRECT - [0:0]
  8 :ISTIO_OUTPUT - [0:0]
  9 :ISTIO_REDIRECT - [0:0]
 10 -A PREROUTING -p tcp -j ISTIO_INBOUND
 11 -A OUTPUT -p tcp -j ISTIO_OUTPUT
 12 -A OUTPUT -p udp -m udp --dport 53 -m owner --uid-owner 1337 -j RETURN
 13 -A OUTPUT -p udp -m udp --dport 53 -m owner --gid-owner 1337 -j RETURN
 14 -A OUTPUT -d 10.96.0.10/32 -p udp -m udp --dport 53 -j REDIRECT --to-ports 15053
 15 -A ISTIO_INBOUND -p tcp -m tcp --dport 15008 -j RETURN
 16 -A ISTIO_INBOUND -p tcp -m tcp --dport 8973 -j ISTIO_IN_REDIRECT
 17 -A ISTIO_IN_REDIRECT -p tcp -j REDIRECT --to-ports 15006
 18 -A ISTIO_OUTPUT -s 127.0.0.6/32 -o lo -j RETURN
 19 -A ISTIO_OUTPUT ! -d 127.0.0.1/32 -o lo -p tcp -m tcp ! --dport 53 -m owner --uid-owner 1337 -j ISTIO_IN_REDIRECT
 20 -A ISTIO_OUTPUT -o lo -p tcp -m tcp ! --dport 53 -m owner ! --uid-owner 1337 -j RETURN
 21 -A ISTIO_OUTPUT -m owner --uid-owner 1337 -j RETURN
 22 -A ISTIO_OUTPUT ! -d 127.0.0.1/32 -o lo -m owner --gid-owner 1337 -j ISTIO_IN_REDIRECT
 23 -A ISTIO_OUTPUT -o lo -p tcp -m tcp ! --dport 53 -m owner ! --gid-owner 1337 -j RETURN
 24 -A ISTIO_OUTPUT -m owner --gid-owner 1337 -j RETURN
 25 -A ISTIO_OUTPUT -d 10.96.0.10/32 -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 15053
 26 -A ISTIO_OUTPUT -d 127.0.0.1/32 -j RETURN
 27 -A ISTIO_OUTPUT -j ISTIO_REDIRECT
 28 -A ISTIO_REDIRECT -p tcp -j REDIRECT --to-ports 15001
 29
 30 *raw
 31 :PREROUTING ACCEPT [156494:65047526]
 32 :OUTPUT ACCEPT [146339:48107437]
 33 -A PREROUTING -d 10.96.0.10/32 -p udp -m udp --sport 53 -j CT --zone 1
 34 -A OUTPUT -p udp -m udp --dport 53 -m owner --uid-owner 1337 -j CT --zone 1
 35 -A OUTPUT -p udp -m udp --sport 15053 -m owner --uid-owner 1337 -j CT --zone 2
 36 -A OUTPUT -p udp -m udp --dport 53 -m owner --gid-owner 1337 -j CT --zone 1
 37 -A OUTPUT -p udp -m udp --sport 15053 -m owner --gid-owner 1337 -j CT --zone 2
 38 -A OUTPUT -d 10.96.0.10/32 -p udp -m udp --dport 53 -j CT --zone 2
```

> 对于 dns 协议来说，存在主从的 dns server，从 dns server 使用 TCP 协议和主 dns server 通信同步 dns 数据，属于 dns 区域传输。其他情况下则使用效率更高的 udp 协议进行通信，比如域名解析的请求。

0 业务进程使用 udp 是对外请求解析域名的流量被重定向到 pilot-agent 进程：

  1. OUTPUT 链
     1. raw 表匹配到 L38 的规则，启用 connection tracking，并设置 ct zone 为 2；
     2. 无 connection track 表；
     3. 无 mangle 表；
     4. nat 表匹配到 L14 的规则，dNat 重定向到本机地址的 15053 端口；
  2. POSTROUTING 链
     1. 无 mangle 表；
     2. 无 fileter 表；

1 pilot-agent 收到业务进程的 dns 请求：

  1. PREROUTING 链
     1. raw 表没有匹配到的规则（业务容器端口基本不可能是 53）；
     2. 无 connection track 表；
     3. 无 mangle 表；
     4. nat 表没有匹配到规则；
  2. INPUT 链
     1. 无 mangle 表；
     2. 无 filter 表；

1.1.1 pilot-agent 未在本地缓存解析出域名，请求上游 dns 服务器解析域名：

  1. OUTPUT 链
    1. raw 表匹配 L34 和 L36 的规则，启用 connection tracking，并设置 ct zone 为 1；同时匹配 L38 的规则，启用 connection tracking，并设置 ct zone 为 2；
    2. 无 connection track 表；
    3. 无 mangle 表；
    4. nat 表匹配到 L12 或 L13 的规则，执行 OUTPUT 链的默认行为 ACCEPT（见 L4）；
  2. POSTROUTING 链
    1. 无 mangle 表；
    2. 无 fileter 表；

1.1.2 pilot-agent 接收上游 dns 响应 ：

  1. PREROUTING 链
    1. raw 表没有匹配到的规则（目的 ip 是本机 ip）
    2. 无 connection track 表；
    3. 无 mangle 表；
    4. nat 表没有匹配到规则；
  2. INPUT 链
    1. 无 mangle 表；
    2. 无 filter 表；

1.2.1 pilot-agent 使用本地缓存解析出域名

2 pilot-agent 拿到解析出域名后响应给业务进程：

  1. OUTPUT 链
     1. raw 表匹配 L35 和 L37 的规则，启用 connection tracking，并设置 ct zone 为 2；
     2. 无 connection track 表；
     3. 无 mangle 表；
     4. nat 表没有匹配到规则；
  2. POSTROUTING 链
     1. 无 mangle 表；
     2. 无 fileter 表；

3 业务容器收到域名响应：

  1. PREROUTING 链
     1. raw 表没有匹配到的规则
     2. 无 connection track 表；
     3. 无 mangle 表；
     4. nat 表没有匹配到规则；
  2. INPUT 链
     1. 无 mangle 表；
     2. 无 filter 表；
