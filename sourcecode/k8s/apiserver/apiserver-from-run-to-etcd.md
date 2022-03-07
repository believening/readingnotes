apiserver form run to etcd

[s := options.NewServerRunOptions()](https://github.com/kubernetes/kubernetes/blob/4a3b558c52eb6995b3c5c1db5e54111bd0645a64/cmd/kube-apiserver/app/server.go#L106) // 默认的 apiserver 配置 `ServerRunOptions`, 其中包括 etcd 配置 `*genericoptions.EtcdOptions`

[s.Etcd.AddFlags(fss.FlagSet("etcd"))](https://github.com/kubernetes/kubernetes/blob/4a3b558c52eb6995b3c5c1db5e54111bd0645a64/cmd/kube-apiserver/app/options/options.go#L170) // 解析 etcd 参数到 `*genericoptions.EtcdOptions`

[completedOptions, err := Complete(s)](https://github.com/kubernetes/kubernetes/blob/4a3b558c52eb6995b3c5c1db5e54111bd0645a64/cmd/kube-apiserver/app/server.go#L132) // 包装类再次初始化 apiserver 配置，[涉及 etcd 相关的主要为 watchcache](https://github.com/kubernetes/kubernetes/blob/4a3b558c52eb6995b3c5c1db5e54111bd0645a64/cmd/kube-apiserver/app/server.go#L679)

[errs := completedOptions.Validate()](https://github.com/kubernetes/kubernetes/blob/4a3b558c52eb6995b3c5c1db5e54111bd0645a64/cmd/kube-apiserver/app/server.go#L138) // 合法性校验，[etcd 相关主要是 server 地址和 override 资源 server 地址，以及 backend 类型](https://github.com/kubernetes/kubernetes/blob/4a3b558c52eb6995b3c5c1db5e54111bd0645a64/cmd/kube-apiserver/app/options/validation.go#L168)

[server, err := CreateServerChain(completeOptions, stopCh)](https://github.com/kubernetes/kubernetes/blob/4a3b558c52eb6995b3c5c1db5e54111bd0645a64/cmd/kube-apiserver/app/server.go#L183) // 实例化server对象，做了很多事情，此处不展开和 etcd 不相关的事情

 -  [kubeAPIServerConfig, serviceResolver, pluginInitializer, err := CreateKubeAPIServerConfig(completedOptions, nodeTunneler, proxyTransport)](https://github.com/kubernetes/kubernetes/blob/4a3b558c52eb6995b3c5c1db5e54111bd0645a64/cmd/kube-apiserver/app/server.go#L203) // kubeAPIServer（不同于apiserver） 配置的初始化，
    -  [genericConfig, versionedInformers, serviceResolver, pluginInitializers, admissionPostStartHook, storageFactory, err := buildGenericConfig(s.ServerRunOptions, proxyTransport)](https://github.com/kubernetes/kubernetes/blob/4a3b558c52eb6995b3c5c1db5e54111bd0645a64/cmd/kube-apiserver/app/server.go#L306) // 其中的 `genericConfig` 包含了 `RESTOptionsGetter` 和 etcd 后端有关系。storageFactory 也和etcd相关，是根据 etcd 配置生成的。

结合 client-go 的代码一起理解，参考[博客](https://bbs.huaweicloud.com/community/usersnew/id_1572321197421283/page_1)

list-watch：
   server： 所有实例都可以 watch form revision
   client：list from server，server 返回的是所有的变动的事件，同样可以指定到 revision
