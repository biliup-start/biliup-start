#!/bin/bash  

LOG_FILE="/opt/biliup/keep/brec-fix-`date +"%Y-%m"`.log"
INPUT_BASE="/opt/brec"  
OUTPUT_BASE="/opt/biliup"  
declare -A FILE_PREFIXES
declare -A CHECKED_FILES
LOG_COUNTER=0
log_with_timestamp() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" >> "$LOG_FILE"
}

cleanup() {
    log_with_timestamp "脚本执行意外结束"
    exit 1
}
trap cleanup INT TERM EXIT

while true; do
    FILES=$(find "$OUTPUT_BASE" -type f -name "*.flv.part" -mtime 0)
    NEW_FILES=$(find "$OUTPUT_BASE" -type f -name "*_P*.flv" -mmin -2)  
    LATEST_FILES=$(find "$OUTPUT_BASE" -type f -name "*.flv" -not -name "*_P*.flv" -mmin -2) 
    IFS=$'\n'
    
    for FILE in $FILES; do
    BASENAME=$(basename "$FILE" .flv.part)_P000
    PREFIX=${BASENAME:0:5}	
    if [ -z "${FILE_PREFIXES[$PREFIX]}" ]; then
	   cp /opt/1.mp4 "$OUTPUT_BASE/$BASENAME.mp4"
        log_with_timestamp "已添加前置文件 $BASENAME.mp4"
        FILE_PREFIXES["$PREFIX"]=1
    fi
    done

    if [ -z "$LATEST_FILES" ] && [ -z "$NEW_FILES" ]; then  
        if [ "$LOG_COUNTER" -eq 0 ]; then
            log_with_timestamp "没有找到两分钟内修改的*.flv文件。"
            LOG_COUNTER=$((LOG_COUNTER+1))
        fi
    else
        LOG_COUNTER=0
        for FILE in $LATEST_FILES $NEW_FILES; do
            if [ -z "${CHECKED_FILES[$FILE]}" ]; then
                log_with_timestamp "找到的最新修改的*.flv文件是: $(basename "$FILE")"
                NEED_FIX=$($INPUT_BASE/BililiveRecorder.Cli tool analyze "$FILE" | awk -F'│' '/Unrepairable|Other|TimestampJump|TimestampOffset|DecodingHeader|RepeatingData/ {sum += $3} END{print sum}')   
                if [ "$NEED_FIX" -ne 0 ]; then  
                    log_with_timestamp "文件可能需要修复，现在运行修复命令..."
                    if [[ $LATEST_FILES == *"$FILE"* ]]; then
                        sudo bash -c "$INPUT_BASE/BililiveRecorder.Cli tool fix \"$FILE\" \"$FILE\"" >> "$LOG_FILE" 2>&1  
                        for FILE_BASE in $(find "$OUTPUT_BASE" -type f -name "*.fix_p*.flv" ); do
                            mv "$FILE_BASE" "$(echo "$FILE_BASE" | sed 's/\.fix_p/_P/')"
                        done
                        mv "$(echo "$FILE.xml" | sed 's/\.flv//')" "$(echo "$FILE.xml" | sed 's/\.flv/_P001/')"
                    elif [[ $NEW_FILES == *"$FILE"* ]]; then
                        sudo bash -c "ffmpeg -i \"$FILE\" -c:v h264_qsv -c:a aac \"$(echo "$FILE.mp4" | sed 's/\.flv//')\"" >> "$LOG_FILE" 2>&1 
                    fi
                    if [ $? -eq 0 ]; then  
                        mv "$FILE" "/home/rclone/待修文件"
                        log_with_timestamp "修复成功，源文件移动到rclone上传：待修文件/$(basename "$FILE")"          
                    else  
                        log_with_timestamp "修复失败，请到录播姬文档查看更详细的错误信息。"
                    fi  
                else  
                    if [[ $LATEST_FILES == *"$FILE"* ]]; then
                        cp "$FILE" "$(echo "$FILE.flv" | sed 's/\.flv/_P001/')" && rm "$FILE"
                        mv "$(echo "$FILE.xml" | sed 's/\.flv//')" "$(echo "$FILE.xml" | sed 's/\.flv/_P001/')"
                        log_with_timestamp "不需要修复或录播姬无法修复已重命名"
                    elif [[ $NEW_FILES == *"$FILE"* ]]; then
                        log_with_timestamp "录播姬判断无需 ffmpeg转换文件格式"
                    fi
                fi  
                CHECKED_FILES["$FILE"]=1
            fi
        done
    fi
    sleep 33
done