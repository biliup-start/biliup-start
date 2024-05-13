#!/bin/bash

BILIUP_DIR=/opt/biliup
ALLOWED_TYPES="mp4 flv avi wmv mov webm mpeg4 ts mpg rm rmvb mkv"

country_code=$(curl -s https://ipinfo.io/country)

if ! find / -wholename "${BILIUP_DIR}/biliupR" -print -quit | grep -q .; then
    cd ${BILIUP_DIR} 
    if [ "$country_code" = "CN" ]; then
        url="https://j.iokun.top/https://"
    else
        url="https://"
    fi
    # 获取最新版本的链接
    latest_url=$(curl -Ls -o /dev/null -w %{url_effective} ${url}github.com/biliup/biliup-rs/releases/latest/download/)

    # 从链接中提取版本号
    biliuprs_version=$(echo $latest_url | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+')

    echo "你的CPU架构是："
    echo -e "    （\e[31m默认\033[0m）0: \e[33mx86_64\033[0m"
    echo -e "            1: \033[0;32mARMa64\033[0m"
    echo -e "            2: \033[0;32m ARM\033[0m"
    read -p "请输入[0/1/2]：" arch_choice
    if [[ -z "$arch_choice" || ! "$arch_choice" =~ [0-2] ]]; then
        echo -e "你输入错误，使用默认 \e[33mx86_64\033[0m CPU架构："
        arch_choice=0
    fi
    if [ "$arch_choice" -eq 2 ]; then
        wget ${url}github.com/biliup/biliup-rs/releases/latest/download/biliupR-${biliuprs_version}-arm-linux.tar.xz && tar -xf biliupR-${biliuprs_version}-arm-linux.tar.xz && mv "biliupR-${biliuprs_version}-arm-linux/biliup" "biliupR"
    elif [ "$arch_choice" -eq 1 ]; then
        wget ${url}github.com/biliup/biliup-rs/releases/latest/download/biliupR-${biliuprs_version}-aarch64-linux.tar.xz && tar -xf biliupR-${biliuprs_version}-aarch64-linux.tar.xz && mv "biliupR-${biliuprs_version}-aarch64-linux/biliup" "biliupR"
    else
        wget ${url}github.com/biliup/biliup-rs/releases/latest/download/biliupR-${biliuprs_version}-x86_64-linux.tar.xz && tar -xf biliupR-${biliuprs_version}-x86_64-linux.tar.xz && mv "biliupR-${biliuprs_version}-x86_64-linux/biliup" "biliupR"
    fi
    rm -rf biliupR-*-linux && rm -f biliupR-*-linux.tar.xz
    echo -e "biliup-rs完成：${green}已经下载\033[0m"
fi

read -p "根据情况选择0:上传 1:追加投稿[0/1]: " OPERATION_TYPE
if ! [[ "$OPERATION_TYPE" =~ ^[0-9]+$ ]] || [ "$OPERATION_TYPE" -ne 1 ]; then
  OPERATION_TYPE=0
  echo "未输入或输入非1，自动选择 0:上传"
else
  echo "选择了 ${OPERATION_TYPE}:上传"
fi

while [[ ! " $ALLOWED_TYPES " =~ " $FILE_TYPE " ]]; do
  read -p "请输入文件类型（例如：flv）: " FILE_TYPE
done

while true; do
  read -p "请输入需要上传文件的目录: " OUTPUT_BASE
  IFS=$'\n'
  files=($(find "$OUTPUT_BASE" -name "*.$FILE_TYPE" 2>/dev/null))
  if [ ${#files[@]} -eq 0 ]; then
    echo "没有找到文件，请重新输入。"
    continue
  fi
  echo "上传 ${#files[@]} 个文件"
done

if [ "$OPERATION_TYPE" -eq 0 ]; then
while true; do
    read -p "请输入上传标签（多个标签逗号,隔开）: " UPLOAD_TAG
    if [ -z "$UPLOAD_TAG" ]; then
        UPLOAD_TAG=${UPLOAD_TAG:-biliup}
        break
    else
        UPLOAD_TAG=${UPLOAD_TAG//，/,}
        if [[ "$UPLOAD_TAG" == *,,* ]]; then
            echo "输入错误，不能连续输入多个逗号,隔开"
        else
            echo "您输入的标签 $UPLOAD_TAG"
            break
        fi
    fi
  done
  echo "输入了 ${UPLOAD_TAG} 标签"
  line_option=($([ "$country_code" = "CN" ] || echo "--line ws"))
  cd ${BILIUP_DIR} && ./biliupR upload "${files[@]}" --tag $UPLOAD_TAG --limit ${#files[@]} "${line_option[@]}"
else
  while [[ ! $OPERATIONFILE_TYPE =~ ^(BV|AV)[a-zA-Z0-9]+$ ]]; do
    read -p "请输入追加稿件的BV号（例如：BV1fr42147Re）: " OPERATIONFILE_TYPE
  done
  line_option=($([ "$country_code" = "CN" ] || echo "--line ws"))
  cd ${BILIUP_DIR} && ./biliupR append --vid $OPERATIONFILE_TYPE "${files[@]}" --limit ${#files[@]} "${line_option[@]}"
fi
