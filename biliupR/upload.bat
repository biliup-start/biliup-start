@echo off
setlocal enabledelayedexpansion

:: ��ȡ���Ҵ���
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

:: ��ȡ���°汾�汾��
for /f "tokens=2 delims= " %%i in ('curl -I -s %biliupgithub%github.com/biliup/biliup-rs/releases/latest/download/ ^| findstr /i location') do set "latest_url=%%i"

:: ����������ȡ�汾��
for /f "tokens=7 delims=/" %%a in ("%latest_url%") do set "biliuprs_version=%%a"

:: ����Ŀ¼��������ļ�����
set BILIUP_DIR=C:\opt\biliup
set ALLOWED_TYPES=mp4 flv avi wmv mov webm mpeg4 ts mpg rm rmvb mkv

if not exist C:\opt\biliup\biliupR.exe (
    mkdir C:\opt\biliup
    powershell -Command "Invoke-WebRequest -Uri '%biliupgithub%github.com/biliup/biliup-rs/releases/latest/download/biliupR-%biliuprs_version%-x86_64-windows.zip' -OutFile '%BILIUP_DIR%\biliupR-%biliuprs_version%-x86_64-windows.zip'"

    echo ���ڽ� biliupR-%biliuprs_version%-x86_64-windows.zip ��ѹ�� %BILIUP_DIR% ...
    powershell -Command "Expand-Archive -Path '%BILIUP_DIR%\biliupR-%biliuprs_version%-x86_64-windows.zip' -DestinationPath 'C:\opt\biliup' -Force"
    powershell -Command "Move-Item -Path '%BILIUP_DIR%\biliupR-%biliuprs_version%-x86_64-windows\biliup.exe' -Destination 'C:\opt\biliup\biliupR.exe'"

    if exist %BILIUP_DIR%\biliupR-%biliuprs_version%-x86_64-windows.zip (
        echo C:\opt\biliup\biliupR.exe��װ�ɹ� ɾ�� biliupR-%biliuprs_version%-x86_64-windows.zip
        powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c del %BILIUP_DIR%\biliupR-%biliuprs_version%-x86_64-windows.zip' -Verb RunAs"
        powershell -Command "Start-Process -FilePath 'powershell' -ArgumentList '/c Remove-Item -Recurse -Force %BILIUP_DIR%\biliupR-%biliuprs_version%-x86_64-windows' -Wait -Verb RunAs"
    )
)

:: ��ȡ�û�����Ĳ������ͣ��������1��׷�ӣ�����Ĭ��Ϊ0���ϴ���
set /p OPERATION_TYPE="�������ѡ��0:�ϴ� 1:׷��Ͷ��[0/1]: "
if not "%OPERATION_TYPE%"=="0" if not "%OPERATION_TYPE%"=="1" (
    set OPERATION_TYPE=0
    echo ��������Զ�ѡ�� 0:�ϴ�
) else (
    if "%OPERATION_TYPE%"=="1" (
        echo ѡ���� %OPERATION_TYPE%:׷��Ͷ��
    ) else (
        echo ѡ���� %OPERATION_TYPE%:�ϴ�
    )
)

:: ��ȡ�û�������ļ����Ͳ�����Ƿ��������������
:file_type_loop
set /p FILE_TYPE="��������Ƶ��ʽ�����磺flv��: "
set FOUND=0
for %%t in (%ALLOWED_TYPES%) do (
    if /I "%%t"=="%FILE_TYPE%" (
        set FOUND=1
        goto end_loop
    )
)
:end_loop
if %FOUND%==0 goto file_type_loop

:: ��ȡ�û��������Ҫ�ϴ��ļ���Ŀ¼
:directory_loop
set /p OUTPUT_BASE="�����ϴ��ļ���Ŀ¼�����磺C:\��: "
if not exist "%OUTPUT_BASE%" goto directory_loop

:: ����ָ��Ŀ¼�����з��������ļ����͵��ļ�
set file_count=0
for %%G in ("%OUTPUT_BASE%\\*.%FILE_TYPE%") do (
    set /A file_count+=1
    set files=!files! "%%~G"
)

:: ����Ƿ��ҵ����ļ�
if not defined files (
    echo û���ҵ��ļ�
    goto directory_loop
)

:: ���ݲ��������ϴ��ļ���׷�ӵ�������Ƶ
echo �ϴ� %file_count% ���ļ�
cd %BILIUP_DIR%

if not exist "%BILIUP_DIR%\cookies.json" (
    echo ��û�е�¼����cookies������
    %BILIUP_DIR%\biliupR.exe login
)

if "%OPERATION_TYPE%"=="0" (
    :inputTag
    set /p UPLOAD_TAG="�������ϴ���ǩ�������ǩ����,������: "
    if defined UPLOAD_TAG (
        set UPLOAD_TAG=%UPLOAD_TAG:��=,%
        echo %UPLOAD_TAG% | findstr /r ",," >nul
        if %errorlevel% equ 0 (
            echo ������󣬲�����������������,����
            goto inputTag
        )
        echo ������ı�ǩ %UPLOAD_TAG%
    ) else (
        set UPLOAD_TAG=biliup
        echo δ����Ĭ�� biliup ��ǩ
    )

    .\biliupR.exe upload !files! --tag !UPLOAD_TAG! !line! --limit !file_count!
) else (
    :bv_number_loop
    set /p OPERATIONFILE_TYPE="������׷�Ӹ����BV�ţ����磺BV1fr42147Re��: "
    if not defined OPERATIONFILE_TYPE goto bv_number_loop
    echo %OPERATIONFILE_TYPE% | findstr /R "^BV[a-zA-Z0-9]*$" >nul 2>&1
    if not errorlevel 1 (
        goto bv_number_loop
    ) else (
    .\biliupR.exe upload !files! --tag !UPLOAD_TAG! !line! --limit !file_count!
    )
)

:: �����˳��ű����ӳ���
:exit_script
echo ���н�����������˳�...
pause >nul
exit /b
