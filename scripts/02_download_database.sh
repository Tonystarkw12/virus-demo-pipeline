#!/bin/bash

# 病毒组干实验Demo - 数据库下载脚本
# 用途: 下载Kraken2预构建病毒数据库

set -e

echo "=== 病毒组干实验Demo - 数据库下载开始 ==="

# 检查环境
if [ "$CONDA_DEFAULT_ENV" != "viru_demo" ]; then
    echo "请先激活viru_demo环境: conda activate viru_demo"
    exit 1
fi

# 创建数据库存放目录
mkdir -p ./kraken_viral_db
cd ./kraken_viral_db

# 下载预构建病毒库（最新版本）
echo "下载Kraken2预构建病毒数据库..."
if [ ! -f "k2_viral_20241228.tar.gz" ]; then
    wget https://genome-idx.s3.amazonaws.com/kraken/k2_viral_20241228.tar.gz
else
    echo "数据库文件已存在，跳过下载"
fi

# 解压数据库
echo "解压数据库..."
if [ ! -d "k2_viral_20241228" ]; then
    tar -zxvf k2_viral_20241228.tar.gz
else
    echo "数据库已解压，跳过解压步骤"
fi

cd ..

echo "=== 数据库下载完成 ==="
echo "数据库大小: $(du -sh ./kraken_viral_db/k2_viral_20241228 | cut -f1)"