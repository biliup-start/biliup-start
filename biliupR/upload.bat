@echo off
setlocal enabledelayedexpansion

:: 获取国家代码
for /f "tokens=* USEBACKQ" %%F in (`curl -s https://ipinfo.io/country`) do (
    set "country_code=%%F"
)
if "%country_code%"=="CN" (
    set biliupgithub=https://j.iokun.top/https://
    set line=
) else (
    set biliupgithub=https://
    set line=--line ws
 )

:: 获取最新版本版本号
for /f "tokens=2 delims= " %%i in ('curl -I -s %biliupgithub%github.com/biliup/biliup-rs/releases/latest/download/ ^| findstr /i location') do set "latest_url=%%i"

:: 从链接中提取版本号
for /f "tokens=7 delims=/" %%a in ("%latest_url%") do set "biliuprs_version=%%a"

:: 定义目录和允许的文件类型
set BILIUP_DIR=C:\opt\biliup
set ALLOWED_TYPES=mp4 flv avi wmv mov webm mpeg4 ts mpg rm rmvb mkv

if not exist C:\opt\biliup\biliupR.exe (
    mkdir C:\opt\biliup
    powershell -Command "Invoke-WebRequest -Uri '%biliupgithub%github.com/biliup/biliup-rs/releases/latest/download/biliupR-%biliuprs_version%-x86_64-windows.zip' -OutFile '%BILIUP_DIR%\biliupR-%biliuprs_version%-x86_64-windows.zip'"

    echo 正在将 biliupR-%biliuprs_version%-x86_64-windows.zip 解压到 %BILIUP_DIR% ...
    powershell -Command "Expand-Archive -Path '%BILIUP_DIR%\biliupR-%biliuprs_version%-x86_64-windows.zip' -DestinationPath 'C:\opt\biliup' -Force"
    powershell -Command "Move-Item -Path '%BILIUP_DIR%\biliupR-%biliuprs_version%-x86_64-windows\biliup.exe' -Destination 'C:\opt\biliup\biliupR.exe'"

    if exist %BILIUP_DIR%\biliupR-%biliuprs_version%-x86_64-windows.zip (
        echo C:\opt\biliup\biliupR.exe安装成功 删除 biliupR-%biliuprs_version%-x86_64-windows.zip
        powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c del %BILIUP_DIR%\biliupR-%biliuprs_version%-x86_64-windows.zip' -Verb RunAs"
        powershell -Command "Start-Process -FilePath 'powershell' -ArgumentList '/c Remove-Item -Recurse -Force %BILIUP_DIR%\biliupR-%biliuprs_version%-x86_64-windows' -Wait -Verb RunAs"
    )
)

:: 获取用户输入的操作类型，如果不是1（追加），则默认为0（上传）
set /p OPERATION_TYPE="根据情况选择0:上传 1:追加投稿[0/1]: "
if not "%OPERATION_TYPE%"=="0" if not "%OPERATION_TYPE%"=="1" (
    set OPERATION_TYPE=0
    echo 输入错误，自动选择 0:上传
) else (
    if "%OPERATION_TYPE%"=="1" (
        echo 选择了 %OPERATION_TYPE%:追加投稿
    ) else (
        echo 选择了 %OPERATION_TYPE%:上传
    )
)

:: 获取用户输入的文件类型并检查是否在允许的类型中
:file_type_loop
set /p FILE_TYPE="请输入视频格式（例如：flv）: "
set FOUND=0
for %%t in (%ALLOWED_TYPES%) do (
    if /I "%%t"=="%FILE_TYPE%" (
        set FOUND=1
        goto end_loop
    )
)
:end_loop
if %FOUND%==0 goto file_type_loop

:: 获取用户输入的需要上传文件的目录
:directory_loop
set /p OUTPUT_BASE="输入上传文件的目录（例如：C:\）: "
if not exist "%OUTPUT_BASE%" goto directory_loop

:: 查找指定目录中所有符合输入文件类型的文件
set file_count=0
for %%G in ("%OUTPUT_BASE%\\*.%FILE_TYPE%") do (
    set /A file_count+=1
    set files=!files! "%%~G"
)

:: 检查是否找到了文件
if not defined files (
    echo 没有找到文件
    goto directory_loop
)

:: 根据操作类型上传文件或追加到现有视频
echo 上传 %file_count% 个文件
cd %BILIUP_DIR%

if not exist "%BILIUP_DIR%\cookies.json" (
    echo 你没有登录或者cookies不存在
    %BILIUP_DIR%\biliupR.exe login
)

if "%OPERATION_TYPE%"=="0" (
    :inputTag
    set /p UPLOAD_TAG="请输入上传标签（多个标签逗号,隔开）: "
    if defined UPLOAD_TAG (
        set UPLOAD_TAG=%UPLOAD_TAG:，=,%
        echo %UPLOAD_TAG% | findstr /r ",," >nul
        if %errorlevel% equ 0 (
            echo 输入错误，不能连续输入多个逗号,隔开
            goto inputTag
        )
        echo 您输入的标签 %UPLOAD_TAG%
    ) else (
        set UPLOAD_TAG=biliup
        echo 未输入默认 biliup 标签
    )

    .\biliupR.exe upload !files! --tag !UPLOAD_TAG! !line! --limit !file_count!
) else (
    :bv_number_loop
    set /p OPERATIONFILE_TYPE="请输入追加稿件的BV号（例如：BV1fr42147Re）: "
    if not defined OPERATIONFILE_TYPE goto bv_number_loop
    echo %OPERATIONFILE_TYPE% | findstr /R "^BV[a-zA-Z0-9]*$" >nul 2>&1
    if not errorlevel 1 (
        goto bv_number_loop
    ) else (
    .\biliupR.exe upload !files! --tag !UPLOAD_TAG! !line! --limit !file_count!
    )
)

:: 定义退出脚本的子程序
:exit_script
echo 运行结束按任意键退出...
pause >nul
exit /b
