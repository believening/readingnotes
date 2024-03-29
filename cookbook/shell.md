# 命令行手册

## git

1. golang go.mod version to commit

   ``` shell
   alias gvmc="git log --pretty='%Cred%ad-%h%Creset -%C(auto)%d%Creset %s %C(bold blue)<%an>%Creset' --date=format:%Y%m%d%H%M%S --abbrev=12"
   ```

2. tag of curret commit

   ``` shell
   git tag --points-at HEAD
   ```

## ssh

1. 使用密钥登录跳板机并跳转目标机器

   ``` shell
   ssh -i /path/to/ssh/private_key -o ProxyJump="root@${jumper_ip}" root@${target_ip}
   # ssh -i /path/to/ssh/private_key -o ProxyCommand="ssh -W %h:%p root@${jumper_ip}" root@${target_ip}
   ```

2. scp 使用密钥经跳板机传递文件到目标机器（及反向操作）

   ``` shell
   scp -i /path/to/ssh/private_key -o ProxyJump="root@${jumper_ip}" -r ${src} root@${target_ip}:${dst}
   scp -i /path/to/ssh/private_key -o ProxyJump="root@${jumper_ip}" -r root@${target_ip}:${src} ${dst}
   ```

3. ssh-agent auto-start

   ``` shell
   SSH_ENV="$HOME/.ssh/agent-environment"

   start_agent() {
      /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
      chmod 600 "${SSH_ENV}"
      . "${SSH_ENV}" > /dev/null
      /usr/bin/ssh-add /path/to/private_key > /dev/null
      # support more private keys
   }

   # Source SSH settings, if applicable
   if [ -f "${SSH_ENV}" ]; then
      . "${SSH_ENV}" > /dev/null
      ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
         start_agent;
      }
   else
      start_agent;
   fi
   ```

## k8s

1. patch status

   ``` shell
   # json patch
   curl --cert cert --key key -k  -XPATCH  -H "Content-Type: application/json-patch+json" -H "Accept: application/json" --data '[{"op": "add", "path": "/status", "value": {"status":{...}}}]' 'https://{apiserver}:6443/apis/{group}/{version}/namespaces/{ns}/{resources}/{name}/status'
   # merge-patch
   curl --cert cert --key key -k  -XPATCH  -H "Content-Type: application/merge-patch+json" -H "Accept: application/json" --data '{"status":{...}}' 'https://{apiserver}:6443/apis/{group}/{version}/namespaces/{ns}/{resources}/{name}/status'
   ```

## yq

1. 多 doc 文本选择替换
   ```
   yq eval 'select(.kind == "Service") |= ((.metadata.labels.deployment = .metadata.labels.app) | del(.metadata.labels.app))' -i $input_file
   ```
2. 借用 style 实现 int 转字符
   ```
   yq eval 'select(.kind == "Deployment") |= ((.metadata.annotations.replicas = .spec.replicas) | (.metadata.annotations.replicas style="double"))' -i $input_file
   ```