name: Update README

on:
  schedule:
    - cron: '0 * * * *'  # 每小时运行一次

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: 3.8

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install requests

    - name: Update README
      run: |
        python update_readme.py
