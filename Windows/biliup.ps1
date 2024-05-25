Add-Type -AssemblyName PresentationFramework

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

# 获取用户输入的盘符
$UserDrive = Read-Host "请输入你想录播的盘符（默认为C盘）"
if (-not $UserDrive) {
    $UserDrive = "C"
}

# 检查用户输入的盘符是否有效
while (-not (Test-Path "${UserDrive}:\\")) {
    [System.Windows.Forms.MessageBox]::Show("未找到 ${UserDrive} 盘，请到我的电脑中查看正确盘符。", '错误')
    $UserDrive = Read-Host "请输入你想录播的盘符（默认为C盘）"
    if ([string]::IsNullOrEmpty($UserDrive)) {
        $UserDrive = "C"
    }
}

# 设置biliup目录
$BILIUP_DIR = "${UserDrive}:\opt\biliup"
Write-Host '提示：正在运行确认下一步，期间等待较长不在提示。'
$outputFilePath = "$BILIUP_DIR\output.txt"

# 检查是否有 biliup 进程正在运行
$biliupProcess = Get-Process -Name "biliup" -ErrorAction SilentlyContinue
if ($biliupProcess) {
    $BILIUP_DIR = "${UserDrive}:\opt\biliup\$((Get-Random).ToString())"
} else {
    # 从文件中读取上一次用户输入的端口号
    if (Test-Path "$BILIUP_DIR\lastPort.txt") {
        $lastPort = Get-Content "$BILIUP_DIR\lastPort.txt"
        if ($lastPort -lt 1 -or $lastPort -gt 65535) {
            $lastPort = "19159"
        }

        # 异步执行端口查询
        $portCheckJob = Start-Job -ScriptBlock {
            param($port)
            Test-NetConnection -ComputerName localhost -Port $port
        } -ArgumentList $lastPort
    
        # 等待异步任务完成或超时（例如，33秒）
        Wait-Job $portCheckJob -Timeout 33

        # 检查异步任务是否已完成
        if ($portCheckJob.State -eq "Completed") {
            $portInUse = Receive-Job $portCheckJob

            if ($portInUse) {
                # 杀死占用端口的进程
                $processUsingPort = Get-NetTCPConnection | Where-Object { $_.LocalPort -eq $lastPort }
                if ($processUsingPort) {
                    Stop-Process -Id $processUsingPort.OwningProcess -Force
                }
            }
        }

        # 清理后台任务
        Remove-Job -Name $portCheckJob.Name

    }
}

# 创建biliup目录
if (-not (Test-Path $BILIUP_DIR)) {
    New-Item -ItemType Directory -Path $BILIUP_DIR | Out-Null
}

# 切换至biliup目录
Set-Location $BILIUP_DIR

# 获取国家代码并设置相应的下载源
$Windowsbiliup = "https://github.com/ikun1993/biliupstart/releases/download/biliupstart/windowsbiliup.bat"
$CountryCode = (Invoke-RestMethod -Uri "https://ipinfo.io/country").Trim()
if ($CountryCode -eq "CN") {
    $biliupgithub = "https://j.iokun.top/$Windowsbiliup"
    $pipsource = "-i https://mirrors.cernet.edu.cn/pypi/web/simple"
} else {
    $biliupgithub = $Windowsbiliup
    $pipsource = "-i https://pypi.org/simple"
}

# 检查Python是否已安装
$python_path = Get-Command python.exe -ErrorAction SilentlyContinue
if (-not $python_path) {
    Write-Host '提示：未安装Python，准备安装Python和环境。'
    $chocolateyPath = 'C:\ProgramData\chocolatey'
    if (Test-Path $chocolateyPath) {
        Start-Process powershell -Verb RunAs -ArgumentList "Remove-Item -Path $chocolateyPath -Recurse -Force"
    }

    $biliupbatPath = Join-Path -Path $pwd -ChildPath 'windowsbiliup.bat'
    if (-not (Test-Path $biliupbatPath)) {
        Invoke-WebRequest -Uri $biliupgithub -OutFile $biliupbatPath
    }
     
    Start-Process -FilePath $biliupbatPath -Verb RunAs -Wait

    if (Test-Path $biliupbatPath) {
        Remove-Item -Path $biliupbatPath -Force
    }
}

# 检查Python版本是否满足要求
$python_version = python --version
$python_version_match = $python_version -match 'Python ([0-9.]+)'
if (-not $python_version_match) {
    Write-Host '提示：无法获取 Python 版本,退出程序。'
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
    Write-Host '错误：Python 小于 $required_python_version，请手动更新到更高版本。当前版本：$python_version_number。'
    exit
}

# 检查biliup版本
$pipversion = (pip index versions biliup | Select-String "LATEST" | Select-Object -First 1).Line.Split(":")[1].Trim()
if (Get-Package -Name "biliup" -ErrorAction SilentlyContinue) {
    $biliversion = 0
} else {
    $biliversion = (pip show biliup | Select-String -Pattern "Version").ToString().Split(":")[1].Trim()
}

# 更新biliup
if ($pipversion -ne 0 -and $biliversion -ne $pipversion) {
    $userInput = Read-Host "检查到新版本，是否需要更新？(Y/N)"
    if ($userInput.ToLower() -eq "n") {
        Write-Host '提示：选择不更新 如需更新手动终端输入 pip install $pipsource -U biliup 。'
    } else {
        pip install $pipsource -U biliup
        $biliversion = (pip show biliup | Select-String -Pattern "Version").ToString().Split(":")[1].Trim()
        if ($biliversion -ne $pipversion) {
            Write-Host '错误：更新失败 如需更新手动终端输入 pip install -U biliup 。'
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
        Read-Host "错误: 请输入有效的端口号，请重新输入。"
    } elseif ($UserInput -in (0..65535)) {
        $portIsInUse = Get-NetTCPConnection | Where-Object { $_.LocalPort -eq $UserInput }
        if ($portIsInUse) {
            Write-Host '错误：端口 $UserInput 已被占用，请重新输入。'
        } else {
            $portIsValid = $true
        }
    }
}

# 保存用户输入的端口号到文件
Set-Content -Path "${UserDrive}:\opt\biliup\lastPort.txt" -Value $UserInput

# 启动biliup
$UserPassword = Read-Host "请输入密码（按回车键不使用密码）"
if ([string]::IsNullOrEmpty($UserPassword)) {
    $message = "未启用密码公网不推荐 持续运行biliup需保持新窗口存在"
    $biliup = Start-Process "biliup" -ArgumentList "-P $UserInput start" -PassThru
    Start-Sleep -Seconds 11
    Start-Process "http://localhost:$UserInput"
} else {
    $messag = "账号：biliup 密码：$UserPassword 持续运行biliup需保持新窗口存在"
    $biliup = Start-Process "biliup" -ArgumentList "-P $UserInput --password $UserPassword start" -PassThru
    Start-Sleep -Seconds 11
    Start-Process "http://localhost:$UserInput"
}

# 结束脚本
Write-Host @"
注意：该脚本第三方制作与官方无关

注意：赞助爱发电请开发者喝杯咖啡

注意：https://afdian.net/a/biliup

你录播文件和日志在 $BILIUP_DIR

反馈问题需带上文件 $BILIUP_DIR\ds_update.log

$message

脚本执行完毕。
"@
