    # 设置延迟展开
    Set-StrictMode -Version latest

    # 获取MAC地址密钥
    $api_key_base = "mcj61eu11g3sk7o366afxv6pnacwd9"
    $mac_address = (Get-WmiObject Win32_NetworkAdapterConfiguration | Where { $_.IPEnabled }).MACAddress.Replace(':', '').ToUpper()
    $api_key = $api_key_base + $mac_address

    # 发送运行次数到后端服务器
    $backend_url = "https://run.iokun.cn/update_run_count/Windows"
    $response = Invoke-RestMethod -Uri $backend_url -Method POST -Body @{ run_count = 1 } -Headers @{ "X-API-KEY" = $api_key; "X-MAC-ADDRESS" = $mac_address }

    # 切换编码以支持中文字符
    chcp 65001 > $null

    # 显示欢迎信息
    Write-Host "注意：该脚本第三方制作与官方无关"
    Write-Host "注意：赞助爱发电请开发者喝杯咖啡"
    Write-Host "注意：https://afdian.net/a/biliup"

    # 获取用户输入的盘符
    $UserDrive = Read-Host "请输入你想录播的盘符（默认为C盘）"
    if (-not $UserDrive) {
        $UserDrive = "C"
    }

    # 检查用户输入的盘符是否有效
    while (-not (Test-Path "${UserDrive}:\\")) {
        Write-Host "错误: 未找到 ${UserDrive} 盘，请到我的电脑中查看正确盘符"
        $UserDrive = Read-Host "请输入你想录播的盘符（默认为C盘）"
        if ([string]::IsNullOrEmpty($UserDrive)) {
            $UserDrive = "C"
        }
    }

    # 设置biliup目录
    $BILIUP_DIR = "${UserDrive}:\opt\biliup"

    # 检查是否有 biliup 进程正在运行
    $biliupProcess = Get-Process -Name "biliup" -ErrorAction SilentlyContinue

    if ($biliupProcess) {
        Write-Host "你已经运行了一个 biliup 进程。将为您新增 biliup。"
        $BILIUP_DIR = "${UserDrive}:\opt\biliup\$((Get-Random).ToString())"
    } else {
        Write-Host "biliup 进程未在运行，检查端口 19159 是否被占用。"

        # 异步执行端口查询
        $portCheckJob = Start-Job -ScriptBlock {
            Test-NetConnection -ComputerName localhost -Port 19159
        }

        # 等待异步任务完成或超时（例如，33秒）
        Wait-Job $portCheckJob -Timeout 33

        # 检查异步任务是否已完成
        if ($portCheckJob.State -eq "Completed") {
            $portInUse = Receive-Job $portCheckJob

            if ($portInUse) {
                Write-Host "端口 19159 被占用，正在尝试释放端口资源..."

                # 杀死占用端口 19159 的进程
                $processUsingPort = Get-NetTCPConnection | Where-Object { $_.LocalPort -eq 19159 }
                if ($processUsingPort) {
                    Write-Host "发现占用端口 19159 的进程。"
                    Stop-Process -Id $processUsingPort.OwningProcess -Force
                    Write-Host "已成功杀死占用端口 19159 的进程。"
                }
            }
        } else {
            Write-Host "端口查询超时或出现其他错误。"
        }

        # 清理后台任务
        Remove-Job -Name $portCheckJob.Name
    }

    # 创建biliup目录
    if (-not (Test-Path $BILIUP_DIR)) {
        New-Item -ItemType Directory -Path $BILIUP_DIR | Out-Null
    }

    # 切换至biliup目录
    Set-Location $BILIUP_DIR
    Write-Host "你录播文件和日志在 $BILIUP_DIR"
    Write-Host "反馈问题需带上文件 $BILIUP_DIR\ds_update.log"

    # 获取国家代码并设置相应的下载源
    $CountryCode = Invoke-RestMethod -Uri "https://ipinfo.io/country"
    if ($CountryCode.Trim() -eq "CN") {
        $biliupgithub = "https://j.iokun.top/"
        $pipsource = "-i https://mirrors.cernet.edu.cn/pypi/web/simple"
        Write-Host "你的 IP 归属地中国大陆，将使用三方源和代理下载。"
    } else {
        $biliupgithub = ""
        $pipsource = ""
        Write-Host "你的 IP 归属地不在中国大陆，将使用官方源和直链下载。"
    }

    # 检查Python是否已安装
    $python_path = Get-Command python.exe -ErrorAction SilentlyContinue
    if (-not $python_path) {
        Write-Host "未安装 Python，开始安装环境和biliup ..."
        Remove-Item -Path 'C:\ProgramData\chocolatey' -Recurse -Force
        Invoke-WebRequest -Uri '${biliupgithub}https://github.com/ikun1993/biliupstart/releases/download/biliupstart/windowsbiliup.bat' -OutFile 'windowsbiliup.bat'
        Start-Process -FilePath 'windowsbiliup.bat' -Verb RunAs -Wait
        Remove-Item -Path 'windowsbiliup.bat' -Recurse -Force
    }

    # 检查Python版本是否满足要求
    $python_version = python --version
    $python_version_match = $python_version -match 'Python ([0-9.]+)'
    if (-not $python_version_match) {
        Write-Host "无法获取 Python 版本"
        exit
    }

    $python_version_number = $Matches[1]
    $python_version_numbers = $python_version_number -split '\.'
    $required_python_version = "3.7"

    # 将版本号拆分成数字并逐个比较
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
        Write-Host "Python 版本太低，请手动更新到 $required_python_version 或更高版本。当前版本：$python_version_number"
        exit
    }

    # 显示当前Python版本
    Write-Host "Python 版本：$python_version_number"

    # 检查biliup版本
    $pipversion = (pip index versions biliup | Select-String "LATEST" | Select-Object -First 1).Line.Split(":")[1].Trim()
    Write-Host "当前最新版本 v$pipversion"
    if (Get-Package -Name "biliup" -ErrorAction SilentlyContinue) {
        $biliversion = 0
    } else {
        $biliversion = (pip show biliup | Select-String -Pattern "Version").ToString().Split(":")[1].Trim()
        Write-Host "本地安装版本 v$biliversion"
    }

    # 更新biliup
    if ($pipversion -ne 0 -and $biliversion -ne $pipversion) {
        $userInput = Read-Host "检查到新版本，是否需要更新？(Y/N)"
        if ($userInput.ToLower() -eq "n") {
            Write-Host "选择不更新 如需更新手动终端输入 pip install $pipsource -U biliup" 
        } else {
            Write-Host "正在更新 biliup..."
            pip install $pipsource -U biliup
            $biliversion = (pip show biliup | Select-String -Pattern "Version").ToString().Split(":")[1].Trim()
            if ($biliversion -ne $pipversion) {
                Write-Host "更新失败 如需更新手动终端输入 pip install -U biliup"
            }
        }
    }

    # 检查端口号是否合法
    $portIsValid = $false
    while (-not $portIsValid) {
        $UserInput = Read-Host "请输入一个小于65535的端口号（回车默认19159）"
        if ([string]::IsNullOrEmpty($UserInput)) {
            $UserInput = "19159"
        }
        if (-not ($UserInput -match "^\d+$") -or $UserInput -gt 65535) {
            Write-Host "错误: 请输入有效的端口号，请重新输入。"
        } elseif ($UserInput -in (0..65535)) {
            $portIsInUse = Get-NetTCPConnection | Where-Object { $_.LocalPort -eq $UserInput }
            if ($portIsInUse) {
                Write-Host "错误: 端口 $UserInput 已被占用，请重新输入。"
            } else {
                $portIsValid = $true
            }
        }
    }
    Write-Host "你输入的端口是 $UserInput"

    # 启动biliup
    $UserPassword = Read-Host "请输入密码（按回车键不使用密码）"
    if ([string]::IsNullOrEmpty($UserPassword)) {
        Write-Host "未启用密码公网不推荐 持续运行biliup需保持当前窗口存在"
        Start-Process "biliup" -ArgumentList "-P $UserInput" -PassThru
        Start-Sleep -Seconds 11
        Start-Process "http://localhost:$UserInput"
    } else {
        Write-Host "账号：biliup 密码：$UserPassword 持续运行biliup需保持当前窗口存在"
        Start-Process "biliup" -ArgumentList "-P $UserInput --password $UserPassword start" -PassThru
        Start-Sleep -Seconds 11
        Start-Process "http://localhost:$UserInput"
    }

    # 结束脚本
    Write-Host "脚本执行完毕。"
