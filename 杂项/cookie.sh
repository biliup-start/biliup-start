#!/bin/bash

cookie_file="douyin.txt"

__ac_nonce=$(grep -o '__ac_nonce=[^;]*' "$cookie_file" | awk -F= '{print $2}' | sed 's/;.*//')
__ac_signature=$(grep -o '__ac_signature=[^;]*' "$cookie_file" | awk -F= '{print $2}' | sed 's/;.*//')
sessionid=$(grep -o 'sessionid=[^;]*' "$cookie_file" | awk -F= '{print $2}' | sed 's/;.*//')

if [ -n "$__ac_nonce" ] && [ -n "$__ac_signature" ] && [ -n "$sessionid" ]; then
    douyin_cookie="__ac_nonce=$__ac_nonce;__ac_signature=$__ac_signature;sessionid=$sessionid;"
    echo douyin_cookie = "\"$douyin_cookie\"" > douyin.json
else
    echo "cookies字段不齐全"
fi