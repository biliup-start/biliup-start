#!/bin/bash  
  
LOG_FILE="/opt/biliup/keep/script-df-`date +"%Y-%m"`.log"    
REC_DIR1="/opt/DanmakuRender/直播回放/录播"  
REC_DIR2="/opt/DanmakuRender/直播回放/录播（带弹幕版）"  
command="find /opt/biliup/cover -type f -mtime 0 -delete"  
command1="find /opt/biliup -type f -name '*.flv' -mtime 0 -delete"  
command2="find /opt/biliup -type f -name '*.xml' -mtime 0 -delete"  
  
declare -A log_messages

log_with_timestamp() {  
    local message="$1"
    if [[ -z "${log_messages[$message]}" ]]; then
        echo "$(date): $message" >> "$LOG_FILE"
        log_messages["$message"]=1
    fi
}  
  
check_disk_space() {  
    # 检查磁盘空间是否低于5%  
    df --output=pcent "/" | tail -1 | awk '{print $1}' | grep -q '^[5-9][0-9]*%$\|^100%$'  
    return $?  # 返回状态码，如果磁盘空间低于5%，则返回0
}  
  
delete_file_if_unused() {  
    local file="$1"  
    local base_name="${filename%.*}"  
      
    if [ -e "$REC_DIR2/${base_name}（带弹幕版）.*" ]; then  
        if ! fuser -s "$file" >/dev/null 2>&1; then  
            log_with_timestamp "文件 $file 不再被使用，开始删除"  
            if rm -f "$file"; then  
                log_with_timestamp "文件 $file 删除成功"  
            else  
                log_with_timestamp "文件 $file 删除失败"  
            fi  
        else  
            log_with_timestamp "文件 $file 正在被使用，跳过删除"  
        fi  
    else  
        log_with_timestamp "对应的带弹幕版文件不存在，跳过 $filename"  
    fi  
}  
  
cleanup() {  
    log_with_timestamp "脚本执行意外结束"  
    exit 1  
}  
  
trap cleanup INT TERM EXIT  
  
log_with_timestamp "脚本开始执行"  
  
while true; do  
    if check_disk_space; then  
        log_with_timestamp "磁盘空间低于5%，开始执行清理任务"  
          
        for dir in "$REC_DIR1" "$REC_DIR2"; do  
            for file in "$dir"/*; do  
                if [ -f "$file" ]; then  
                    delete_file_if_unused "$file"  
                    sudo bash -c "$command" >> "$LOG_FILE" 2>&1 
                    sudo bash -c "$command1" >> "$LOG_FILE" 2>&1 
                    sudo bash -c "$command2" >> "$LOG_FILE" 2>&1 
                fi  
            done  
        done  
    else  
        log_with_timestamp "未达到清理条件，磁盘空间大于5%"  
    fi  
    sleep 60  
done