#!/bin/bash
###
 # @Author: Takashi
 # @Date: 2024-01-12 16:18:42
 # @LastEditors: Takashi
 # @LastEditTime: 2024-01-12 16:25:25
 # @Description: file content
### 
#!/bin/bash

# 脚本用法
usage() {
  echo "Usage: $0 -f FILE -n N"
  echo "  -f FILE: 包含命令的文件"
  echo "  -n N   : 最大并行数"
  exit 1
}

# 处理命令行选项
while getopts ":f:n:" opt; do
  case ${opt} in
    f) file="${OPTARG}" ;;
    n) max_parallel="${OPTARG}" ;;
    *) usage ;;
  esac
done

# 检查参数是否存在
if [ -z "${file}" ] || [ -z "${max_parallel}" ]; then
  usage
fi

# 检查文件是否存在
if [ ! -f "${file}" ]; then
  echo "Error: 文件 '${file}' 不存在."
  exit 2
fi

# 读取命令行，将其放入后台执行
exec 3<"$file" # 打开文件用于读取，并分配文件描述符3
rm "$file" # 删除源文件
touch "$file" # 创建一个新的空文件，用于保持未执行的命令（如果出现错误）
while read -r -u 3 cmd; do
  # 限制后台进程的数目
  while [ $(jobs -p | wc -l) -ge "$max_parallel" ]; do
    sleep 0.1 # 等待直到并行作业数减少
  done
  cmd=$(echo "$cmd" | sed -e 's/^[ \t\r\n]*//;s/[ \t\r\n]*$//') # 去除命令前后的空格
  # 执行命令，并在后台
  bash -c "$cmd" &
done
exec 3<&- # 关闭文件描述符3

# 等待所有后台进程完成
wait

echo "所有命令执行完成。"