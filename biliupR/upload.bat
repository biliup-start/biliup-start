#!/bin/bash

BILIUP_DIR=/opt/biliup
ALLOWED_TYPES="mp4 flv avi wmv mov webm mpeg4 ts mpg rm rmvb mkv"

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

while [[ ! "$OUTPUT_BASE" = /* ]]; do
  read -p "请输入需要上传文件的目录: " OUTPUT_BASE
done

IFS=$'\n'
files=($(find "$OUTPUT_BASE" -name "*.$FILE_TYPE"))
if [ ${#files[@]} -eq 0 ]; then
  echo "没有找到文件"
  exit 1
fi

country_code=$(curl -s https://ipinfo.io/country)

echo "上传 ${#files[@]} 个文件"
if [ "$OPERATION_TYPE" -eq 0 ]; then
  read -p "请输入上传标签: " UPLOAD_TAG
  UPLOAD_TAG=${UPLOAD_TAG:-biliup}
  echo "选择了 ${UPLOAD_TAG} 标签"
  line_option=($([ "$country_code" = "CN" ] || echo "--line ws"))
  cd ${BILIUP_DIR} && ./biliupR upload "${files[@]}" --tag $UPLOAD_TAG --limit 99 "${line_option[@]}"
else
  while [[ ! $OPERATIONFILE_TYPE =~ ^(BV|AV)[a-zA-Z0-9]+$ ]]; do
    read -p "请输入追加稿件的BV号（例如：BV1fr42147Re）: " OPERATIONFILE_TYPE
  done
  line_option=($([ "$country_code" = "CN" ] || echo "--line ws"))
  cd ${BILIUP_DIR} && ./biliupR append --vid $OPERATIONFILE_TYPE "${files[@]}" --limit 99 "${line_option[@]}"
fi
