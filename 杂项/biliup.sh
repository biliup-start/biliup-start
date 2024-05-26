#!/bin/bash

biliup_path="/opt/biliup"
log_path="/opt/biliup/logs"
LOG_PRINTED=0

while true; do
  # 检查特定文件是否不存在
  if ! find "$biliup_path" -type f \( -name "*.flv" -o -name "*.mp4" -o -name "*.ts" -o -name "*.part" \) -print -quit | read; then
    LOG_PRINTED=0
    screen -S biliup -dm bash -c 'cd "$biliup_path" && biliup -P 65000 --password Gy67XpZimzuC:nD start' && \
    echo "$(date +"%Y-%m-%d %H:%M:%S") Biliup Restart" >> "${log_path}/Biliup-$(date +"%Y-%m").log"
    sleep 3600
    continue
  else
    # 检查进程是否存在
    if pgrep -f "biliup[^.]*$" >/dev/null; then
      # 如果进程存在，但您想记录它正在运行，可以这样做
      if [ "$LOG_PRINTED" -eq 0 ]; then
        echo "$(date +"%Y-%m-%d %H:%M:%S") Biliup运行中" >> "${log_path}/Biliup-$(date +"%Y-%m").log"
        LOG_PRINTED=1
      fi
    else
      # 如果进程不存在，启动它并记录启动日志
      LOG_PRINTED=0
      screen -S biliup -dm bash -c 'cd "$biliup_path" && biliup -P 65000 --password Gy67XpZimzuC:nD start' && \
      echo "$(date +"%Y-%m-%d %H:%M:%S") Biliup Start" >> "${log_path}/Biliup-$(date +"%Y-%m").log"
      sleep 11
    fi
  fi

  # 清空大于5MB的日志文件
  find /opt/ -type f -name "*.log*" -size +5M -exec truncate -s 0 {} \;

  # 等待60秒，然后再次检查
  sleep 60
done
