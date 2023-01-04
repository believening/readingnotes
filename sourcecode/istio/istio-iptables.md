# istio iptables

## 传统 isito forward 模式

在常规的 forward 模式下，istio 通过修改 nat 表来影响链接的建立。

入方向修改 `PREROUTING` 链，将流量转到 envoy

出方向修改 `OUTPUT` 链，将流量转到 envoy

这里需要注意的是 NAT 表的特性：

> This table is consulted when a packet that creates a new connection is encountered. It consists of three built-ins: PREROUTING (for altering packets as soon as they come in), OUTPUT (for altering locally-generated packets before routing), and POSTROUTING (for altering packets as they are about to go out).
> nat 表在链接建立的时候被使用，也就是第一个 4 层协议包，后续基于该链接的所有包都会直接应用 nat 的结果。nat 表上规则不会影响到已经存在的网络链接的行为。
> 更多的，对于 filter 表来说，通常会使用 `-m conntrack --ctstate RELATED,ESTABLISHED` 来排除对已存在链接的影响。
