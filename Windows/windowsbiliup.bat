@echo off

:: �������д�������˷�����
set backend_url=https://run.iokun.cn/update_run_count
powershell -Command "Invoke-RestMethod -Uri %backend_url% -Method POST -Body @{run_count=1}"

:: ���� Flask ��ȡ���д���
set get_run_count_url=https://run.iokun.cn/get_run_count
for /f "delims=" %%i in ('powershell -Command "(Invoke-RestMethod -Uri %get_run_count_url%).run_count"') do set run_count=%%i

:: ������ն�
echo һ���ű������� %run_count% ��

:: Step 1: ��װ Chocolatey
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

:: Step 2: ʹ�� Chocolatey ��װ ffmpeg
choco install ffmpeg -y

:: Step 3: ʹ�� Chocolatey ��װ Python 3.10
choco install python310 -y

:: Step 4: ʹ�� Chocolatey ��װ Node.js
choco install nodejs -y

:: Step 5: ��� Python ·����ϵͳ��������
setx PATH "%PATH%;C:\Python310\Scripts\;C:\Python310\"

:: Step 6: ��� IP �����ز���װ biliup
setlocal

:: �ж� IP �������Ƿ�Ϊ�й�
for /f %%b in ('curl -s https://ipinfo.io/country') do (
    set CountryCode=%%b
)
echo IP������: %CountryCode%
if "%CountryCode%"=="CN" (
    set pipSource="https://mirrors.cernet.edu.cn/pypi/web/simple"
    echo ��� IP ���������й�����ʹ������Դ��װ Python �⡣
) else (
    set pipSource="https://pypi.org/simple"
    echo ��� IP �����ز����й�����ʹ��Ĭ��Դ��װ Python �⡣
)

::  ��װ biliup
pip install -i "%pipSource%" biliup

endlocal
::  ��������Ϣ
echo �����ȫ����װ
