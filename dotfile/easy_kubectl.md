使用 shell function k 作为 kubectl 的别名提高运维效率

1. 需要 kubectx，kubens，fzf 二进制

   - fzf 下载请参考[官网](https://github.com/junegunn/fzf)
   - [kubectx，kubens](https://github.com/ahmetb/kubectx) 可以使用 go install 下载

      ``` shell
      go install github.com/ahmetb/kubectx/cmd/kubectx@v0.9.4
      go install github.com/ahmetb/kubectx/cmd/kubens@v0.9.4
      ```

2. source 如下 profile 文件

   ```profile
   # 每个 shell session 独占一份 kubeconfig 副本，避免 kubectx/kubens 改动 ~/.kube/config 影响其它会话。
   # 子 shell 通过 EASY_K_SESSION_CONFIG 继承父 shell 的隔离副本；新顶层 shell 各自生成新副本。
   if [[ -z "${EASY_K_SESSION_CONFIG}" ]]; then
     _easy_k_src="${KUBECONFIG:-$HOME/.kube/config}"
     if [[ -r "${_easy_k_src}" ]]; then
       EASY_K_SESSION_CONFIG="$(mktemp -t kubeconfig.XXXXXX)"
       cp "${_easy_k_src}" "${EASY_K_SESSION_CONFIG}"
       export KUBECONFIG="${EASY_K_SESSION_CONFIG}"
       export EASY_K_SESSION_CONFIG
       trap 'rm -f "${EASY_K_SESSION_CONFIG}"' EXIT
     fi
     unset _easy_k_src
   fi
   
   if [[ -n "${BASH_VERSION}" ]]; then
     if ! type __start_kubectl 1>/dev/null 2>&1; then
       source <(kubectl completion bash)
     fi
     if kubectl completion bash | grep "bash completion V2 for kubectl" 1>/dev/null 2>&1; then
       # 对于 shell function k 来说，需要直接使用 kubectl 获取补全的结果
       source <(kubectl completion bash | gsed '/\s\b__start_kubectl\b\s/s/\bkubectl\b/k/g' | gsed 's/_kubectl/_k_kubectl/g' | gsed '/requestComp=/s/${words\[0\]}/kubectl/g')
     else
       complete -o nospace -F __start_kubectl k
     fi
   elif [[ -n "${ZSH_VERSION}" ]]; then
     if ! type _kubectl 1>/dev/null 2>&1; then
       source <(kubectl completion zsh)
     fi
     source <(kubectl completion zsh | gsed '/\s\b_kubectl\b\s/s/\bkubectl\b/k/g' | gsed 's/_kubectl/_k_kubectl/g' | gsed '/requestComp=/s/${words\[1\]}/kubectl/g' )
   fi
   
   k() {
     if [[ $1 = c ]]; then
       shift
       kubectx $@
     elif [[ $# -eq 0 ]]; then
       kubens
     else
       kubectl $@
     fi
   }
   
   ```

3. 可通过镜像安装集成包
   
   ``` shell
   mkdir -p ${HOME}/easy_kube && docker run --rm -v ${HOME}/easy_kube:/host/easy_kube believening/easy_kube:v0.1.6 cp easy_kube.tar.gz /host/easy_kube/
   pushd $HOME/easy_kube
   sudo chown $UID:$GID easy_kube.tar.gz
   tar -zxf easy_kube.tar.gz
   source init.sh
   popd
   rm -rf $HOME/easy_kube
   ```

4. dockerfile

    ``` Dockerfile
    FROM golang:alpine AS dependency

    ENV CGO_ENABLED=0
    ENV LDFLAGS='-extldflags -static -s -w'
    RUN go install -ldflags "${LDFLAGS}" github.com/ahmetb/kubectx/cmd/kubens@v0.9.4 && \
        go install -ldflags "${LDFLAGS}" github.com/ahmetb/kubectx/cmd/kubectx@v0.9.4 && \
        go install -ldflags "${LDFLAGS}" github.com/junegunn/fzf@0.34.0

    FROM alpine AS tar

    RUN apk add --no-cache tar
    COPY --from=dependency /go/bin /easy_kube/bin
    ADD easy_k /easy_kube/easy_k
    ADD init.sh /easy_kube/init.sh
    RUN tar -zcf /easy_kube.tar.gz --owner=0 --group=0 -C /easy_kube .

    FROM bash

    COPY --from=tar /easy_kube.tar.gz /easy_kube.tar.gz
    ```

5. init.sh
   
   ``` shell
   #!/bin/bash
   
   if [ ! -d $HOME/bin ]; then
     mkdir $HOME/bin
   fi

   for binary in kubectx kubens fzf; do
     if ! which ${binary} >/dev/null 2>&1; then
       cp ./bin/${binary} $HOME/bin/
     fi
   done

   if [[ -n "${BASH_VERSION}" ]]; then
     sed -i '/source $HOME\/\.easy_k\.profile/d' $HOME/.bash_profile $HOME/.profile >/dev/null 2>&1
     cp ./easy_k $HOME/.easy_k.profile
     if [ -e $HOME/.bash_profile ]; then
       echo 'source $HOME/.easy_k.profile' >> $HOME/.bash_profile
     else
       echo 'source $HOME/.easy_k.profile' >> $HOME/.profile
     fi
   elif [[ -n "${ZSH_VERSION}" ]]; then
     sed -i '/source $HOME\/\.easy_k\.profile/d' $HOME/.zshrc $HOME/.profile >/dev/null 2>&1
     echo 'source $HOME/.easy_k.profile' >> $HOME/.zshrc
   fi

   source $HOME/.easy_k.profile
   ```


6. mac os
   
  - 可以直接使用 brew 安装 kubectl, kubectx, kubens, fzf 等。
  - profile 中的 sed 可能需要换成 gsed。
