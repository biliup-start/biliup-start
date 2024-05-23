    # �����ӳ�չ��
    Set-StrictMode -Version latest

    # ��ȡMAC��ַ��Կ
    $api_key_base = "mcj61eu11g3sk7o366afxv6pnacwd9"
    $mac_address = (Get-WmiObject Win32_NetworkAdapterConfiguration | Where { $_.IPEnabled }).MACAddress.Replace(':', '').ToUpper()
    $api_key = $api_key_base + $mac_address

    # �������д�������˷�����
    $backend_url = "https://run.iokun.cn/update_run_count/Windows"
    $response = Invoke-RestMethod -Uri $backend_url -Method POST -Body @{ run_count = 1 } -Headers @{ "X-API-KEY" = $api_key; "X-MAC-ADDRESS" = $mac_address }

    # �л�������֧�������ַ�
    chcp 65001 > $null

    # ��ʾ��ӭ��Ϣ
    Write-Host "ע�⣺�ýű�������������ٷ��޹�"
    Write-Host "ע�⣺�����������뿪���ߺȱ�����"
    Write-Host "ע�⣺https://afdian.net/a/biliup"

    # ��ȡ�û�������̷�
    $UserDrive = Read-Host "����������¼�����̷���Ĭ��ΪC�̣�"
    if (-not $UserDrive) {
        $UserDrive = "C"
    }

    # ����û�������̷��Ƿ���Ч
    while (-not (Test-Path "${UserDrive}:\\")) {
        Write-Host "����: δ�ҵ� ${UserDrive} �̣��뵽�ҵĵ����в鿴��ȷ�̷�"
        $UserDrive = Read-Host "����������¼�����̷���Ĭ��ΪC�̣�"
        if ([string]::IsNullOrEmpty($UserDrive)) {
            $UserDrive = "C"
        }
    }

    # ����biliupĿ¼
    $BILIUP_DIR = "${UserDrive}:\opt\biliup"

    # ����Ƿ��� biliup ������������
    $biliupProcess = Get-Process -Name "biliup" -ErrorAction SilentlyContinue

    if ($biliupProcess) {
        Write-Host "���Ѿ�������һ�� biliup ���̡���Ϊ������ biliup��"
        $BILIUP_DIR = "${UserDrive}:\opt\biliup\$((Get-Random).ToString())"
    } else {
        Write-Host "biliup ����δ�����У����˿� 19159 �Ƿ�ռ�á�"

        # �첽ִ�ж˿ڲ�ѯ
        $portCheckJob = Start-Job -ScriptBlock {
            Test-NetConnection -ComputerName localhost -Port 19159
        }

        # �ȴ��첽������ɻ�ʱ�����磬33�룩
        Wait-Job $portCheckJob -Timeout 33

        # ����첽�����Ƿ������
        if ($portCheckJob.State -eq "Completed") {
            $portInUse = Receive-Job $portCheckJob

            if ($portInUse) {
                Write-Host "�˿� 19159 ��ռ�ã����ڳ����ͷŶ˿���Դ..."

                # ɱ��ռ�ö˿� 19159 �Ľ���
                $processUsingPort = Get-NetTCPConnection | Where-Object { $_.LocalPort -eq 19159 }
                if ($processUsingPort) {
                    Write-Host "����ռ�ö˿� 19159 �Ľ��̡�"
                    Stop-Process -Id $processUsingPort.OwningProcess -Force
                    Write-Host "�ѳɹ�ɱ��ռ�ö˿� 19159 �Ľ��̡�"
                }
            }
        } else {
            Write-Host "�˿ڲ�ѯ��ʱ�������������"
        }

        # �����̨����
        Remove-Job -Name $portCheckJob.Name
    }

    # ����biliupĿ¼
    if (-not (Test-Path $BILIUP_DIR)) {
        New-Item -ItemType Directory -Path $BILIUP_DIR | Out-Null
    }

    # �л���biliupĿ¼
    Set-Location $BILIUP_DIR
    Write-Host "��¼���ļ�����־�� $BILIUP_DIR"
    Write-Host "��������������ļ� $BILIUP_DIR\ds_update.log"

    # ��ȡ���Ҵ��벢������Ӧ������Դ
    $CountryCode = Invoke-RestMethod -Uri "https://ipinfo.io/country"
    if ($CountryCode.Trim() -eq "CN") {
        $biliupgithub = "https://j.iokun.top/"
        $pipsource = "-i https://mirrors.cernet.edu.cn/pypi/web/simple"
        Write-Host "��� IP �������й���½����ʹ������Դ�ʹ������ء�"
    } else {
        $biliupgithub = ""
        $pipsource = ""
        Write-Host "��� IP �����ز����й���½����ʹ�ùٷ�Դ��ֱ�����ء�"
    }

    # ���Python�Ƿ��Ѱ�װ
    $python_path = Get-Command python.exe -ErrorAction SilentlyContinue
    if (-not $python_path) {
        Write-Host "δ��װ Python����ʼ��װ������biliup ..."
        Remove-Item -Path 'C:\ProgramData\chocolatey' -Recurse -Force
        Invoke-WebRequest -Uri '${biliupgithub}https://github.com/ikun1993/biliupstart/releases/download/biliupstart/windowsbiliup.bat' -OutFile 'windowsbiliup.bat'
        Start-Process -FilePath 'windowsbiliup.bat' -Verb RunAs -Wait
        Remove-Item -Path 'windowsbiliup.bat' -Recurse -Force
    }

    # ���Python�汾�Ƿ�����Ҫ��
    $python_version = python --version
    $python_version_match = $python_version -match 'Python ([0-9.]+)'
    if (-not $python_version_match) {
        Write-Host "�޷���ȡ Python �汾"
        exit
    }

    $python_version_number = $Matches[1]
    $python_version_numbers = $python_version_number -split '\.'
    $required_python_version = "3.7"

    # ���汾�Ų�ֳ����ֲ�����Ƚ�
    $python_version_is_valid = $true
    foreach ($i in 0..2) {
        if ($python_version_numbers[$i] -lt $required_python_version[$i]) {
            $python_version_is_valid = $false
            break
        } elseif ($python_version_numbers[$i] -gt $required_python_version[$i]) {
            break
        }
    }

    if (-not $python_version_is_valid) {
        Write-Host "Python �汾̫�ͣ����ֶ����µ� $required_python_version ����߰汾����ǰ�汾��$python_version_number"
        exit
    }

    # ��ʾ��ǰPython�汾
    Write-Host "Python �汾��$python_version_number"

    # ���biliup�汾
    $pipversion = (pip index versions biliup | Select-String "LATEST" | Select-Object -First 1).Line.Split(":")[1].Trim()
    Write-Host "��ǰ���°汾 v$pipversion"
    if (Get-Package -Name "biliup" -ErrorAction SilentlyContinue) {
        $biliversion = 0
    } else {
        $biliversion = (pip show biliup | Select-String -Pattern "Version").ToString().Split(":")[1].Trim()
        Write-Host "���ذ�װ�汾 v$biliversion"
    }

    # ����biliup
    if ($pipversion -ne 0 -and $biliversion -ne $pipversion) {
        $userInput = Read-Host "��鵽�°汾���Ƿ���Ҫ���£�(Y/N)"
        if ($userInput.ToLower() -eq "n") {
            Write-Host "ѡ�񲻸��� ��������ֶ��ն����� pip install $pipsource -U biliup" 
        } else {
            Write-Host "���ڸ��� biliup..."
            pip install $pipsource -U biliup
            $biliversion = (pip show biliup | Select-String -Pattern "Version").ToString().Split(":")[1].Trim()
            if ($biliversion -ne $pipversion) {
                Write-Host "����ʧ�� ��������ֶ��ն����� pip install -U biliup"
            }
        }
    }

    # ���˿ں��Ƿ�Ϸ�
    $portIsValid = $false
    while (-not $portIsValid) {
        $UserInput = Read-Host "������һ��С��65535�Ķ˿ںţ��س�Ĭ��19159��"
        if ([string]::IsNullOrEmpty($UserInput)) {
            $UserInput = "19159"
        }
        if (-not ($UserInput -match "^\d+$") -or $UserInput -gt 65535) {
            Write-Host "����: ��������Ч�Ķ˿ںţ����������롣"
        } elseif ($UserInput -in (0..65535)) {
            $portIsInUse = Get-NetTCPConnection | Where-Object { $_.LocalPort -eq $UserInput }
            if ($portIsInUse) {
                Write-Host "����: �˿� $UserInput �ѱ�ռ�ã����������롣"
            } else {
                $portIsValid = $true
            }
        }
    }
    Write-Host "������Ķ˿��� $UserInput"

    # ����biliup
    $UserPassword = Read-Host "���������루���س�����ʹ�����룩"
    if ([string]::IsNullOrEmpty($UserPassword)) {
        Write-Host "δ�������빫�����Ƽ� ��������biliup�豣�ֵ�ǰ���ڴ���"
        Start-Process "biliup" -ArgumentList "-P $UserInput" -PassThru
        Start-Sleep -Seconds 11
        Start-Process "http://localhost:$UserInput"
    } else {
        Write-Host "�˺ţ�biliup ���룺$UserPassword ��������biliup�豣�ֵ�ǰ���ڴ���"
        Start-Process "biliup" -ArgumentList "-P $UserInput --password $UserPassword start" -PassThru
        Start-Sleep -Seconds 11
        Start-Process "http://localhost:$UserInput"
    }

    # �����ű�
    Write-Host "�ű�ִ����ϡ�"
