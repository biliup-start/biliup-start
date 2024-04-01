#!/bin/bash

# 定义目录
BILIUP_DIR=/opt/biliup
OUTPUT_BASE=/opt/blrec/rec/22965398-LPL第一视角1

# 获取国家代码
country_code=$(curl -s https://ipinfo.io/country)

# 检查国家代码是否为 CN
if [ "$country_code" = "CN" ]; then
    url=qn
else
    url=ws
fi

# 创建一个空数组来存储文件路径
files=()

# 查找所有符合条件的文件，并将它们的路径添加到数组中
IFS=$'\n'
for file in $(find "$OUTPUT_BASE" -type f -name "*.flv" -mtime 0)
do
  files+=("$file")
done

# 检查是否找到了文件
if [ ${#files[@]} -eq 0 ]; then
  echo "没有找到文件"
  exit 1
fi

# 用数组中的所有文件路径一次调用上传命令
echo "上传 ${#files[@]} 个文件"
${BILIUP_DIR}/biliupR upload "${files[@]}" --tag biliup --line ${url} --limit 999
