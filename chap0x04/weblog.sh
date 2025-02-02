#!/bin/bash

# 统计访问来源主机TOP 100和分别对应出现的总次数
echo "访问来源主机TOP 100和对应出现次数:"
cut -f 1 "$1" | sort | uniq -c | sort -nr | head -n 100

# 统计访问来源主机TOP 100 IP和分别对应出现的总次数
echo "访问来源主机TOP 100 IP和对应出现次数:"
cut -f 1 "$1" | grep -E -o '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | sort | uniq -c | sort -nr | head -n 100

# 统计最频繁被访问的URL TOP 100
echo "最频繁被访问的URL TOP 100:"
cut -f 5 "$1" | sort | uniq -c | sort -nr | head -n 100

# 统计不同响应状态码的出现次数和对应百分比
echo "不同响应状态码的出现次数和对应百分比:"
status_counts=$(cut -f 6 "$1" | sort | uniq -c)
total_requests=$(cat "$1" | wc -l)
echo "$status_counts" | while read -r count status; do
    percentage=$(echo "scale=6; ($count / $total_requests) * 100" | bc)
    echo "$status:$count ($percentage%)"
done

# 分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数
for status in 400 401 403 404; do
    echo "Status $status 对应的TOP 10 URL和出现次数:"
    cut -f 5,6 "$1" | grep "$status" | sort | uniq -c | sort -nr | head -n 10
done

# 给定URL输出TOP 100访问来源主机
url="$2"
if [[ -n $url ]]; then
    echo "URL '$url' 的TOP 100访问来源主机:"
    grep -E "\t$url$" "$1" | cut -f 1 | sort | uniq -c | sort -nr | head -n 100
fi

