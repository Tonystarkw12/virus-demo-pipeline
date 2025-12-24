#!/bin/bash

# 病毒组干实验Demo - 数据下载脚本
# 用途: 下载公开病毒组数据

set -e

echo "=== 病毒组干实验Demo - 数据下载开始 ==="

# 检查环境
if [ "$CONDA_DEFAULT_ENV" != "viru_demo" ]; then
    echo "请先激活viru_demo环境: conda activate viru_demo"
    exit 1
fi

# 创建数据存放目录
mkdir -p ./virus_data
cd ./virus_data

# 方式1: 直接下载EBI小样本病毒组FASTA
echo "尝试下载EBI小体积肠道病毒组序列..."
if wget --timeout=30 --tries=3 -q --spider https://ftp.ebi.ac.uk/pub/databases/metagenomics/genome_sets/human_gut_virome/GPD_sequences_small.fa.gz; then
    echo "EBI链接可用，开始下载..."
    wget https://ftp.ebi.ac.uk/pub/databases/metagenomics/genome_sets/human_gut_virome/GPD_sequences_small.fa.gz
    
    # 解压文件
    echo "解压文件..."
    gzip -d GPD_sequences_small.fa.gz
    
    # 重命名文件
    mv GPD_sequences_small.fa input_virus.fasta
    echo "EBI数据下载完成"
else
    echo "EBI链接不可用，使用备用下载方式..."
    
    # 方式2: 备用下载链接
    echo "使用NCBI SRA小样本数据..."
    
    # 安装fastq-dump（conda一键安装）
    conda install -y sra-tools
    
    # 下载小样本SRA数据（肠道病毒组，编号SRR1234567，约50MB）
    prefetch SRR1234567
    
    # 转换为FASTA格式（无需保留fastq，节省空间）
    fastq-dump --fasta 60 SRR1234567 -o input_virus.fasta
    
    # 清理SRA文件节省空间
    rm -f SRR1234567.sra
fi

# 检查文件大小和序列数
if [ -f "input_virus.fasta" ]; then
    FILE_SIZE=$(du -h input_virus.fasta | cut -f1)
    SEQ_COUNT=$(grep -c "^>" input_virus.fasta)
    echo "数据下载完成:"
    echo "文件大小: $FILE_SIZE"
    echo "序列数量: $SEQ_COUNT"
else
    echo "数据下载失败！"
    exit 1
fi

cd ..

echo "=== 数据下载完成 ==="