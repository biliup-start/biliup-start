#!/bin/bash    
  
# 日志文件路径    
LOG_FILE="/opt/biliup/keep/rm-find-`date +"%Y-%m"`.log"        
  
# 要执行的命令   
command="find /home -path '/home/rclone/往期回放' -prune -o -type f -mtime +7 -print | xargs rm -f" 
command1="find /opt -type f \( -name '*.mp4' -o -name '*.flv' -o -name '*.m4s' -o -name '*log*' -o -name '*.xml' -o -name '*.ass' -o -name '*.jpg' -o -name '*.jsonl' \) -type f -mtime +5 -delete"
  
# 带时间戳的日志函数    
log_with_timestamp() {    
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" >> "$LOG_FILE"
}    
  
# 记录脚本开始执行的时间戳    
log_with_timestamp "脚本开始执行"    

# 执行命令并记录输出到日志文件    
sudo bash -c "$command" >> "$LOG_FILE" 2>&1    
if [ $? -eq 0 ]; then  
    echo "home目录下删除任务执行成功" >> "$LOG_FILE"  
else  
    echo "home目录下删除任务执行失败" >> "$LOG_FILE"  
fi    

# 等待5分钟
sleep 300
            
# 执行命令并记录输出到日志文件    
sudo bash -c "$command1" >> "$LOG_FILE" 2>&1    
if [ $? -eq 0 ]; then  
    echo "opt目录下删除任务执行成功" >> "$LOG_FILE"  
else  
    echo "opt目录下删除任务执行失败" >> "$LOG_FILE"  
fi    

# 脚本执行结束  
log_with_timestamp "脚本执行结束"
