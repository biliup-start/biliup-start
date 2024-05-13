@echo off

:inputDrive
echo ע�⣺�ýű�������������ٷ��޹�
echo ע�⣺�����������뿪���ߺȱ����� 
echo ע�⣺https://afdian.net/a/biliup
set UserDrive=
set /p UserDrive="����������¼�����̷���Ĭ��ΪC�̣���"
if "%UserDrive%"=="" (
    set UserDrive=C
)
echo %UserDrive%| findstr /R "^[a-zA-Z]$" > nul
if %errorlevel%==1 (
    echo ����: ������Ĳ��ǵ�����ĸ�����������롣
    goto inputDrive
)
if not exist %UserDrive%:\ (
    echo ����: δ�ҵ� %UserDrive%:\ �̣��뵽�ҵĵ����в鿴��ȷ�̷�
    goto inputDrive
)
set BILIUP_DIR=opt\biliup

netstat -aon | findstr /R /C:"^  TCP    [0-9.]*:19159 " >nul
if %errorlevel%==0 (
    echo ���Ѿ�������һ��biliup ��Ϊ������biliup
    set BILIUP_DIR=opt\biliup\%random%
)

if not exist %UserDrive%:\%BILIUP_DIR% (
    mkdir %UserDrive%:\%BILIUP_DIR%
)

cd %UserDrive%:\%BILIUP_DIR%
echo ��¼���ļ�����־�� %UserDrive%:\%BILIUP_DIR%
echo ��������������ļ� %UserDrive%:\%BILIUP_DIR%\ds_update.log

for /f %%b in ('curl -s https://ipinfo.io/country') do (
    set CountryCode=%%b
)
if "%CountryCode%"=="CN" (
    set biliupgithub=https://j.iokun.top/https://
    set pipsource=https://mirrors.cernet.edu.cn/pypi/web/simple
    echo ��� IP �������й���½����ʹ������Դ�ʹ������ء�
) else (
    set biliupgithub=https://
    set pipsource=https://pypi.org/simple
    echo ��� IP �����ز����ڵأ���ʹ�ùٷ�Դ��ֱ�����ء�
)
:: ��ȡ���°汾�汾��
for /f "tokens=2 delims= " %%i in ('curl -I -s %biliupgithub%github.com/biliup/biliup-rs/releases/latest/download/ ^| findstr /i location') do set "latest_url=%%i"
for /f "tokens=7 delims=/" %%a in ("%latest_url%") do set "biliuprs_version=%%a"

where python >nul 2>nul
if %errorlevel% neq 0 (
    echo δ��װ python
    goto end
)

echo ���biliup�汾...
for /f "tokens=2 delims= " %%i in ('pip show biliup ^| findstr Version') do set biliversion=%%i
for /f "delims=" %%a in ('pip index versions biliup') do (echo %%a | findstr "LATEST" >nul && set "line=%%a")
for /f "tokens=2" %%b in ("%line%") do set "pipversion=%%b"
for /f "tokens=2 delims= " %%i in ('python --version') do set pyversion=%%i

if not defined pipversion (
    echo �����а汾ʧ�� ��������ֶ��ն����� pip install -i "%pipsource%" -U biliup ...
    set pipversion=%biliversion%
) else (
    echo ��ǰ���°汾 v%pipversion%
)

if defined biliversion (

    echo ��ǰPython�汾: %pyversion%
    if "%pyversion:~0,3%" LSS "3.9" (
        echo Python�汾����Ҫ��,����ִ��.
    ) else (
        echo Python < 3.9 ���ֶ�����,�˳��ű�.
        exit /b
    )

    if exist "%UserDrive%:\opt\biliup\upgrade.txt" (
        if not "0.4.31" lss "%biliversion%" (
            goto end
        )
    ) 

    echo ��ѯ���п��ð汾 ����������...
    if not "%biliversion%" == "%pipversion%" (
        if "0.4.31" lss "%biliversion%" (
            choice /C YN /M "biliup�汾���ͣ��Ƿ���£�"
            if errorlevel 2 (
                echo. > "%UserDrive%:\opt\biliup\upgrade.txt"
            ) else (
                powershell -Command "Start-Process -FilePath 'pip' -ArgumentList 'install -i "%pipsource%" -U biliup' -Verb RunAs -Wait"
                for /f "tokens=2 delims= " %%i in ('pip show biliup ^| findstr Version') do set biliversion=%%i
            )
        ) 
    )
) 

:end
if not defined biliversion (
    echo δ���й��ű� ��ʼִ�а�װ

    if exist C:\ProgramData\chocolatey (
        powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c rmdir /s /q C:\ProgramData\chocolatey' -Verb RunAs"
        echo ɾ�� chocolatey �ɹ�
    )

    if not exist %UserDrive%:\opt\biliup\windowsbiliup.bat (
        echo �������� windowsbiliup.bat...
        powershell -Command "Invoke-WebRequest -Uri '%biliupgithub%github.com/ikun1993/biliupstart/releases/download/biliupstart/windowsbiliup.bat' -OutFile '%UserDrive%:\opt\biliup\windowsbiliup.bat'"
    )
    echo �Թ���Ա������� windowsbiliup.bat...
    powershell -Command "Start-Process -FilePath '%UserDrive%:\opt\biliup\windowsbiliup.bat' -Verb RunAs -Wait"
    choice /C YN /M "���Ƿ���ʹ�� webui �汾��"
    if errorlevel 2 (
        powershell -Command "Start-Process -FilePath 'pip' -ArgumentList 'install -i "%pipsource%" -U biliup==0.4.31' -Verb RunAs -Wait"
        for /f "tokens=2 delims= " %%i in ('pip show biliup ^| findstr Version') do set biliversion=%%i
        if not "%biliversion%" == "0.4.31" (
            echo �汾����ʧ�� ��������ֶ��ն����� pip install -U biliup==0.4.31 ...
        ) 
    ) 

    if not "%biliversion%" geq "0.4.51" (
        if not exist %UserDrive%:\opt\biliup\biliupR.exe (
            if not exist %UserDrive%:\opt\biliup\biliupR-%biliuprs_version%-x86_64-windows.zip (
                echo �������� biliupR-%biliuprs_version% -x86_64-windows.zip...
                powershell -Command "Invoke-WebRequest -Uri '%biliupgithub%github.com/biliup/biliup-rs/releases/latest/download/biliupR-%biliuprs_version%-x86_64-windows.zip' -OutFile '%UserDrive%:\opt\biliup\biliupR-%biliuprs_version%-x86_64-windows.zip'"
            )
            echo ���ڽ� biliupR-%biliuprs_version%-x86_64-windows.zip ��ѹ�� %UserDrive%:\%BILIUP_DIR%...
            powershell -Command "Expand-Archive -Path '%UserDrive%:\opt\biliup\biliupR-%biliuprs_version%-x86_64-windows.zip' -DestinationPath '%UserDrive%:\opt\biliup' -Force"
            powershell -Command "Move-Item -Path '%UserDrive%:\opt\biliup\biliupR-%biliuprs_version%-x86_64-windows\biliup.exe' -Destination '%UserDrive%:\opt\biliup\biliupR.exe'"
        )
    )

    if exist %UserDrive%:\opt\biliup\windowsbiliup.bat (
        powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c del %UserDrive%:\opt\biliup\windowsbiliup.bat' -Verb RunAs"
        echo ɾ�� windowsbiliup.bat�ɹ�
    )

    if exist %UserDrive%:\opt\biliup\biliupR-%biliuprs_version%-x86_64-windows.zip (
        powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c del %UserDrive%:\opt\biliup\biliupR-%biliuprs_version%-x86_64-windows.zip' -Verb RunAs"
        echo ɾ�� biliupR-%biliuprs_version%-x86_64-windows.zip�ɹ�
    )

    if exist %UserDrive%:\opt\biliup\biliupR-%biliuprs_version%-x86_64-windows (
        powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c rmdir /s /q %UserDrive%:\opt\biliup\biliupR-%biliuprs_version%-x86_64-windows' -Verb RunAs"
        echo ɾ�� biliupR-%biliuprs_version%-x86_64-windows Ŀ¼�ɹ�
    )
) else (
    if not "%biliversion%" == "%pipversion%" (
        echo �汾����в�һ�£���������ֶ��ն����� pip install -U biliup ...
    ) 
) 

for /f "tokens=2 delims= " %%i in ('pip show biliup ^| findstr Version') do set biliversion=%%i
echo ��ǰ���а汾 v%biliversion%

if not "%biliversion%" gtr "0.4.52" (
    echo ��� cookies.json �Ƿ���ڣ�Bվ�Ƿ��¼��...
    if not exist %UserDrive%:\opt\biliup\cookies.json (
        echo cookies.json ���������ڵ�¼Bվ���Ƽ�ɨ�룩...
        %UserDrive%:\opt\biliup\biliupR.exe login
    )
) else (
    echo 0.4.53�����Ͽ���WEBUI��ɨ���¼
    goto biliupR
)

if exist %UserDrive%:\opt\biliup\cookies.json (
    if exist %UserDrive%:\opt\biliup\qrcode.png (
        powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c del %UserDrive%:\opt\biliup\qrcode.png' -Verb RunAs"    
        echo ��¼�ɹ� ɾ����¼��ά��ͼƬ
    ) else (
        echo ��¼�ɹ��� cookies.json �ļ��Ѵ���
    )
) else (
    echo ��¼ʧ�� ����ն����� %UserDrive%:\opt\biliup\biliupR.exe login �ֶ���¼
)

:biliupR
setlocal enabledelayedexpansion
set "ForbiddenPorts=0 1 7 9 11 13 15 17 19 20 21 22 23 25 37 42 43 53 77 79 87 95 101 102 103 104 109 110 111 113 115 117 119 123 135 139 143 179 389 465 512 513 514 515 526 530 531 532 540 556 563 587 601 636 993 995 2049 3659 4045 6000 6665 6666 6667 6668 6669 137 139 445 593 1025 2745 3127 6129 3389"
:input
set UserInput=
set /p UserInput="������һ��С��65535�˿�(�س�Ĭ��19159)��"
if "%UserInput%"=="" (
    set UserInput=19159
)
echo %UserInput%| findstr /R "^[0-9][0-9]*$" > nul
if %errorlevel%==1 (
    echo ����: ������Ĳ������֣����������롣
    goto input
)
for %%i in (%ForbiddenPorts%) do (
    if %UserInput% equ %%i (
        echo ����: �˿� %UserInput% �����ã����������롣
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
    echo ����: ����������ֳ�����5λ�����������롣
    goto input
)
if %UserInput% GTR 65535 (
    echo ����: ����������ֳ�����65535�����������롣
    goto input
)
netstat -aon | findstr /R /C:"^  TCP    [0-9.]*:%UserInput% " >nul
if %errorlevel%==0 (
    echo ����: �˿� %UserInput% �ѱ�ռ�ã����������롣
    goto input
)
echo ������Ķ˿��� %UserInput%
set /p UserPassword="����������(�س���ʹ������)��"
echo ��������biliup ���гɹ�10����Զ�Ϊ������ö�...

set HTTP_FLAG=
if not "0.4.31" lss "%biliversion%" (
    set HTTP_FLAG=--http
    if not exist %UserDrive%:\opt\biliup\config.toml (
          echo ����config.toml �뵽 %UserDrive%:\%BILIUP_DIR% ��������config.toml
          powershell -Command "Invoke-WebRequest -Uri '%biliupgithub%raw.githubusercontent.com/biliup/biliup/master/public/config.toml' -OutFile '%UserDrive%:\opt\biliup\config.toml'"
    )
)

if "%UserPassword%"=="" (
    echo δ�������빫�����Ƽ� ��������biliup�豣�ֵ�ǰ���ڴ���
    start /B biliup -P %UserInput% %HTTP_FLAG% start
    timeout /t 11 /nobreak >nul
    start http://localhost:%UserInput%
) else (
    echo �˺ţ�biliup ���룺%UserPassword% ��������biliup�豣�ֵ�ǰ���ڴ���
    start /B biliup -P %UserInput% --password %UserPassword% %HTTP_FLAG% start
    timeout /t 11 /nobreak >nul
    start http://localhost:%UserInput%
)
