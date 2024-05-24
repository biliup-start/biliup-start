#!/bin/bash

# 函数：检测发行版类型
detect_distro() {
    if [ -e /etc/os-release ]; then
        source /etc/os-release
        case "$ID" in
            "ubuntu" | "debian")
                echo "$ID"
                ;;
            "centos")
                if [ "$VERSION_ID" == "8" ]; then
                    echo "CentOS8"
                else
                    echo "CentOS"
                fi
                ;;
            *)
                echo "Unknown"
                ;;
        esac
    else
        echo "Unknown"
    fi
}

# 主逻辑
distro=$(detect_distro)

case $distro in
    "CentOS" | "Fedora" | "RHEL")
        package_manager="yum"
        ;;
    "ubuntu" | "debian")
        package_manager="apt"
        ;;
    "CentOS8")
        package_manager="dnf"
        ;;
    *)
        echo "不支持的 Linux 发行版: $distro"
        exit 1
        ;;
esac

# 获取MAC地址密钥
api_key_base="mcj61eu11g3sk7o366afxv6pnacwd9"
mac_address=$(ifconfig -a | grep ether | awk '{print $2}' | head -n 1 | tr -d ':')
api_key="$api_key_base$mac_address"

# 发送运行次数到后端服务器
backend_url="https://run.iokun.cn/update_run_count/Linux"
curl -X POST -d "run_count=1" -H "X-API-KEY: $api_key" -H "X-MAC-ADDRESS: $mac_address" "$backend_url" > /dev/null 2>&1

# 请求 Flask 获取运行次数
get_run_count_url="https://run.iokun.cn/get_run_count/total"
run_count=$(curl -s -H "X-API-KEY: $api_key" -H "X-MAC-ADDRESS: $mac_address" "$get_run_count_url" | sed -n 's/.*"total_run_count":\([^,}]*\).*/\1/p')

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
${red}\e[1m一键安装脚本旧版已运行 $run_count 次 ${reset}

${red}\e[1m ▄▄▄▄· ▪  ▄▄▌  ▪  ▄• ▄▌ ▄▄▄·${reset}
${green}\e[1m ▐█ ▀█▪██ ██•  ██ █▪██▌▐█ ▄█${reset}
${yellow}\e[1m ▐█▀▀█▄▐█·██▪  ▐█·█▌▐█▌ ██▀·${reset}
${blue}\e[1m ██▄▪▐█▐█▌▐█▌▐▌▐█▌▐█▄█▌▐█▪·•${reset}
${magenta}\e[1m ·▀▀▀▀ ▀▀▀.▀▀▀ ▀▀▀ ▀▀▀ .▀   ${reset}
${cyan}\e[1m                                      ${reset}
${red}\e[1m 注意重要: 魔改版本,非社区原版${reset}
${light_green}\e[1m 原版脚本: https://biliup.me/d/34 ${reset}
${light_green}\e[1m 爱发电  : https://afdian.net/a/biliup ${reset}"

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
if [ "$choice" = "N" ] || [ "$choice" = "n" ]; then
    echo -e "${highlight}已取消安装脚本。${reset}"
else
    echo -e "${light_green}启用安装脚本...${reset}"

    set -e

    echo -e "${light_green}开始更新软件包列表...${reset}"
    $package_manager update && $package_manager upgrade -y
    echo -e "${yellow}软件包列表更新完成。${reset}"
    
    echo -e "${light_green}开始安装必要工具...${reset}"
    $package_manager install wget curl -y
    echo -e "${yellow}必要工具安装完成。${reset}"

    echo -e "${light_green}开始安装 python3...${reset}"
    if [ "$package_manager" = "apt" ]; then
        $package_manager install -y python3-dev ufw
        echo -e "${light_green}开放webui端口...${reset}"
        ufw allow 19159
        echo -e "${yellow}已开放19159端口，请确认控制台有无开放安全组。${reset}"
    else
        if [ "$package_manager" = "yum" ]; then
            $package_manager install -y centos-release-scl
            $package_manager install -y rh-python38
            source /opt/rh/rh-python38/enable
        elif [ "$package_manager" = "dnf" ]; then
            $package_manager -y install python38
        fi
        $package_manager install -y epel-release
        $package_manager localinstall --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm
    fi
    echo -e "${yellow}python 安装完成。${reset}"

    echo -e "${light_green}开始安装 ffmpeg..."
    if command -v ffmpeg >/dev/null 2>&1; then
        echo -e "${yellow}ffmpeg 已经安装。${reset}"
    else
        if [ "$package_manager" = "dnf" ]; then
            read -p "注意稀有系统只安装adm64版本，其他版本请N？(Y/N): " dnfadm64
            if [ "$dnfadm64" = "Y" ] || [ "$dnfadm64" = "y" ]; then
                wget -O ffmpeg.tar.xz https://blrec.iokun.top/d/189/jia/ffmpeg.tar.xz?sign=j9F5qqLn7e679cvZ-KE035I_fONMLNnSw2gmg5MbgaM=:0
                tar xvf ffmpeg.tar.xz && rm -rf ffmpeg.tar.xz
                mv ffmpeg-*-*/ffmpeg  ffmpeg-*-*/ffprobe /usr/bin/
            else
                echo -e "${blue}其他版本FFmpeg，请到 https://www.johnvansickle.com/ffmpeg/ 下载${reset}"
                exit 1
            fi
        else
            $package_manager install -y ffmpeg
        fi
        echo -e "${yellow}ffmpeg 安装完成。${reset}"
    fi

    echo -e "${light_green}开始安装 nodejs...${reset}"
    $package_manager install -y nodejs
    echo -e "${yellow}nodejs 安装完成。${reset}"

    echo -e "${light_green}开始安装 pip...${reset}"
    $package_manager install -y python3-pip
    echo -e "${yellow}pip 安装完成。${reset}"

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
        pip_install_cmd="pip3.8 install"
    else
        # 使用sort命令和版本比较来决定使用哪个pip命令
        if printf '3.11\n%s' "$python_version" | sort -V | head -n1 | grep -q '3.11'; then
            echo -e "${highlight}Python3的版本是 $python_version, 使用pip install --break-system-packages来安装...${reset}"
            pip_install_cmd="pip3 install --break-system-packages"
        else
            echo -e "${highlight}Python3的版本是 $python_version, 使用标准pip install来安装...${reset}"
            pip_install_cmd="pip3 install"
        fi    
    fi
    
    if [ "$package_manager" != "apt" ]; then
        $package_manager install -y newt
    else
        $package_manager install -y whiptail
    fi
    
    # 使用whiptail创建菜单，让用户选择biliup版本
    VERSION_CHOICE=$(whiptail --title "选择 biliup 版本" --menu "选择您要安装的 biliup 版本:" 15 60 3 \
        "1" "安装最新版（webui）" \
        "2" "非webui版（0.4.31）" \
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
    PIP_INDEX_URL=$pip_source $pip_install_cmd $biliup_version quickjs
    
    echo -e "${blue}老版本基础微修，一键脚本原最新版${light_green}  ： https://image.biliup.me/install.sh ${reset}"
    echo -e "${green}一键脚本太好用了! 我要打赏${yellow} Biliup ${light_green}： https://afdian.net/a/biliup ${reset}"
    echo -e "${highlight}所有安装步骤完成！！${reset}"
    if [ "$package_manager" = "yum" ]; then
        scl enable rh-python38 bash
    fi
fi
