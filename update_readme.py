import os
import requests
import json 

API_KEY = os.getenv('API_KEY')
GET_RUN_COUNT_URL = "https://run.iokun.cn/get_run_count/total"

def get_run_count():
    headers = {"X-API-KEY": API_KEY}
    response = requests.get(GET_RUN_COUNT_URL, headers=headers)
    if response.status_code != 200:
        raise Exception(f"API request failed with status code {response.status_code}")
    try:
        return response.json()['total_run_count']
    except json.decoder.JSONDecodeError:
        raise Exception(f"Failed to parse API response: {response.text}")

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
