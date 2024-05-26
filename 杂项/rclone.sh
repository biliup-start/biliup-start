#!/bin/bash

# 检查jq是否已安装
if ! command -v jq &> /dev/null ;then
    sudo apt-get update
    sudo apt-get install jq -y
fi

# 初始化onedrive的编号
onedrive_number=1

while true; do
    # 获取rclone挂载的网盘容量
    capacity=$(rclone size onedrive${onedrive_number}: --json | jq .bytes)

    # 当容量大于或等于3.192 TiB时
    if (( capacity >= 3509536902232 )); then
        # onedrive的编号累加
        ((onedrive_number++))

        # 更新/etc/systemd/system/rclone.service文件
        echo "[Unit]
Description=OneDrive
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/rclone mount onedrive${onedrive_number}:/ /opt/rclone --copy-links --no-gzip-encoding --no-check-certificate --allow-other --allow-non-empty --umask 000 --vfs-cache-mode writes
Restart=on-abort
User=root

[Install]
WantedBy=default.target" > /etc/systemd/system/rclone.service

        systemctl daemon-reload
        systemctl stop rclone.service
        fusermount -u /opt/rclone
        systemctl start rclone.service
    fi

    sleep 60
    bash /opt/x.sh
    
done
