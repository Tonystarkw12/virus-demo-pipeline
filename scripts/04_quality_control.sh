#!/bin/bash

# 病毒组干实验Demo - 质控与去冗余脚本
# 用途: fastp质控和cd-hit去冗余

set -e

echo "=== 病毒组干实验Demo - 质控与去冗余开始 ==="

# 检查环境
if [ "$CONDA_DEFAULT_ENV" != "viru_demo" ]; then
    echo "请先激活viru_demo环境: conda activate viru_demo"
    exit 1
fi

# 检查输入文件
INPUT_FILE="./virus_data/input_virus.fasta"
if [ ! -f "$INPUT_FILE" ]; then
    echo "输入文件不存在: $INPUT_FILE"
    echo "请先运行数据下载脚本: ./03_download_data.sh"
    exit 1
fi

# 创建结果存放目录
mkdir -p ./virus_results/{clean_data,non_redundant_data}

# 统计原始序列信息
echo "=== 原始序列统计 ==="
ORIGINAL_COUNT=$(grep -c ">" "$INPUT_FILE")
echo "原始序列数量: $ORIGINAL_COUNT"

# 1. fastp质控
echo "开始fastp质控..."
fastp \
    -i "$INPUT_FILE" \
    -o ./virus_results/clean_data/clean_virus.fasta \
    -q 20 \
    -u 30 \
    -l 50 \
    --json ./virus_results/clean_data/fastp_qc.json \
    --html ./virus_results/clean_data/fastp_qc.html \
    -y

# 统计质控后序列信息
CLEAN_COUNT=$(grep -c ">" ./virus_results/clean_data/clean_virus.fasta)
CLEAN_RATE=$(echo "scale=2; $CLEAN_COUNT * 100 / $ORIGINAL_COUNT" | bc)
echo "质控后序列数量: $CLEAN_COUNT"
echo "序列保留率: $CLEAN_RATE%"

# 2. cd-hit去冗余
echo "开始cd-hit去冗余..."
cd-hit \
    -i ./virus_results/clean_data/clean_virus.fasta \
    -o ./virus_results/non_redundant_data/non_redundant_virus.fasta \
    -c 0.95 \
    -n 8 \
    -M 16000 \
    -T 8 \
    -d 0

# 统计去冗余后序列信息
NR_COUNT=$(grep -c ">" ./virus_results/non_redundant_data/non_redundant_virus.fasta)
REDUNDANT_RATE=$(echo "scale=2; ($CLEAN_COUNT - $NR_COUNT) * 100 / $CLEAN_COUNT" | bc)
echo "去冗余后序列数量: $NR_COUNT"
echo "冗余去除率: $REDUNDANT_RATE%"

# 3. MultiQC整合质控报告
echo "生成MultiQC汇总报告..."
multiqc ./virus_results/clean_data/ -o ./virus_results/

echo "=== 质控与去冗余完成 ==="
echo "质控报告: ./virus_results/clean_data/fastp_qc.html"
echo "汇总报告: ./virus_results/multiqc_report.html"
echo "去冗余序列: ./virus_results/non_redundant_data/non_redundant_virus.fasta"