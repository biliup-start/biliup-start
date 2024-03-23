@echo off

:inputDrive
set UserDrive=
set /p UserDrive="请输入你录播的盘符（默认为C盘）："
if "%UserDrive%"=="" (
    set UserDrive=C
)
echo %UserDrive%| findstr /R "^[a-zA-Z]*$" > nul
if %errorlevel%==1 (
    echo 错误: 你输入的不是字母，请重新输入。
    goto inputDrive
)
if not exist %UserDrive%:\ (
    echo 错误: 没有找到你选择的 %UserDrive%盘 请到我的电脑中查看正确盘符
    goto inputDrive
)
echo 你录播文件和日志在 %UserDrive%:\opt\biliup

where python >nul 2>nul
if %errorlevel% neq 0 (
    echo 未安装 python
    set biliversion=未安装biliup
    set pipversion=未安装python
    goto end
)

echo 检查biliup版本...
for /f "tokens=2 delims= " %%i in ('pip3 show biliup ^| findstr Version') do set biliversion=%%i
for /f "tokens=2 delims= " %%i in ('yolk -V biliup 2^>nul') do set pipversion=%%i

if not defined pipversion (
    echo 查询最新版本失败，正在尝试安装 yolk3k...
    powershell -Command "Start-Process -FilePath 'pip3' -ArgumentList 'install yolk3k' -Verb RunAs -Wait"
    for /f "tokens=2 delims= " %%i in ('yolk -V biliup 2^>nul') do set pipversion=%%i
    if not defined pipversion (
        echo 安装 yolk3k失败  跳过自动更新 手动更新终端如数 pip3 install -U biliup ...
        set pipversion=%biliversion%
    )
) 

if "%pipversion%"=="%biliversion%" (
    echo 当前运行版本 v%biliversion%
) else (
    echo 当前最新版本 v%pipversion%
)

:end
if not defined biliversion (
    echo 未运行过脚本 开始执行安装
    echo 正在创建运行目录 %UserDrive%:\opt\biliup...
    mkdir %UserDrive%:\opt\biliup

    echo 删除可能存在的 chocolatey 目录...
    if exist C:\opt\biliup\biliupR-v0.1.19-x86_64-windows (
        powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c rmdir /s /q C:\ProgramData\chocolatey' -Verb RunAs"
        echo 删除 biliupR-v0.1.19-x86_64-windows 目录成功
    )

    echo 检查 windowsbiliup.bat 是否存在 如存在进行下一步...
    if not exist %~dp0\windowsbiliup.bat (
        echo 正在下载 windowsbiliup.bat...
        powershell -Command "Invoke-WebRequest -Uri 'https://blrec.iokun.top/d/189/windowsbiliup.bat?sign=WFofEtv2yAG3tO4WvAJCaWiLzHx1elLMdTMCPkP_y70=:0' -OutFile 'windowsbiliup.bat'"
    )

    echo 以管理员身份运行 windowsbiliup.bat...
    powershell -Command "Start-Process -FilePath 'windowsbiliup.bat' -Verb RunAs -Wait"

    echo 检查 biliupR-v0.1.19-x86_64-windows.zip 是否存在 如存在进行下一步...
    if not exist %~dp0\biliupR-v0.1.19-x86_64-windows.zip (
        echo 正在下载 biliupR-v0.1.19-x86_64-windows.zip...
        powershell -Command "Invoke-WebRequest -Uri 'https://j.iokun.top/https://github.com/biliup/biliup-rs/releases/download/v0.1.19/biliupR-v0.1.19-x86_64-windows.zip' -OutFile 'biliupR-v0.1.19-x86_64-windows.zip'"
    )

    echo 正在将 biliupR-v0.1.19-x86_64-windows.zip 解压到 %UserDrive%:\opt\biliup...
    powershell -Command "Expand-Archive -Path '%~dp0\biliupR-v0.1.19-x86_64-windows.zip' -DestinationPath '%UserDrive%:\opt\biliup' -Force"
    powershell -Command "Move-Item -Path '%UserDrive%:\opt\biliup\biliupR-v0.1.19-x86_64-windows\biliup.exe' -Destination '%UserDrive%:\opt\biliup\biliupR.exe'"

    echo 删除可能存在的 windowsbiliup.bat...
    if exist %~dp0\windowsbiliup.bat (
        powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c del %~dp0\windowsbiliup.bat' -Verb RunAs"
        echo 删除 windowsbiliup.bat成功
    )

    echo 删除可能存在的 biliupR-v0.1.19-x86_64-windows.zip...
    if exist %~dp0\biliupR-v0.1.19-x86_64-windows.zip (
        powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c del %~dp0\biliupR-v0.1.19-x86_64-windows.zip' -Verb RunAs"
        echo 删除 biliupR-v0.1.19-x86_64-windows.zip成功
    )

    echo 删除可能存在的 biliupR-v0.1.19-x86_64-windows 目录...
    if exist %UserDrive%:\opt\biliup\biliupR-v0.1.19-x86_64-windows (
        powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c rmdir /s /q %UserDrive%:\opt\biliup\biliupR-v0.1.19-x86_64-windows' -Verb RunAs"
        echo 删除 biliupR-v0.1.19-x86_64-windows 目录成功
    )
)
echo 查询库中可用版本 如最新跳过...
if not "%pipversion%"=="%biliversion%" (
    set /p UserUpdate="biliup版本过低，强制更新? [如不需要请关闭停用脚本]："
    if "%UserUpdate%"=="" (
        powershell -Command "Start-Process -FilePath 'pip3' -ArgumentList 'install -U biliup' -Verb RunAs -Wait"
        echo 已更新到版本 v%pipversion% 
    ) else (
        echo 更新失败 v%pipversion% ，请手动更新
    )
) 

echo 检查 cookies.json 是否存在（B站是否登录）...
if not exist %UserDrive%:\opt\biliup\cookies.json (
    echo cookies.json 不存在正在登录B站（推荐扫码）...
    cd %UserDrive%:\opt\biliup
    .\biliupR.exe login
)

timeout /t 3 /nobreak >nul

if exist %UserDrive%:\opt\biliup\cookies.json (
    if exist %UserDrive%:\opt\biliup\qrcode.png (
        powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c del %UserDrive%:\opt\biliup\qrcode.png' -Verb RunAs"    
        echo 登录成功 删除登录二维码图片
    )else (
        echo 登录成功或 cookies.json 文件已存在
    )
) else (
    echo 登录失败 请打开终端输入 %UserDrive%:\opt\biliup\biliupR.exe login 手动登录
)

timeout /t 5 /nobreak >nul

setlocal enabledelayedexpansion
set "ForbiddenPorts=0 1 7 9 11 13 15 17 19 20 21 22 23 25 37 42 43 53 77 79 87 95 101 102 103 104 109 110 111 113 115 117 119 123 135 139 143 179 389 465 512 513 514 515 526 530 531 532 540 556 563 587 601 636 993 995 2049 3659 4045 6000 6665 6666 6667 6668 6669 137 139 445 593 1025 2745 3127 6129 3389"
:input
set UserInput=
set /p UserInput="请输入一个小于65535端口(回车默认19159)："
if "%UserInput%"=="" (
    set UserInput=19159
)
echo %UserInput%| findstr /R "^[0-9][0-9]*$" > nul
if %errorlevel%==1 (
    echo 错误: 你输入的不是数字，请重新输入。
    goto input
)
for %%i in (%ForbiddenPorts%) do (
    if %UserInput% equ %%i (
        echo 错误: 端口 %UserInput% 被禁用，请重新输入。
        goto input
    )
)
set num=%UserInput%
set len=0
:loop
if defined num (
    set /A len+=1
    set num=%num:~1%
    goto loop
)
if %len% GTR 5 (
    echo 错误: 你输入的数字超过了5位，请重新输入。
    goto input
)
if %UserInput% GTR 65535 (
    echo 错误: 你输入的数字超过了65535，请重新输入。
    goto input
)
netstat -aon | findstr /R /C:"^  TCP    [0-9.]*:%UserInput% " >nul
if %errorlevel%==0 (
    echo 错误: 端口 %UserInput% 已被占用，请重新输入。
    goto input
)
echo 你输入的端口是 %UserInput%

set /p UserPassword="请输入密码(回车不使用密码)："
if "%UserPassword%"=="" (
    echo 未启用密码公网不推荐 持续运行biliup需保持当前窗口存在
)

echo 正在启动biliup 运行成功后10秒自动为你打开webui配置端...
cd %UserDrive%:\opt\biliup
if "%UserPassword%"=="" (
    start /B biliup -P %UserInput% start
    timeout /t 11 /nobreak >nul
    start http://localhost:%UserInput%
) else (
    echo 账号：biliup 密码：%UserPassword% 持续运行biliup需保持当前窗口存在
    start /B biliup -P %UserInput% --password %UserPassword% start
    timeout /t 11 /nobreak >nul
    start http://localhost:%UserInput%
)
