import os
import requests

API_KEY = os.getenv('API_KEY')
GET_RUN_COUNT_URL = "https://run.iokun.cn/get_run_count/total"

def get_run_count():
    headers = {"X-API-KEY": API_KEY}
    response = requests.get(GET_RUN_COUNT_URL, headers=headers)
    return response.json()['total_run_count']

def update_readme(run_count):
    with open("README.md", "r") as readme:
        lines = readme.readlines()

    for i, line in enumerate(lines):
        if line.startswith('Run Count:'):
            lines[i] = f"Run Count: {run_count}\n"
            break
    else:
        lines.append(f"\nRun Count: {run_count}\n")

    with open("README.md", "w") as readme:
        readme.writelines(lines)

if __name__ == "__main__":
    run_count = get_run_count()
    update_readme(run_count)
