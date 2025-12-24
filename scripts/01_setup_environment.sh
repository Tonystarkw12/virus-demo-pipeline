#!/bin/bash

# 病毒组干实验Demo - 环境设置脚本
# 作者: iFlow CLI
# 用途: 创建conda环境并安装所有必要工具

set -e  # 遇到错误立即退出

echo "=== 病毒组干实验Demo - 环境设置开始 ==="

# 获取当前工作目录
WORK_DIR=$(pwd)
echo "当前工作目录: $WORK_DIR"

# 1. 检查conda是否已安装
if ! command -v conda &> /dev/null; then
    echo "conda未安装，请先安装conda"
    echo "推荐安装方式："
    echo "wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
    echo "bash Miniconda3-latest-Linux-x86_64.sh"
    exit 1
else
    echo "conda已安装，版本信息:"
    conda --version
fi

# 2. 创建病毒组demo专属环境
echo "创建viru_demo环境..."
conda create -n viru_demo -y python=3.9

# 3. 激活环境并安装工具
echo "激活viru_demo环境并安装核心工具..."
source activate viru_demo

# 安装核心生物信息学工具
conda install -y fastp cd-hit kraken2 multiqc

# 安装R语言及必要包
conda install -y r-base r-ggplot2 r-dplyr r-tidyr

# 安装SRA工具（备用下载方式）
conda install -y sra-tools

echo "=== 环境设置完成 ==="
echo "请使用以下命令激活环境:"
echo "conda activate viru_demo"