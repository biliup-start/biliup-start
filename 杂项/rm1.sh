#!/bin/bash

# 日志文件路径
LOG_FILE="/opt/biliup/keep/rclone-rm-`date +"%Y-%m"`.log"

# 要执行的命令
command1="rclone sync '/opt/DanmakuRender/直播回放/' onedrive:/zhibo/3419998 --include '安慕茜茜子*.{xml,ass,flv,mp4,m4s}' --onedrive-chunk-size 100M"
command2='rclone copy onedrive:/zhibo/3419998 onedrive:/zhibo/往期回放/"$(date -d "1 day ago" +"%Y-%m")"/"$(date -d "1 day ago" +"%d")"'
command3="find /opt/DanmakuRender/直播回放/ -type f -name '*.*' -mmin +1320 -delete"
max_retries=5  # 设置最大重试次数

# 获取当前时间（小时:分钟）
current_time=$(date +"%H:%M")

# 记录带有时间戳的消息到日志文件
log_with_timestamp() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" >> "$LOG_FILE"
}

# 根据当前时间判断是否执行同步任务
if [[ "$current_time" < "11:11" ]]; then  # 如果当前时间小于*点*分
    # 在循环任务中执行命令，并添加随机延迟
    for ((i=1; i<=max_retries; i++)); do  # 循环尝试最多max_retries次
    
        log_with_timestamp "清理DanmakuRender文件执行..."
        sudo bash -c "$command3" >> "$LOG_FILE" 2>&1
        if [ $? -eq 0 ]; then
            echo "清理任务执行成功。" >> "$LOG_FILE"
        else
            echo "清理任务执行失败。" >> "$LOG_FILE"
        fi
            
        # 等待5分钟
        sleep 300
        
        log_with_timestamp "执行rclone..."
        sudo bash -c "$command1" >> "$LOG_FILE" 2>&1  # 执行定义的命令，并将标准输出和错误输出追加到日志文件
        exit_status=$?  # 获取命令的退出状态码
        log_with_timestamp "rclone命令执行完毕，退出状态码：$exit_status"  # 记录命令执行完毕的时间戳和退出状态码
        if [ $exit_status -eq 0 ]; then  # 如果退出状态码为0，表示命令执行成功
            log_with_timestamp "rclone命令执行成功。"

            # 等待5分钟
            sleep 300

            # 执行新的命令
            log_with_timestamp "执行新的命令..."
            for dir in $(ls /home/rclone); do
                if [ "$dir" != "往期回放" ]; then
                    # 检查是否存在昨天日期的文件
                    if ls /home/rclone/${dir}/*$(date -d "1 day ago" +"%Y-%m-%d")*.mp4 1> /dev/null 2>&1; then
                        dest_dir="/home/rclone/往期回放/$(date -d "1 day ago" +"%Y-%m")/$(date -d "1 day ago" +"%d")"
                        mkdir -p "$dest_dir"
                        cp /home/rclone/${dir}/*$(date -d "1 day ago" +"%Y-%m-%d")*.mp4 "$dest_dir"
                    fi
                fi
            done


            # 等待5分钟
            sleep 300

            #  同步完复制到往期回放
            log_with_timestamp "执行复制任务..."
            sudo bash -c "$command2" >> "$LOG_FILE" 2>&1
            if [ $? -eq 0 ]; then
                echo "复制任务执行成功。" >> "$LOG_FILE"
            else
                echo "复制任务执行失败。" >> "$LOG_FILE"
            fi

            break  # 成功后跳出循环

        else  # 如果退出状态码不为0，表示命令执行失败
            log_with_timestamp "rclone命令执行失败，尝试次数：$i/$max_retries。"
            if [ $i -eq $max_retries ]; then  # 如果已经达到最大重试次数
                log_with_timestamp "达到最大重试次数，退出循环。"
                break  # 退出循环
            fi
            random_delay=$(( RANDOM % 60 + 240 ))  # 生成60到300秒之间的随机数
            log_with_timestamp "等待 $random_delay 秒后继续下一次尝试。"
            sleep $random_delay  # 等待指定的随机延迟时间
        fi
    done
else
    log_with_timestamp "当前时间已超过11点11分，跳过rclone命令。"
fi

# 等待所有后台任务完成
wait
echo "脚本执行结束时间：$(date)" >> "$LOG_FILE"
