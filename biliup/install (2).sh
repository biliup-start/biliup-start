#!/bin/bash

# 发送运行次数到后端服务器
backend_url="https://run.biliup.me/update_run_count"
curl -X POST -d "run_count=1" "$backend_url" > /dev/null 2>&1

# 请求 Flask 获取运行次数
get_run_count_url="https://run.biliup.me/get_run_count"
run_count=$(curl -s "$get_run_count_url" | sed -n 's/.*"run_count":\([^,}]*\).*/\1/p')

# 输出到终端
#echo "一键脚本已运行 $run_count 次"

# ANSI转义码，设置高亮
highlight="\e[1;31m"  # 1是高亮，31是红色
reset="\e[0m"         # 重置文字属性

# 获取终端宽度
columns=$(tput cols)

# ANSI颜色代码
red="\e[1;31m"
green="\e[1;32m"
yellow="\e[1;33m"
blue="\e[1;34m"
magenta="\e[1;35m"
cyan="\e[1;36m"
light_green="\e[1;92m"
reset="\e[0m"         # 重置文字属性

# 要显示的 ASCII 艺术，每行不同颜色
ascii_art="
${red}\e[1m    一键脚本已运行 $run_count 次 ${reset}

${red}\e[1m ▄▄▄▄· ▪  ▄▄▌  ▪  ▄• ▄▌ ▄▄▄·${reset}
${green}\e[1m ▐█ ▀█▪██ ██•  ██ █▪██▌▐█ ▄█${reset}
${yellow}\e[1m ▐█▀▀█▄▐█·██▪  ▐█·█▌▐█▌ ██▀·${reset}
${blue}\e[1m ██▄▪▐█▐█▌▐█▌▐▌▐█▌▐█▄█▌▐█▪·•${reset}
${magenta}\e[1m ·▀▀▀▀ ▀▀▀.▀▀▀ ▀▀▀ ▀▀▀ .▀   ${reset}
${cyan}\e[1m                                      ${reset}
${light_green}\e[1m biliup社区论坛:https://biliup.me${reset}"

# 计算居中的空格数量
padding=$((($columns - 32) / 2))

# 显示居中的 ASCII 艺术
echo -e "${highlight}$(echo "$ascii_art" | sed "s/^/$(printf "%${padding}s")/")${reset}"

echo -e ${green}"====="${green}Biliup-Script${white}"====="${background}
echo -e ${cyan}Biliup-Script ${green}是完全可信的。${background}
echo -e ${cyan}Biliup-Script ${yellow}不会执行任何恶意命令${background}
echo -e ${cyan}Biliup-Script ${yellow}不会执行任何恶意命令${background}
echo -e ${cyan}Biliup-Script ${yellow}不会执行任何恶意命令${background}

read -p "是否要启用安装脚本？(Y/N): " choice
if [ "$choice" = "Y" ] || [ "$choice" = "y" ]; then
    echo -e "${light_green}启用安装脚本...${reset}"

    set -e

    echo -e "${light_green}开始更新软件包列表...${reset}"
    apt update && apt upgrade -y
    echo -e "${yellow}软件包列表更新完成。${reset}"
    
    echo -e "${light_green}开始安装必要工具...${reset}"
    apt install wget curl ufw whiptail -y
    echo -e "${yellow}必要工具安装完成。${reset}"

    echo -e "${light_green}开始安装 python3-dev...${reset}"
    apt install -y python3-dev
    echo -e "${yellow}python-dev 安装完成。${reset}"

    echo -e "${light_green}开始安装 ffmpeg...${reset}"
    apt install -y ffmpeg
    echo -e "${yellow}ffmpeg 安装完成。${reset}"

    echo -e "${light_green}开始安装 nodejs...${reset}"
    apt install -y nodejs
    echo -e "${yellow}nodejs 安装完成。${reset}"

    echo -e "${light_green}开始安装 pip...${reset}"
    apt install -y python3-pip
    echo -e "${yellow}pip 安装完成。${reset}"

    echo -e "${light_green}开放webui端口...${reset}"
    ufw allow 19159
    echo -e "${yellow}已开放19159端口，请确认控制台有无开放安全组。${reset}"

    # 获取Python3的版本号
    python_version=$(python3 --version | cut -d " " -f2)
    
    # 检测IP地址，决定使用哪个源来升级pip或安装biliup
    country=$(curl -s ipinfo.io/country)
    pip_source=""
    source_description="默认源"
    
    if [ "$country" = "CN" ]; then
        echo -e "${yellow}您的 IP 地址显示为中国，正在使用清华源...${reset}"
        pip_source="https://pypi.tuna.tsinghua.edu.cn/simple"
        source_description="清华源"
    else
        echo -e "${yellow}您的 IP 地址显示为非中国，正在使用默认源...${reset}"
    fi
    
    # 如果Python版本低于3.8，则升级pip
    if [[ $(echo -e "3.8\n$python_version" | sort -V | tail -n1) != "$python_version" ]]; then
        echo -e "${yellow}当前Python版本低于3.8，正在使用${source_description}升级pip到最新版本...${reset}"
        PIP_INDEX_URL=$pip_source pip3 install --upgrade pip
        echo -e "${light_green}pip升级完成。${reset}"
    fi
    
    # 使用sort命令和版本比较来决定使用哪个pip命令
    if printf '3.11\n%s' "$python_version" | sort -V | head -n1 | grep -q '3.11'; then
        echo -e "${highlight}Python3的版本是 $python_version, 使用pip install --break-system-packages来安装...${reset}"
        pip_install_cmd="pip3 install --break-system-packages"
    else
        echo -e "${highlight}Python3的版本是 $python_version, 使用标准pip install来安装...${reset}"
        pip_install_cmd="pip3 install"
    fi
    
    # 使用whiptail创建菜单，让用户选择biliup版本
    VERSION_CHOICE=$(whiptail --title "选择 biliup 版本" --menu "选择您要安装的 biliup 版本:" 15 60 3 \
        "1" "安装最新版（webui）" \
        "2" "安装稳定版（0.4.31）" \
        "3" "自选版本" 3>&1 1>&2 2>&3)
    
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        # 根据选择设置biliup_version
        if [ "$VERSION_CHOICE" = "1" ]; then
            echo -e "${yellow}您选择了安装biliup最新版...${reset}"
            biliup_version="biliup"
        elif [ "$VERSION_CHOICE" = "2" ]; then
            echo -e "${yellow}您选择了安装biliup稳定版 0.4.31...${reset}"
            biliup_version="biliup==0.4.31"
        elif [ "$VERSION_CHOICE" = "3" ]; then
            # 使用whiptail的inputbox让用户输入版本号
            input_version=$(whiptail --title "输入biliup版本" --inputbox "请输入biliup的安装版本号：" 10 60 3>&1 1>&2 2>&3)
            exitstatus=$?
            if [ $exitstatus = 0 ]; then
                biliup_version="biliup==$input_version"
            else
                echo "用户取消了操作"
                exit 1
            fi
        fi
    else
        echo "用户取消了操作"
        exit 1
    fi

    
    # 使用之前选择的命令来安装 biliup
    echo -e "${yellow}正在使用${source_description}安装 biliup...${reset}"
    PIP_INDEX_URL=$pip_source $pip_install_cmd $biliup_version
    
    echo -e "${highlight}所有安装步骤完成！！${reset}"


else
    echo -e "${highlight}已取消安装脚本。${reset}"
fi