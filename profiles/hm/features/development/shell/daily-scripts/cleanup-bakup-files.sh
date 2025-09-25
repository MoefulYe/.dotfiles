#!/usr/bin/env bash

# 清理 bakup 备份文件脚本
# 使用 fd 递归搜索以 bakup 开头的扩展名文件，并允许用户选择删除
# 
# 使用方法:
#   ./cleanup-bakup-files.sh                    # 搜索当前目录
#   ./cleanup-bakup-files.sh /path/to/dir       # 搜索指定目录

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认搜索当前目录，接受可选的第二个参数控制搜索目录
SEARCH_DIR="${1:-.}"

# 检查 fd 是否安装
if ! command -v fd &> /dev/null; then
    echo -e "${RED}错误: fd 命令未找到。请先安装 fd。${NC}"
    echo "在 NixOS 中，你可以运行: nix-shell -p fd"
    exit 1
fi

echo -e "${BLUE}正在搜索目录: ${SEARCH_DIR}${NC}"
echo -e "${YELLOW}搜索模式: *.bakup*${NC}"
echo ""

# 使用 fd 搜索所有以 bakup 开头的扩展名文件
# 匹配模式: xxx.bakup, xxx.bakup2025090922222, xxx.bakup-2025090922222 等
mapfile -t bakup_files < <(fd -t f --glob "*.bakup*" "$SEARCH_DIR" 2>/dev/null || true)

# 检查是否找到文件
if [ ${#bakup_files[@]} -eq 0 ]; then
    echo -e "${GREEN}未找到任何 bakup 备份文件。${NC}"
    exit 0
fi

echo -e "${YELLOW}找到 ${#bakup_files[@]} 个 bakup 备份文件:${NC}"
echo ""

# 显示找到的文件
for i in "${!bakup_files[@]}"; do
    file="${bakup_files[$i]}"
    size=$(du -h "$file" 2>/dev/null | cut -f1 || echo "未知")
    echo -e "${BLUE}[$((i+1))]${NC} $file ${YELLOW}($size)${NC}"
done

echo ""
echo -e "${YELLOW}请选择操作:${NC}"
echo "1. 删除所有文件"
echo "2. 逐个确认删除"
echo "3. 退出"
echo ""

read -p "请输入选择 (1-3): " choice

case $choice in
    1)
        echo -e "${RED}警告: 即将删除所有 ${#bakup_files[@]} 个文件！${NC}"
        read -p "确认删除所有文件? (y/N): " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            deleted_count=0
            for file in "${bakup_files[@]}"; do
                if rm "$file" 2>/dev/null; then
                    echo -e "${GREEN}已删除: $file${NC}"
                    ((deleted_count++))
                else
                    echo -e "${RED}删除失败: $file${NC}"
                fi
            done
            echo -e "${GREEN}完成! 共删除 $deleted_count 个文件。${NC}"
        else
            echo -e "${YELLOW}操作已取消。${NC}"
        fi
        ;;
    2)
        deleted_count=0
        for file in "${bakup_files[@]}"; do
            echo ""
            echo -e "${BLUE}文件: $file${NC}"
            size=$(du -h "$file" 2>/dev/null | cut -f1 || echo "未知")
            echo -e "${YELLOW}大小: $size${NC}"
            
            read -p "删除此文件? (y/N): " confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                if rm "$file" 2>/dev/null; then
                    echo -e "${GREEN}已删除: $file${NC}"
                    ((deleted_count++))
                else
                    echo -e "${RED}删除失败: $file${NC}"
                fi
            else
                echo -e "${YELLOW}跳过: $file${NC}"
            fi
        done
        echo ""
        echo -e "${GREEN}完成! 共删除 $deleted_count 个文件。${NC}"
        ;;
    3)
        echo -e "${YELLOW}操作已取消。${NC}"
        ;;
    *)
        echo -e "${RED}无效选择。${NC}"
        exit 1
        ;;
esac
