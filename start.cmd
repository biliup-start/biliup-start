@echo off
 
echo ������ʹ�� powershell �ű�����һ�λ����غ���������ȴ� ....

for /f %%b in ('powershell -command "(Invoke-WebRequest -Uri 'https://ipinfo.io/country').Content"') do (
    set "CountryCode=%%b"
)
if "%CountryCode%"=="CN" (
    set "iokun=https://j.iokun.top/"
) else (
    set "iokun="
)

if not exist "./start.ps1" (
    powershell -command "(Invoke-WebRequest -Uri '%iokun%https://github.com/ikun1993/biliupstart/releases/download/biliupstart/start.ps1' -OutFile 'start.ps1')"
    if errorlevel 1 (
        echo ����start.ps1�ű�ʧ�ܣ������������ӻ��Ժ����ԡ�
        pause
        exit /b 1
    )
)

PowerShell -ExecutionPolicy Bypass -File "./start.ps1"
