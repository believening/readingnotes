#!/bin/bash

# 使用 gpt-3.5-turbo 和 gpt-4 生成

# 定义递归查找子进程的函数
function find_children() {
  local parent_pid=$1
  echo -n "${parent_pid}|"
  local child_pids=$(ps -o pid= --ppid $parent_pid)

  for child_pid in $child_pids; do
    find_children $child_pid
  done
}

# 检查参数是否正确
if [ $# -eq 0 ]; then
  echo "Usage: $0 <pid>"
  exit 1
fi

# 获取指定进程及其递归子进程的 pid 列表
pid_list=$(find_children $1)
pid_list=${pid_list%|}
echo "监控进程列表：$pid_list"

# 将进程号列表转换为数组
pid_array=(${pid_list//|/ })

# 遍历进程号数组，并使用 strace 命令监控进程接收的信号
for pid in "${pid_array[@]}"
do
  # 使用 strace 命令监控进程接收的信号，将输出重定向到文件
  strace -t -p "$pid" -s 9999 -e 'trace=signal' -o "strace_$pid.log" &
done

echo "监控已启动，请查看 strace_PID.log 文件查看进程信号接收情况。"
