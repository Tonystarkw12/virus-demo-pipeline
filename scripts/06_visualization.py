#!/usr/bin/env python3
"""
病毒组数据可视化脚本 - Python版本
生成病毒丰度柱状图和类型占比饼图
"""

import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

# 设置中文字体
plt.rcParams['font.sans-serif'] = ['DejaVu Sans', 'SimHei']
plt.rcParams['axes.unicode_minus'] = False

print("=== 病毒组干实验Demo - 数据可视化开始 ===")

# 读取病毒丰度数据
print("读取病毒丰度数据...")
try:
    df = pd.read_csv('./virus_results/annotation_results/virus_abundance.tsv', 
                    sep='\t', header=None, 
                    names=['Abundance', 'Virus_Name', 'Percentage'])
except FileNotFoundError:
    print("错误：找不到病毒丰度数据文件")
    exit(1)

# 数据预处理：取前10种高丰度病毒
print("数据预处理...")
top10 = df.head(10)

# 图表1：前10种病毒丰度柱状图（横向）
print("生成前10种病毒丰度柱状图...")
plt.figure(figsize=(10, 8))
bars = plt.barh(range(len(top10)), top10['Abundance'], color='#2E86AB', alpha=0.8)
plt.yticks(range(len(top10)), top10['Virus_Name'])
plt.xlabel('Sequence Abundance')
plt.title('Top 10 Viral Species Abundance in Human Gut Virome', fontsize=14, fontweight='bold')
plt.gca().invert_yaxis()  # 最高丰度在顶部

# 添加数值标签
for i, (bar, value) in enumerate(zip(bars, top10['Abundance'])):
    plt.text(bar.get_width() + max(top10['Abundance'])*0.01, bar.get_y() + bar.get_height()/2, 
             f'{value}', va='center', fontsize=10)

plt.tight_layout()
plt.savefig('./virus_results/top10_virus_abundance.pdf', dpi=300, bbox_inches='tight')
plt.savefig('./virus_results/top10_virus_abundance.png', dpi=300, bbox_inches='tight')
plt.close()

# 图表2：病毒类型占比饼图
print("生成病毒类型占比饼图...")

# 分类：含"phage"的为噬菌体，其余为其他病毒
df['Virus_Type'] = df['Virus_Name'].apply(lambda x: 'Bacteriophage' if 'phage' in x.lower() else 'Other Viruses')

# 统计各类型总丰度
type_counts = df.groupby('Virus_Type')['Abundance'].sum()
percentages = type_counts / type_counts.sum() * 100

# 绘制饼图
plt.figure(figsize=(8, 8))
colors = ['#FF9999', '#66B2FF']
explode = (0.05, 0)  # 突出第一部分

wedges, texts, autotexts = plt.pie(percentages, labels=type_counts.index, autopct='%1.1f%%', 
                                  colors=colors, explode=explode, startangle=90)

# 美化文字
for autotext in autotexts:
    autotext.set_color('white')
    autotext.set_fontweight('bold')
    autotext.set_fontsize(12)

for text in texts:
    text.set_fontsize(12)

plt.title('Viral Type Proportion in Human Gut Virome', fontsize=14, fontweight='bold')
plt.axis('equal')  # 保证饼图是圆形

plt.savefig('./virus_results/virus_type_proportion.pdf', dpi=300, bbox_inches='tight')
plt.savefig('./virus_results/virus_type_proportion.png', dpi=300, bbox_inches='tight')
plt.close()

# 生成统计报告
print("生成可视化统计报告...")
with open('./virus_results/visualization_summary.txt', 'w', encoding='utf-8') as f:
    f.write("病毒组数据可视化统计报告\n")
    f.write("========================\n\n")
    f.write("1. 数据概览:\n")
    f.write(f"   - 病毒种类总数: {len(df)}\n")
    f.write("   - 前10种病毒展示在柱状图中\n\n")
    
    f.write("2. 病毒类型分布:\n")
    for virus_type, count in type_counts.items():
        percentage = percentages[virus_type]
        f.write(f"   - {virus_type}: {count} ({percentage:.1f}%)\n")
    f.write("\n")
    
    f.write("3. 前10种高丰度病毒:\n")
    for i, (_, row) in enumerate(top10.iterrows(), 1):
        f.write(f"   {i}. {row['Virus_Name']}: {row['Abundance']}\n")
    f.write("\n")
    
    f.write("4. 输出图表:\n")
    f.write("   - 前10病毒丰度柱状图: top10_virus_abundance.pdf/png\n")
    f.write("   - 病毒类型占比饼图: virus_type_proportion.pdf/png\n")

print("=== 数据可视化完成 ===")
print("输出文件:")
print("  - 柱状图: ./virus_results/top10_virus_abundance.pdf")
print("  - 饼图: ./virus_results/virus_type_proportion.pdf")
print("  - 统计报告: ./virus_results/visualization_summary.txt")
print("\n可视化分析完成！可以查看生成的图表和统计报告。")