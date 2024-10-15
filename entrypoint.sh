#!/bin/sh

# 打印当前日期和时间
echo "Current date and time: $(date)"

# 检查 GitHub API 是否可用
echo "Checking GitHub API..."
curl -s https://api.github.com | jq .

# 退出状态码为 0 表示成功
exit 0
