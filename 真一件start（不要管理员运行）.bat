@echo off

:inputDrive
set UserDrive=
set /p UserDrive="����������¼�����̷���Ĭ��ΪC�̣���"
if "%UserDrive%"=="" (
    set UserDrive=C
)
echo %UserDrive%| findstr /R "^[a-zA-Z]*$" > nul
if %errorlevel%==1 (
    echo ����: ������Ĳ�����ĸ�����������롣
    goto inputDrive
)
if not exist %UserDrive%:\ (
    echo ����: û���ҵ���ѡ��� %UserDrive%�� �뵽�ҵĵ����в鿴��ȷ�̷�
    goto inputDrive
)
echo ��¼���ļ�����־�� %UserDrive%:\opt\biliup

where python >nul 2>nul
if %errorlevel% neq 0 (
    echo δ��װ python
    set biliversion=δ��װbiliup
    set pipversion=δ��װpython
    goto end
)

echo ���biliup�汾...
for /f "tokens=2 delims= " %%i in ('pip3 show biliup ^| findstr Version') do set biliversion=%%i
for /f "tokens=2 delims= " %%i in ('yolk -V biliup 2^>nul') do set pipversion=%%i

if not defined pipversion (
    echo ��ѯ���°汾ʧ�ܣ����ڳ��԰�װ yolk3k...
    powershell -Command "Start-Process -FilePath 'pip3' -ArgumentList 'install yolk3k' -Verb RunAs -Wait"
    for /f "tokens=2 delims= " %%i in ('yolk -V biliup 2^>nul') do set pipversion=%%i
    if not defined pipversion (
        echo ��װ yolk3kʧ��  �����Զ����� �ֶ������ն����� pip3 install -U biliup ...
        set pipversion=%biliversion%
    )
) 

if "%pipversion%"=="%biliversion%" (
    echo ��ǰ���а汾 v%biliversion%
) else (
    echo ��ǰ���°汾 v%pipversion%
)

:end
if not defined biliversion (
    echo δ���й��ű� ��ʼִ�а�װ
    echo ���ڴ�������Ŀ¼ %UserDrive%:\opt\biliup...
    mkdir %UserDrive%:\opt\biliup

    echo ɾ�����ܴ��ڵ� chocolatey Ŀ¼...
    if exist C:\opt\biliup\biliupR-v0.1.19-x86_64-windows (
        powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c rmdir /s /q C:\ProgramData\chocolatey' -Verb RunAs"
        echo ɾ�� biliupR-v0.1.19-x86_64-windows Ŀ¼�ɹ�
    )

    echo ��� windowsbiliup.bat �Ƿ���� ����ڽ�����һ��...
    if not exist %~dp0\windowsbiliup.bat (
        echo �������� windowsbiliup.bat...
        powershell -Command "Invoke-WebRequest -Uri 'https://blrec.iokun.top/d/189/windowsbiliup.bat?sign=WFofEtv2yAG3tO4WvAJCaWiLzHx1elLMdTMCPkP_y70=:0' -OutFile 'windowsbiliup.bat'"
    )

    echo �Թ���Ա������� windowsbiliup.bat...
    powershell -Command "Start-Process -FilePath 'windowsbiliup.bat' -Verb RunAs -Wait"

    echo ��� biliupR-v0.1.19-x86_64-windows.zip �Ƿ���� ����ڽ�����һ��...
    if not exist %~dp0\biliupR-v0.1.19-x86_64-windows.zip (
        echo �������� biliupR-v0.1.19-x86_64-windows.zip...
        powershell -Command "Invoke-WebRequest -Uri 'https://j.iokun.top/https://github.com/biliup/biliup-rs/releases/download/v0.1.19/biliupR-v0.1.19-x86_64-windows.zip' -OutFile 'biliupR-v0.1.19-x86_64-windows.zip'"
    )

    echo ���ڽ� biliupR-v0.1.19-x86_64-windows.zip ��ѹ�� %UserDrive%:\opt\biliup...
    powershell -Command "Expand-Archive -Path '%~dp0\biliupR-v0.1.19-x86_64-windows.zip' -DestinationPath '%UserDrive%:\opt\biliup' -Force"
    powershell -Command "Move-Item -Path '%UserDrive%:\opt\biliup\biliupR-v0.1.19-x86_64-windows\biliup.exe' -Destination '%UserDrive%:\opt\biliup\biliupR.exe'"

    echo ɾ�����ܴ��ڵ� windowsbiliup.bat...
    if exist %~dp0\windowsbiliup.bat (
        powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c del %~dp0\windowsbiliup.bat' -Verb RunAs"
        echo ɾ�� windowsbiliup.bat�ɹ�
    )

    echo ɾ�����ܴ��ڵ� biliupR-v0.1.19-x86_64-windows.zip...
    if exist %~dp0\biliupR-v0.1.19-x86_64-windows.zip (
        powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c del %~dp0\biliupR-v0.1.19-x86_64-windows.zip' -Verb RunAs"
        echo ɾ�� biliupR-v0.1.19-x86_64-windows.zip�ɹ�
    )

    echo ɾ�����ܴ��ڵ� biliupR-v0.1.19-x86_64-windows Ŀ¼...
    if exist %UserDrive%:\opt\biliup\biliupR-v0.1.19-x86_64-windows (
        powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c rmdir /s /q %UserDrive%:\opt\biliup\biliupR-v0.1.19-x86_64-windows' -Verb RunAs"
        echo ɾ�� biliupR-v0.1.19-x86_64-windows Ŀ¼�ɹ�
    )
)
echo ��ѯ���п��ð汾 ����������...
if not "%pipversion%"=="%biliversion%" (
    set /p UserUpdate="biliup�汾���ͣ�ǿ�Ƹ���? [�粻��Ҫ��ر�ͣ�ýű�]��"
    if "%UserUpdate%"=="" (
        powershell -Command "Start-Process -FilePath 'pip3' -ArgumentList 'install -U biliup' -Verb RunAs -Wait"
        echo �Ѹ��µ��汾 v%pipversion% 
    ) else (
        echo ����ʧ�� v%pipversion% �����ֶ�����
    )
) 

echo ��� cookies.json �Ƿ���ڣ�Bվ�Ƿ��¼��...
if not exist %UserDrive%:\opt\biliup\cookies.json (
    echo cookies.json ���������ڵ�¼Bվ���Ƽ�ɨ�룩...
    cd %UserDrive%:\opt\biliup
    .\biliupR.exe login
)

timeout /t 3 /nobreak >nul

if exist %UserDrive%:\opt\biliup\cookies.json (
    if exist %UserDrive%:\opt\biliup\qrcode.png (
        powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c del %UserDrive%:\opt\biliup\qrcode.png' -Verb RunAs"    
        echo ��¼�ɹ� ɾ����¼��ά��ͼƬ
    )else (
        echo ��¼�ɹ��� cookies.json �ļ��Ѵ���
    )
) else (
    echo ��¼ʧ�� ����ն����� %UserDrive%:\opt\biliup\biliupR.exe login �ֶ���¼
)

timeout /t 5 /nobreak >nul

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
if "%UserPassword%"=="" (
    echo δ�������빫�����Ƽ� ��������biliup�豣�ֵ�ǰ���ڴ���
)

echo ��������biliup ���гɹ���10���Զ�Ϊ���webui���ö�...
cd %UserDrive%:\opt\biliup
if "%UserPassword%"=="" (
    start /B biliup -P %UserInput% restart
    timeout /t 11 /nobreak >nul
    start http://localhost:%UserInput%
) else (
    echo �˺ţ�biliup ���룺%UserPassword% ��������biliup�豣�ֵ�ǰ���ڴ���
    start /B biliup -P %UserInput% --password %UserPassword% restart
    timeout /t 11 /nobreak >nul
    start http://localhost:%UserInput%
)
