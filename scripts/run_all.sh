#!/bin/bash

# 病毒组干实验Demo - 完整流程执行脚本
# 用途: 一键执行所有分析步骤

set -e

echo "=== 病毒组干实验Demo - 完整分析流程开始 ==="
echo "开始时间: $(date)"

# 获取当前工作目录
WORK_DIR=$(pwd)
echo "工作目录: $WORK_DIR"

# 1. 环境设置
echo "=== 步骤1: 环境设置 ==="
if [ "$CONDA_DEFAULT_ENV" != "viru_demo" ]; then
    echo "请先激活环境: conda activate viru_demo"
    echo "然后重新运行此脚本"
    exit 1
fi

# 2. 数据库下载
echo "=== 步骤2: 数据库下载 ==="
if [ ! -d "./kraken_viral_db/k2_viral_20241228" ]; then
    bash ./scripts/02_download_database.sh
else
    echo "数据库已存在，跳过下载"
fi

# 3. 数据下载
echo "=== 步骤3: 数据下载 ==="
if [ ! -f "./virus_data/input_virus.fasta" ]; then
    bash ./scripts/03_download_data.sh
else
    echo "数据文件已存在，跳过下载"
fi

# 4. 质控与去冗余
echo "=== 步骤4: 质控与去冗余 ==="
bash ./scripts/04_quality_control.sh

# 5. 物种注释
echo "=== 步骤5: 物种注释 ==="
bash ./scripts/05_annotation.sh

# 6. 可视化（需要手动运行R脚本）
echo "=== 步骤6: 数据可视化 ==="
echo "请手动运行R可视化脚本:"
echo "Rscript ./scripts/06_visualization.R"

# 7. 生成最终报告
echo "=== 步骤7: 生成分析报告 ==="
echo "请参考 ./reports/report_template.md 填写分析报告"

echo "=== 完整分析流程完成 ==="
echo "结束时间: $(date)"

# 生成结果清单
echo "=== 结果文件清单 ==="
echo "质控报告:"
[ -f "./virus_results/clean_data/fastp_qc.html" ] && echo "  - ./virus_results/clean_data/fastp_qc.html"
[ -f "./virus_results/multiqc_report.html" ] && echo "  - ./virus_results/multiqc_report.html"

echo "序列文件:"
[ -f "./virus_results/clean_data/clean_virus.fasta" ] && echo "  - ./virus_results/clean_data/clean_virus.fasta"
[ -f "./virus_results/non_redundant_data/non_redundant_virus.fasta" ] && echo "  - ./virus_results/non_redundant_data/non_redundant_virus.fasta"

echo "注释结果:"
[ -f "./virus_results/annotation_results/kraken_summary_report.txt" ] && echo "  - ./virus_results/annotation_results/kraken_summary_report.txt"
[ -f "./virus_results/annotation_results/virus_abundance.tsv" ] && echo "  - ./virus_results/annotation_results/virus_abundance.tsv"

echo "可视化图表:"
[ -f "./virus_results/top10_virus_abundance.pdf" ] && echo "  - ./virus_results/top10_virus_abundance.pdf"
[ -f "./virus_results/virus_type_proportion.pdf" ] && echo "  - ./virus_results/virus_type_proportion.pdf"

echo ""
echo "所有脚本执行完成！请运行R脚本进行可视化，并参考报告模板撰写最终报告。"