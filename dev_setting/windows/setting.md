# 设置 windows 开发环境

## 1. wsl

### 1.1 安装配置

* [参照 MS 指导安装 wsl2](https://docs.microsoft.com/en-us/windows/wsl/install), 默认安装 ubuntu

  ``` powershell
  wsl --install
  # 执行完之后需要重启生效
  ```

* 设置 wsl 默认 root 用户登录 `ubuntu config --default-user root`
* [wsl 配置 PATH 不包含 windows PATH](https://devblogs.microsoft.com/commandline/automatically-configuring-wsl/#section-interop)
  
  ``` sh
  # 在 wsl 中
  $ cat > /etc/wsl.conf << EOF
  [interop]
  appendWindowsPath = false
  EOF
  # 需要在 windows 中重启 wsl 使得配置生效
  # 执行 wsl --shutdown 即可
  ```

### 1.2 zsh 以及 oh-my-zsh

* 安装 zsh

  ``` sh
  $ apt-get install zsh
  ```

* 安装 oh-my-zsh

  ``` sh
  $ sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ```

## 2. git 和 git-bash

### 2.1 安装

[官网](https://git-scm.com/)下载安装

### 2.2 配置（略）

### 2.3 git bash

#### 2.3.1 zsh
  
* [下载zsh](https://packages.msys2.org/package/zsh?repo=msys&variant=x86_64)
* zstd 压缩格式，利用 wsl 解压（或者参考[zstd官网](http://facebook.github.io/zstd/)）

  ```shell
  # 将压缩包放置到合适目录，以下命令均以压缩包所在目录为工作目录(windows 目录挂载在 /mnt 目录下)
  # 安装 zstd
  $ apt-get install zstd
  # 解压文件
  $ tar -I zstd -xvf zsh-5.8-5-x86_64.pkg.tar.zst
  ```

* 将前述步骤解压好的文件复制拷贝到 git 安装的根目录
* 使能 zsh 作为默认 shell, 将如下内容添加到 git bash 启动配置文件中

  ``` bash
  # Launch Zsh
  if [ -t 1 ]; then
    exec zsh
  fi
  ```

* 安装 [oh-my-zsh](https://ohmyz.sh/)

  ``` shell
  $ sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ```

上述所有步骤均可参考: https://gist.github.com/fworks/af4c896c9de47d827d4caa6fd7154b6b

## 3. 终端 windows terminal 或者 tabby

鉴于 windows terminal 可能需要登录 windows store，可以使用 [tabby](https://tabby.sh/) 替换

## 4. 技术栈工具链安装

### 4.1 vscode

### 4.2 golang

### 4.3 rust

### 4.4 linux 常用小组件

* [gocloc](https://github.com/hhatto/gocloc) `go install github.com/hhatto/gocloc/cmd/gocloc@latest`
* @Deprecated [ag: the_sileer_searcher](https://github.com/ggreer/the_silver_searcher)
* rg [rg:ripgrep](https://github.com/BurntSushi/ripgrep)
* [graph-easy ascii 画图](https://github.com/ironcamel/Graph-Easy)
* [json terminal tool: fx](https://github.com/antonmedv/fx)
