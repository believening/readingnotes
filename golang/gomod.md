# go mod 相关

## replace

背景：

* 项目依赖某个开源 sdk，并且同时依赖了 sdk 的 v1 和 v2 两个版本，sdk 利用 go mod 在同一个仓库中并行推进两个版本。
* 项目对两个版本的 sdk 均有侵入式修改。

要求：

* 使用私有的 git repo 替换 github mod 地址。
* 同时引入 v1 和 v2 版本的作为依赖。
* 需要指定的 git revision 作为依赖的版本。

操作：

开源 sdk 通过 [go mod 标准的方式已经区分了不同版本的 module](https://go.dev/blog/v2-go-modules)
v1 版本通过 `replace xxx/xxx/xxx v0.0.0-pseudo-version` 引入
v2 版本通过 `replace xxx/xxx/xxx/2 v2.0.0-pseudo-version` 引入

号外：

如果没有通过 go mod 标准方式在 go.mod 文件中区分版本，那么如果仓库使用了[semantic versioning](https://semver.org/) 版本标记，go 会将仓库中 tag 为 vX.Y.Z 的 commit 作为对应版本的。

参考资料：

* [what-does-incompatible-in-go-mod-mean-will-it-cause-harm](https://stackoverflow.com/questions/57355929/what-does-incompatible-in-go-mod-mean-will-it-cause-harm)
* [Modules#can-a-module-consume-a-package-that-has-not-opted-in-to-modules](https://github.com/golang/go/wiki/Modules#can-a-module-consume-a-package-that-has-not-opted-in-to-modules)
