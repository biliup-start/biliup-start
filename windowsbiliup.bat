@echo off
:: Step 1: 安装 Chocolatey
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

:: Step 2: 使用 Chocolatey 安装 ffmpeg
choco install ffmpeg -y

:: Step 3: 使用 Chocolatey 安装 Python 3.10
choco install python310 -y

:: Step 4: 添加 Python 路径到系统环境变量
setx PATH "%PATH%;C:\Python310\Scripts\;C:\Python310\" /M

:: Step 5: 检测 IP 归属地并安装 biliup
setlocal

REM 获取本机IP归属地
for /f %%b in ('curl -s https://ipinfo.io/country') do (
    set CountryCode=%%b
)
for /f "tokens=2 delims= " %%i in ('yolk -V biliup 2^>nul') do set pipversion=%%i

if not defined pipversion (
    echo 查询最新版本失败，正在尝试安装 yolk3k...
    powershell -Command "Start-Process -FilePath 'pip3' -ArgumentList 'install yolk3k' -Verb RunAs -Wait"
    for /f "tokens=2 delims= " %%i in ('yolk -V biliup 2^>nul') do set pipversion=%%i
    if not defined pipversion (
        echo 检查库中版本失败 如需更新手动终端输入 pip3 install -U biliup ...
        set pipversion=0.4.44
    )
) 
echo IP归属地: "%CountryCode%"
:: 判断 IP 归属地是否为中国
if "%CountryCode%"=="CN" (
    echo 你的 IP 归属地是中国，将使用清华源安装 biliup。
    pip install -i https://pypi.tuna.tsinghua.edu.cn/simple biliup==%pipversion%
) else (
    echo 你的 IP 归属地不是中国，将使用默认源安装 biliup。
    pip install biliup==%pipversion%
)
