#!/bin/bash

# 病毒组干实验Demo - 物种注释脚本
# 用途: Kraken2病毒物种注释和丰度统计

set -e

echo "=== 病毒组干实验Demo - 物种注释开始 ==="

# 检查环境
if [ "$CONDA_DEFAULT_ENV" != "viru_demo" ]; then
    echo "请先激活viru_demo环境: conda activate viru_demo"
    exit 1
fi

# 检查输入文件
INPUT_FILE="./virus_results/non_redundant_data/non_redundant_virus.fasta"
DB_PATH="./kraken_viral_db/k2_viral_20241228"

if [ ! -f "$INPUT_FILE" ]; then
    echo "输入文件不存在: $INPUT_FILE"
    echo "请先运行质控脚本: ./04_quality_control.sh"
    exit 1
fi

if [ ! -d "$DB_PATH" ]; then
    echo "Kraken2数据库不存在: $DB_PATH"
    echo "请先运行数据库下载脚本: ./02_download_database.sh"
    exit 1
fi

# 创建注释结果目录
mkdir -p ./virus_results/annotation_results

# 统计输入序列数量
INPUT_COUNT=$(grep -c ">" "$INPUT_FILE")
echo "输入序列数量: $INPUT_COUNT"

# 1. Kraken2注释
echo "开始Kraken2病毒注释..."
kraken2 \
    --db "$DB_PATH" \
    --threads 8 \
    --output ./virus_results/annotation_results/kraken_raw_out.txt \
    --report ./virus_results/annotation_results/kraken_summary_report.txt \
    --use-names \
    "$INPUT_FILE"

# 2. 提取病毒丰度统计
echo "整理病毒丰度数据..."
grep -v "unclassified" ./virus_results/annotation_results/kraken_summary_report.txt | \
awk '{print $3"\t"$5"\t"$1}' | \
sed '1d' | \
sort -k3 -rn > ./virus_results/annotation_results/virus_abundance.tsv

# 统计注释结果
TOTAL_SPECIES=$(wc -l < ./virus_results/annotation_results/virus_abundance.tsv)
TOP_VIRUS=$(head -1 ./virus_results/annotation_results/virus_abundance.tsv | cut -f2)
PHAGE_COUNT=$(grep -i "phage" ./virus_results/annotation_results/virus_abundance.tsv | wc -l)

echo "=== 注释结果统计 ==="
echo "注释到病毒种类数: $TOTAL_SPECIES"
echo "丰度最高病毒: $TOP_VIRUS"
echo "噬菌体种类数: $PHAGE_COUNT"

# 3. 生成简要统计报告
echo "生成统计报告..."
cat > ./virus_results/annotation_results/annotation_summary.txt << EOF
病毒组物种注释统计报告
====================

1. 输入序列信息:
   - 去冗余序列数量: $INPUT_COUNT

2. 注释结果:
   - 注释到病毒种类数: $TOTAL_SPECIES
   - 丰度最高病毒: $TOP_VIRUS
   - 噬菌体种类数: $PHAGE_COUNT

3. 输出文件:
   - Kraken2原始结果: kraken_raw_out.txt
   - Kraken2汇总报告: kraken_summary_report.txt
   - 病毒丰度表格: virus_abundance.tsv

EOF

echo "=== 物种注释完成 ==="
echo "注释报告: ./virus_results/annotation_results/kraken_summary_report.txt"
echo "丰度表格: ./virus_results/annotation_results/virus_abundance.tsv"
echo "统计报告: ./virus_results/annotation_results/annotation_summary.txt"