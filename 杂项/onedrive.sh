#!/bin/bash

# 初始化onedrive的编号
onedrive_number=1

while true; do
    # 获取rclone挂载的网盘容量
    capacity=$(df --output=pcent /opt/rclone | tail -n 1 | tr -dc '0-9')

    # 当容量小于2%时
    if (( capacity < 2 )); then
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

        # 运行fusermount -u /opt/rclone命令和sudo systemctl restart rclone.service命令
        fusermount -u /opt/rclone
        systemctl restart rclone.service
        bash /opt/x.sh

        # onedrive的编号累加
        ((onedrive_number++))
    fi

    # 每隔一段时间检查一次，这里设为1小时
    sleep 1h
done
