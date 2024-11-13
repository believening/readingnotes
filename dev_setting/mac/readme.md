1. set brew mirror (if needed)

   ```
   # 使用阿里云的镜像源
   #export HOMEBREW_API_DOMAIN="https://mirrors.aliyun.com/homebrew-bottles/api"
   #export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.aliyun.com/homebrew/brew.git"
   #export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.aliyun.com/homebrew/homebrew-core.git"
   #export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.aliyun.com/homebrew/homebrew-bottles"
   # 使用 ustc 镜像
   export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
   export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
   export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
   export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"
   ```

2. switch go version
   ```
   #brew unlink go@xxx
   #brew link go@xxx
   ```
   使用 golang 官方安装，使用 sgo 切换


