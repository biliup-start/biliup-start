@echo off
setlocal enabledelayedexpansion

::  定义目录，biliupR和视频文件目录
set BILIUP_DIR=C:\opt\biliup
set OUTPUT_BASE=C:\Users\94623\Videos

::  获取国家代码
for /f "tokens=* USEBACKQ" %%F in (`curl -s https://ipinfo.io/country`) do (
    set "country_code=%%F"
)

::  检查国家代码是否为 CN
if "%country_code%"=="CN" (
    set "url=qn"
) else (
    set "url=ws"
)

::  创建一个空字符串来存储文件路径
set files=

::  查找所有符合条件的文件，并将它们的路径添加到字符串中
for /R "%OUTPUT_BASE%" %%G in (*.mp4) do (
    set files=!files! "%%G"
)

::  检查是否找到了文件
if not defined files (
    echo 没有找到文件
    pause
    exit /b
)

::  计算文件数量
set file_count=0
for %%A in (!files!) do (
    set /a file_count+=1
)

::  显示文件数量并上传文件
echo 准备上传 !file_count! 个文件
"%BILIUP_DIR%/biliupR" upload !files! --tag biliup --line %url% --limit 999

pause
cmd.exe
