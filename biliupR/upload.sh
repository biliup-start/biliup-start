#!/bin/bash

BILIUP_DIR=/opt/biliup
ALLOWED_TYPES="mp4 flv avi wmv mov webm mpeg4 ts mpg rm rmvb mkv"

echo "请稍等正在检查biliupR文件(如存在直接进行下一步)..."

country_code=$(curl -s https://ipinfo.io/country)

if ! find / -wholename "${BILIUP_DIR}/biliupR" -print -quit | grep -q .; then
    cd ${BILIUP_DIR} 
    if [ "$country_code" = "CN" ]; then
        url="https://j.iokun.top/https://"
    else
        url="https://"
    fi
    echo "你的CPU架构是："
    echo -e "    （\e[31m默认\033[0m）0: \e[33mx86_64\033[0m"
    echo -e "            1: \033[0;32mARMa64\033[0m"
    echo -e "            2: \033[0;32m ARM\033[0m"
    read -p "请输入[0/1/2]：" arch_choice
    if [[ -z "$arch_choice" || ! "$arch_choice" =~ [0-2] ]]; then
        echo "你输入错误，使用默认 \e[33mx86_64\033[0m CPU架构："
        arch_choice=0
    fi
    if [ "$arch_choice" -eq 2 ]; then
        wget ${url}github.com/biliup/biliup-rs/releases/download/v0.1.19/biliupR-v0.1.19-arm-linux.tar.xz && tar -xf biliupR-v0.1.19-arm-linux.tar.xz && mv "biliupR-v0.1.19-arm-linux/biliup" "biliupR"
    elif [ "$arch_choice" -eq 1 ]; then
        wget ${url}github.com/biliup/biliup-rs/releases/download/v0.1.19/biliupR-v0.1.19-aarch64-linux.tar.xz && tar -xf biliupR-v0.1.19-aarch64-linux.tar.xz && mv "biliupR-v0.1.19-aarch64-linux/biliup" "biliupR"
    else
        wget ${url}github.com/biliup/biliup-rs/releases/download/v0.1.19/biliupR-v0.1.19-x86_64-linux.tar.xz && tar -xf biliupR-v0.1.19-x86_64-linux.tar.xz && mv "biliupR-v0.1.19-x86_64-linux/biliup" "biliupR"
    fi
    rm -rf biliupR-v0.1.19-*-linux && rm -f biliupR-v0.1.19-*-linux.tar.xz
    echo -e "biliup-rs完成：${green}已经下载\033[0m"
fi

read -p "根据情况选择0:上传 1:追加投稿[0/1]: " OPERATION_TYPE
if ! [[ "$OPERATION_TYPE" =~ ^[0-9]+$ ]]; then
  OPERATION_TYPE=0
  echo "输出错误，自动选择 0:上传"
else
  if [ "$OPERATION_TYPE" -eq 1 ]; then
    echo "选择了 ${OPERATION_TYPE}:追加投稿"
  elif [ "$OPERATION_TYPE" -eq 0 ]; then
    echo "选择了 ${OPERATION_TYPE}:上传"
  else
    OPERATION_TYPE=0
    echo "输出错误，自动选择 0:上传"
  fi
fi

while [[ ! " $ALLOWED_TYPES " =~ " $FILE_TYPE " ]]; do
  read -p "请输入文件类型（例如：flv）: " FILE_TYPE
done

while [[ ! "$OUTPUT_BASE" = /* ]]; do
  read -p "请输入需要上传文件的目录: " OUTPUT_BASE
done

IFS=$'\n'
files=($(find "$OUTPUT_BASE" -name "*.$FILE_TYPE"))
if [ ${#files[@]} -eq 0 ]; then
  echo "没有找到文件"
  exit 1
fi

echo "上传 ${#files[@]} 个文件"

if [ "$OPERATION_TYPE" -eq 0 ]; then
  while true; do
    read -p "请输入上传标签（多个标签逗号,隔开）: " UPLOAD_TAG
    if [[ "$UPLOAD_TAG" =~ ^\^ ]]; then
        echo "输入错误，标签不能以 ^ 开头"
    elif [ -z "$UPLOAD_TAG" ]; then
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
  cd ${BILIUP_DIR} && ./biliupR upload "${files[@]}" --tag $UPLOAD_TAG --limit 99 "${line_option[@]}"
else
  while [[ ! $OPERATIONFILE_TYPE =~ ^(BV|AV)[a-zA-Z0-9]+$ ]]; do
    read -p "请输入追加稿件的BV号（例如：BV1fr42147Re）: " OPERATIONFILE_TYPE
  done
  line_option=($([ "$country_code" = "CN" ] || echo "--line ws"))
  cd ${BILIUP_DIR} && ./biliupR append --vid $OPERATIONFILE_TYPE "${files[@]}" --limit 99 "${line_option[@]}"
fi
