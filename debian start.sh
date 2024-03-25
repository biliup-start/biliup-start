#!/bin/bash

# 获取国家代码
country_code=$(curl -s https://ipinfo.io/country)

# 检查国家代码是否为 CN
if [ "$country_code" = "CN" ]; then
    url="https://j.iokun.top/https://"
    pipsource="https://pypi.tuna.tsinghua.edu.cn/simple"
else
    url="https://"
    pipsource="https://pypi.org/simple"
fi

# 定义颜色代码
green='\033[0;32m'
plain='\033[0m'
red='\e[31m'
yellow='\e[33m'

# 安装下载命令
install_biliup() {
    if [ ! -f "/opt/biliup/install.sh" ]; then
        sudo bash -c "wget -O /opt/biliup/install.sh https://image.biliup.me/install.sh && chmod +x /opt/biliup/install.sh && bash /opt/biliup/install.sh"
        echo -e "biliup完成：${green}安装命令已经运行${plain}"
    else
        echo -e "biliup完成：${green}安装命令已经存在${plain}"
    fi

    if ! find /opt/biliup/ -name "*-linux.tar.xz" -print -quit | grep -q .; then
        echo "你的CPU架构是："
        echo -e "    （${red}默认${plain}）0: ${yellow}x86_64${plain}"
        echo -e "            Y: ${green}ARMx64${plain}"
        echo -e "            N: ${green} ARM${plain}"
        read -p "请输入[0/Y/N]：" arch_choice
        if [[ -z "$arch_choice" || ! "$arch_choice" =~ [0-2] ]]; then
            arch_choice=0
        fi
        if [ "$arch_choice" -eq 0 ]; then
            cd /opt/biliup && wget ${url}github.com/biliup-rs/releases/download/v0.1.19/biliupR-v0.1.19-x86_64-linux.tar.xz && tar -xf biliupR-v0.1.19-x86_64-linux.tar.xz && mv "/opt/biliup/biliupR-v0.1.19-x86_64-linux/biliup" "/opt/biliup/biliupR"
        elif [ "$arch_choice" -eq 1 ]; then
            cd /opt/biliup && wget ${url}github.com/biliup/biliup-rs/releases/download/v0.1.19/biliupR-v0.1.19-aarch64-linux.tar.xz && tar -xf biliupR-v0.1.19-aarch64-linux.tar.xz && mv "/opt/biliup/biliupR-v0.1.19-aarch64-linux/biliup" "/opt/biliup/biliupR"
        else
            cd /opt/biliup && wget ${url}github.com/biliup/biliup-rs/releases/download/v0.1.19/biliupR-v0.1.19-arm-linux.tar.xz && tar -xf biliupR-v0.1.19-arm-linux.tar.xz && mv "/opt/biliup/biliupR-v0.1.19-arm-linux/biliup" "/opt/biliup/biliupR"
        fi
        echo -e "biliup-rs完成：${green}已经下载${plain}"
    else
        echo -e "biliup-rs完成：${green}已经存在${plain}"
    fi
}

# 检查/opt/biliup是否存在，如果不存在则创建
if [ ! -d "/opt/biliup" ]; then
    mkdir /opt/biliup
fi

echo -e "录播文件和日志储存在 ${green}/opt/biliup${plain}"

# 检查biliup是否正在运行
if pgrep -f "biliup" > /dev/null; then
    read -p "biliup 已安装 你希望重新安装biliup吗？[Y/N]："  rerun
    if [ -z "$rerun" ]; then
        rerun=0
    fi
    if [ "$rerun" = "y" ]; then
        pkill -f "biliup" ; rm -f "/opt/biliup/watch_process.pid" 
        echo -e "${green}已经杀死biliup程，将重新运行biliup${plain}"
        install_biliup
    else
        echo -e "${red}取消重新启动biliup${plain}"
        read -p "biliup 已运行 你希望新增一个biliup进程吗？[Y/N]："  addnew
        if [ "$addnew" = "y" ]; then
            pkill -f "biliup" ; rm -f "/opt/biliup/watch_process.pid" 
            echo -e "将${green}新增${plain}一个biliup进程"
        else
            echo -e "${red}退出脚本${plain}"
            exit 1
        fi
    fi
else
    install_biliup
fi

# 运行前置条件查询python版本
python_version=$(python3 --version | cut -d " " -f2)

# 使用sort命令和版本比较来决定使用哪个pip命令
if printf '3.11\n%s' "$version" | sort -V | head -n1 | grep -q '3.11'; then
    echo -e "Python3的版本是${yellow} $version ${plain}, 使用${green}pip install --break-system-packages${plain} 来安装..."
    pip_install_cmd="pip3 install -i $pipSource --break-system-packages"
    python3_install_cmd="-i $pipSource --break-system-packages"
else
    echo -e "Python3的版本是${yellow} $version ${plain}, 使用标准${green} pip install ${plain}来安装..."
    pip_install_cmd="pip3 install -i $pipSource"
    python3_install_cmd="-i $pipSource"
fi

echo -n "检查biliup版本中，请等待"
for i in {1..3}
do
    echo -n "."
    sleep 1
done
echo ""

# 检查pip3版本并获取biliup的官方版本
if ! pip3 --version &> /dev/null; then
    sudo apt-get update
    sudo apt-get install python3-pip
fi
if ! pip3 --version &> /dev/null; then
    curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" && sudo python3 "get-pip.py" $python3_install_cmd &&  rm -f "get-pip.py"
    echo -e "检测到只安装python3 已自动安装${green}最新版本pip3${plain}"   
else
    if [[ $(echo "$(pip3 --version | awk '{print $2}') 21.3" | awk '{print ($1 < $2)}') -ne 0 ]]; then
        official_version=$(pip search biliup | cut -d ' ' -f 2)
    else
        if [ -n "$(pip3 show yolk3k | grep Version | cut -d ' ' -f 2)" ]; then
            official_version=$(yolk -H "%pipsource%" -V biliup | cut -d ' ' -f 2)
        else    
            sudo $pip_install_cmd yolk3k
            source ~/.bashrc  # 更新你的 shell
            official_version=$(yolk -H "%pipsource%" -V biliup | cut -d ' ' -f 2)
        fi
    fi
fi

# 检查本地biliup版本
local_version=$(pip3 show biliup | grep Version | cut -d ' ' -f 2)
echo -e "本地版本：${green} $local_version ${plain}"
if [ -n "$official_version" ]; then
    echo -e "最新版本：${yellow} $official_version ${plain}"
else
    echo -e "最新版本：${red} 失败跳过更新检查 手动更新${yellow} sudo $pip_install_cmd -U biliup${plain}"
fi

# 如果本地版本和最新版本不一致，提示用户更新
if [ -n "$official_version" ] && [ "$local_version" != "$official_version" ]; then
    read -p "本地版本和库中最新版本不一致，你希望更新biliup吗？[Y/N]：" update_choice
    if [ -z "$update_choice" ]; then
        update_choice=y
    fi
    if [ "$update_choice" = "y" ]; then
        sudo $pip_install_cmd -U biliup
        echo -e "更新后的版本是：${green} $official_version ${plain}"
    else
        echo -e "最新库中的版本是：${green} $official_version ${plain}"
    fi
fi
    
# 登录biliup-rs
if [ ! -f "/opt/biliup/cookies.json" ]; then
    read -p "未登录B站（cookier.json不存在）推荐使用扫码登录，是否登录？[Y/N]：" choice
    if [ -z "$choice" ]; then
        choice=y
    fi
    if [ "$choice" = "y" ]; then
        sudo bash -c "/opt/biliup/biliupR login"
        if [ -f "/opt/biliup/cookies.json" ]; then
            echo -e "已从biliup-rs获取${yellow}cookie${red} 泄露会被盗登B站${plain}"
        else
            echo -e "未登录biliup-rs 请控制台手动执行 ${red}/opt/biliup/biliupR login${plain}"
        fi
    else
        echo -e "cookie是登录B站所需 如上传请控制台手动执行 ${red}/opt/biliup/biliupR login${plain}"
    fi
fi

# 禁用的端口列表
ForbiddenPorts="0 1 7 9 11 13 15 17 19 20 21 22 23 25 37 42 43 53 77 79 87 95 101 102 103 104 109 110 111 113 115 117 119 123 135 139 143 179 389 465 512 513 514 515 526 530 531 532 540 556 563 587 601 636 993 995 2049 3659 4045 6000 6665 6666 6667 6668 6669 137 139 445 593 1025 2745 3127 6129 3389"

# 互动输入端口
while true; do
    read -p  "请输入一个小于65535的端口(回车默认19159)： " UserPort
    if [ -z "$UserPort" ]; then
        UserPort=19159
        echo -e "你使用了默认端口 ${green}$UserPort ${plain}  等待进入下一步"
    fi
    if [[ $UserPort =~ ^[0-9]+$ ]] && [ $UserPort -le 65535 ]; then
        if [[ $ForbiddenPorts =~ (^|[[:space:]])$UserPort($|[[:space:]]) ]]; then
            echo "错误: 端口 $UserPort 被禁用，请重新输入。"
        elif lsof -i :$UserPort > /dev/null ; then
            echo "错误: 端口 $UserPort 已被占用，请重新输入。"
        else
            if [ $UserPort != 19159 ]; then
                echo -e "注意: 你选择的端口 ${yellow} $UserPort ${plain} 不是默认端口。如果你的防火墙设置阻止了该端口通信，请确保你已经在防火墙中打开了这个端口。"
            fi
            break
        fi
    else
        echo "错误: 你输入的不是有效的端口号，请重新输入。"
    fi
done

# 互动输入密码
while true; do
    read -r -p  "请输入密码(回车为不使用密码公网慎用）：" UserPassword
    if [ -z "$UserPassword" ]; then
        UserPassword=0
        break
    elif [[ "$UserPassword" =~ [$'\001'-$'\037'] ]]; then
        echo "错误: 你输入的密码包含无效的字符，请重新输入。"
    else
        echo -e "账号：${green} biliup ${plain} 密码：${yellow} $UserPassword ${plain}"
        break
    fi
done

# 定义函数来运行biliup命令
biliup_version=$(pip3 show biliup | grep Version | cut -d ' ' -f 2 | tr -d '.')
run_biliup() {
    if [[ $biliup_version -lt 0432 ]]; then
        read -p  "0.4.32以下 是否开启hhtp？回车默认开启[Y/N]：" rrun
        if [ -z "$rerun" ]; then
            rrun=y
        fi
        if [ "$rrun" = "y" ]; then
            echo -e "biliup v0.4.32以下 请到${red} /opt/biliup/config.toml ${plain}进行配置"
            curl -L "${url}raw.githubusercontent.com/biliup/biliup/master/public/config.toml" -o "/opt/biliup/config.toml"
            if [ "$UserPassword" = "0" ]; then
                sudo bash -c "cd /opt/biliup && biliup --http -P $UserPort start"
            else
                sudo bash -c "cd /opt/biliup && biliup --http -P $UserPort --password '$UserPassword' start"
            fi
        else
            echo -e "biliup v0.4.32以下 请到${red} /opt/biliup/config.toml ${plain}进行配置"
            curl -L "${url}raw.githubusercontent.com/biliup/biliup/master/public/config.toml" -o "/opt/biliup/config.toml"
            if [ "$UserPassword" = "0" ]; then
                sudo bash -c "cd /opt/biliup && biliup -P $UserPort start"
            else
                sudo bash -c "cd /opt/biliup && biliup -P $UserPort --password '$UserPassword' start"
            fi
        fi   
    else
        if [ "$UserPassword" = "0" ]; then
            sudo bash -c "cd /opt/biliup && biliup -P $UserPort start"
        else
            sudo bash -c "cd /opt/biliup && biliup -P $UserPort --password '$UserPassword' start"
        fi   
    fi
}

run_biliup

# 检查biliup是否正在运行
rm_biliup() {
    if [ -n "$(curl -s ipinfo.io/ip)" ]; then    
        echo -e "biliup已运行请至浏览器配置WEBUI  ${green}http://$(curl -s ipinfo.io/ip):$UserPort${plain}"
    else
        echo -e "biliup已运行请至浏览器配置WEBUI  ${green}http://[$(curl -s 6.ipw.cn)]:$UserPort${plain}"
    fi
    if [ -f "/opt/biliup/install.sh" ]
    then
        read -p  "你希望清理安装包吗？回车默认清理[Y/N]：" rerun
        if [ -z "$rerun" ]; then
            rerun=y
        fi
        if [ "$rerun" = "y" ]; then
            rm -f /opt/biliup/biliupR-v0.1.19-*-linux.tar.xz
            rm -rf /opt/biliup/biliupR-v0.1.19-*-linux
            rm -f /opt/biliup/install.sh 
            echo -e "${green}已清理安装包,biliu启动成功${plain}"
        fi
    fi
}

# 最后给用户一个提示
if pgrep -f "biliup" > /dev/null; then
    rm_biliup
else
    if [ -f "/opt/biliup/watch_process.pid" ]; then 
        rm -f "/opt/biliup/watch_process.pid" ; run_biliup
    else
        run_biliup
    fi
    if ! pgrep -f "biliup" > /dev/null; then
        echo $err_output
        echo -e "${red}真一键biliup出问题了，请在QQ群中反馈${plain}"
    else
        rm_biliup
    fi
fi
