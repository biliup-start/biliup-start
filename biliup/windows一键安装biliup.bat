@echo off
:: Step 1: 安装 Chocolatey
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

:: Step 2: 使用 Chocolatey 安装 ffmpeg
choco install ffmpeg -y

:: Step 3: 使用 Chocolatey 安装 Python 3.10
choco install python310 -y

:: Step 4: 添加 Python 路径到系统环境变量
setx PATH "%PATH%;C:\Python310\Scripts\;C:\Python310\"

:: Step 5: 检测 IP 归属地并安装 biliup
setlocal

REM 获取本机IP归属地
for /f %%b in ('curl -s https://ipinfo.io/country') do (
    set CountryCode=%%b
)
echo IP归属地: "%CountryCode%"
:: 判断 IP 归属地是否为中国
if "%CountryCode%"=="CN" (
    echo 你的 IP 归属地是中国，将使用清华源安装 biliup。
    pip install -i https://pypi.tuna.tsinghua.edu.cn/simple biliup
) else (
    echo 你的 IP 归属地不是中国，将使用默认源安装 biliup。
    pip install biliup
)


endlocal
:: 输出完成信息
echo 已完成全部安装
