@echo off

:: 发送运行次数到后端服务器
set backend_url=https://run.biliup.me/update_run_count
powershell -Command "Invoke-RestMethod -Uri %backend_url% -Method POST -Body @{run_count=1}"

:: 请求 Flask 获取运行次数
set get_run_count_url=https://run.biliup.me/get_run_count
for /f "delims=" %%i in ('powershell -Command "(Invoke-RestMethod -Uri %get_run_count_url%).run_count"') do set run_count=%%i

:: 输出到终端
echo 一键脚本已运行 %run_count% 次

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

:: 判断 IP 归属地是否为中国
for /f %%b in ('curl -s https://ipinfo.io/country') do (
    set CountryCode=%%b
)
echo IP归属地: %CountryCode%
if "%CountryCode%"=="CN" (
    set pipSource="https://mirrors.cernet.edu.cn/pypi/web/simple"
    echo 你的 IP 归属地是中国，将使用三方源安装 Python 库。
) else (
    set pipSource="https://pypi.org/simple"
    echo 你的 IP 归属地不是中国，将使用默认源安装 Python 库。
)

::  安装 biliup
pip install -i "%pipSource%" biliup

endlocal
::  输出完成信息
echo 已完成全部安装
