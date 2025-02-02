#!/bin/bash

# 定义帮助信息
show_help() {
    echo "使用方法: $(basename "$0") [选项]... [目录]"
    echo "对指定目录下的所有图片文件进行批处理。"
    echo ""
    echo "选项:"
    echo "-q, --quality <百分比>    JPEG图片质量压缩，例如90"
    echo "-r, --resize <宽度x高度>  压缩分辨率，保持宽高比"
    echo "-w, --watermark <文本>    添加文本水印"
    echo "-p, --prefix <字符串>     添加文件名前缀"
    echo "-s, --suffix <字符串>     添加文件名后缀"
    echo "-c, --convert             将PNG/SVG图片转换为JPG格式"
    echo "-h, --help                显示帮助信息"
    exit 0
}

# 初始化变量
quality=""
resize=""
watermark=""
prefix=""
suffix=""
convert_flag=0

# 处理命令行参数
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -q|--quality)
        quality="$2"
        shift # past argument
        shift # past value
        ;;
        -r|--resize)
        resize="$2"
        shift # past argument
        shift # past value
        ;;
        -w|--watermark)
        watermark="$2"
        shift # past argument
        shift # past value
        ;;
        -p|--prefix)
        prefix="$2"
        shift # past argument
        shift # past value
        ;;
        -s|--suffix)
        suffix="$2"
        shift # past argument
        shift # past value
        ;;
        -c|--convert)
        convert_flag=1
        shift # past argument
        ;;
        -h|--help)
        show_help
        ;;
        *)    # 目录参数
        dir="$1"
        shift # past argument
        ;;
    esac
done

# 检查目录是否存在
if [[ ! -d "$dir" ]]; then
    echo "错误: 指定的目录不存在。"
    exit 1
fi

# 开始处理图片
for file in "$dir"/*.{jpg,jpeg,png,svg}; do
    if [[ -f "$file" ]]; then
        # JPEG质量压缩
        if [[ -n "$quality" ]]; then
            convert "$file" -quality "$quality%" "$file"
        fi
        
        # 分辨率压缩
        if [[ -n "$resize" ]]; then
            convert "$file" -resize "$resize" -resize "x$resize>" "$file"
        fi
        
        # 添加水印
        if [[ -n "$watermark" ]]; then
            convert "$file" -pointsize 24 -fill black -gravity southeast -draw "text 10,10 '$watermark'" "$file"
        fi
        
        # 重命名
        if [[ -n "$prefix" || -n "$suffix" ]]; then
            # 提取文件名和扩展名
            filename=$(basename "$file")
            extension="${filename##*.}"
            filename="${filename%.*}"
            
            # 添加前缀或后缀
            if [[ -n "$prefix" ]]; then
                newname="$prefix$filename"
            elif [[ -n "$suffix" ]]; then
                newname="$filename$suffix"
            fi
            
            # 重命名文件
            mv "$file" "${dir}/${newname}.${extension}"
        fi
        
        # 转换格式
        if [[ $convert_flag -eq 1 ]]; then
            filename=$(basename "$file")
            extension="${filename##*.}"
            if [[ "$extension" == "png" || "$extension" == "svg" ]]; then
                convert "$file" "${dir}/${filename%.${extension}}.jpg"
            fi
        fi
    fi
done

echo "图片批处理完成。" 
