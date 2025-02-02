#!/bin/bash

# 定义统计函数
stats() {
    local file=$1
    local age_stats=(0 0 0) # 20岁以下，20-30岁，30岁以上
    local position_stats=()
    local longest_player=""
    local shortest_player=""
    local longest_name=0
    local shortest_name=100
    local oldest=0
    local youngest=100
    local oldest_player=""
    local youngest_player=""
    local total_players=0
    # 跳过标题行
   while IFS=$'\t' read group country rank jersey position age selections club player captain; do
        ((total_players++))
	#echo"$group"
	#echo"$country"
	#echo"$rank"
	#echo"$jersey"
	#echo"$position"
	#echo"$age"
	#echo"$selections"
	#echo"$club"
	#echo"$player"
	#echo"$captain"
	
        # 统计年龄区间
	if [[ "$group" == "Group" ]]; then
		youngest=100
           	continue  # 如果 group 等于 "group"，则跳过本次循环
        fi
        if (( age < 20 )); then
            (( age_stats[0]++ ))
        elif (( age >= 20 && age <= 30 )); then
            (( age_stats[1]++ ))
        else
            (( age_stats[2]++ ))
        fi

        # 使用awk处理场上位置
        position_length=$(awk '{print length}' <<< "$position")
        if [[ -z "${position_stats[$position_length]}" ]]; then
            position_stats[$position_length]=1
        else
            (( position_stats[$position_length]++ ))
        fi

        # 名字长度统计
        name_length=${#player}
        if (( name_length > longest_name )); then
            longest_name=$name_length
            longest_player=$player
        fi
        if (( name_length < shortest_name )); then
            shortest_name=$name_length
            shortest_player=$player
        fi

        # 年龄最大和最小统计
        if (( age > oldest )); then
           oldest=$age
           oldest_player=$player
        fi
        if (( age < youngest )); then
		#echo "$age"
		#echo "$player"
           youngest=$age
           youngest_player=$player
        fi
    done<"$file"
    # 计算每个年龄区间的百分比
    percentage_20_below=$(echo "scale=2; (${age_stats[0]}*100)/${total_players}" | bc)
    percentage_20_to_30=$(echo "scale=2; (${age_stats[1]}*100)/${total_players}" | bc)
    percentage_above_30=$(echo "scale=2; (${age_stats[2]}*100)/${total_players}" | bc)

    # 打印统计结果
    echo "年龄统计："
    echo "20岁以下：${age_stats[0]}人 (${percentage_20_below}%)"
    echo "20-30岁：${age_stats[1]}人 (${percentage_20_to_30}%)"
    echo "30岁以上：${age_stats[2]}人 (${percentage_above_30}%)"
    echo "总人数： ${total_players} 人"
    
    echo "场上位置统计："
    for position in "${!position_stats[@]}"; do
        echo "$position:${position_stats[$position]}人"
    done

    echo "名字最长的球员：$longest_player"
    echo "名字最短的球员：$shortest_player"
    echo "年龄最大的球员：$oldest_player"
    echo "年龄最小的球员：$youngest_player"
}

# 主程序
main() {
    local file=$1

    if [[ ! -f "$file" ]]; then
        echo "错误: 指定的文件不存在。"
        return 1
    fi

    stats "$file"
}

# 脚本入口
if [[ $# -ne 1 ]]; then
    echo "使用方法: $0 <文件路径>"
    exit 1
fi

main "$1"

