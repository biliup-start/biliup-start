@echo off
:: Step 1: ��װ Chocolatey
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

:: Step 2: ʹ�� Chocolatey ��װ ffmpeg
choco install ffmpeg -y

:: Step 3: ʹ�� Chocolatey ��װ Python 3.10
choco install python310 -y

:: Step 4: ��� Python ·����ϵͳ��������
setx PATH "%PATH%;C:\Python310\Scripts\;C:\Python310\"

:: Step 5: ��� IP �����ز���װ biliup
setlocal

REM ��ȡ����IP������
for /f %%b in ('curl -s https://ipinfo.io/country') do (
    set CountryCode=%%b
)
echo IP������: "%CountryCode%"
:: �ж� IP �������Ƿ�Ϊ�й�
if "%CountryCode%"=="CN" (
    echo ��� IP ���������й�����ʹ���廪Դ��װ biliup��
    pip install -i https://pypi.tuna.tsinghua.edu.cn/simple biliup
) else (
    echo ��� IP �����ز����й�����ʹ��Ĭ��Դ��װ biliup��
    pip install biliup
)


endlocal
:: ��������Ϣ
echo �����ȫ����װ
