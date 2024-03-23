import platform
import subprocess
import requests

def download_and_run_script(url):
    response = requests.get(url)
    script_name = url.split('/')[-1]
    with open(script_name, 'wb') as file:
        file.write(response.content)
    if platform.system() == "Windows":
        subprocess.run(['cmd', '/c', script_name])
    else:
        subprocess.run(['bash', script_name])

# 检查操作系统类型
os_type = platform.system()
if os_type == "Windows":
    # Windows
    download_and_run_script('https://github.com/ikun1993/biliupstart/releases/latest/download/start.bat')
elif os_type in ["Linux", "Darwin"]:
    # Linux or Mac
    download_and_run_script('https://github.com/ikun1993/biliupstart/releases/latest/download/start.sh')
else:
    print("Unsupported operating system.")
