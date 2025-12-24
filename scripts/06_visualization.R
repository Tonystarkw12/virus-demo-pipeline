#!/usr/bin/env Rscript

# 病毒组干实验Demo - 数据可视化脚本
# 用途: 生成病毒丰度柱状图和类型占比饼图

# 加载必要的包
suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tidyr)
})

cat("=== 病毒组干实验Demo - 数据可视化开始 ===\n")

# 设置工作目录
setwd("./")

# 检查输入文件
input_file <- "./virus_results/annotation_results/virus_abundance.tsv"
if (!file.exists(input_file)) {
  stop("输入文件不存在: ", input_file, "\n请先运行物种注释脚本: ./05_annotation.sh")
}

# 读取病毒丰度数据
cat("读取病毒丰度数据...\n")
virus_abund <- read.delim(input_file, 
                         header = FALSE, 
                         col.names = c("Abundance", "Virus_Name", "Percentage"))

# 数据预处理：取前10种高丰度病毒
cat("数据预处理...\n")
top10_virus <- virus_abund[1:10, ]

# 图表1：前10种病毒丰度柱状图（横向）
cat("生成前10种病毒丰度柱状图...\n")
p1 <- ggplot(top10_virus, aes(x = reorder(Virus_Name, Abundance), y = Abundance)) +
  geom_col(fill = "#2E86AB", alpha = 0.8) +
  coord_flip() +
  labs(title = "Top 10 Viral Species Abundance in Human Gut Virome",
       x = "Viral Species",
       y = "Sequence Abundance") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 12, face = "bold"),
        axis.text = element_text(size = 8),
        axis.text.y = element_text(vjust = 0.5))

# 保存柱状图
ggsave("./virus_results/top10_virus_abundance.pdf", 
       plot = p1, 
       width = 8, 
       height = 6, 
       dpi = 300)

# 同时保存为PNG格式（便于预览）
ggsave("./virus_results/top10_virus_abundance.png", 
       plot = p1, 
       width = 8, 
       height = 6, 
       dpi = 300)

# 图表2：病毒类型占比饼图
cat("生成病毒类型占比饼图...\n")

# 快速分类：含"phage"的为噬菌体，其余为其他病毒
virus_abund$Virus_Type <- ifelse(grepl("phage", tolower(virus_abund$Virus_Name)), 
                                 "Bacteriophage", 
                                 "Other Viruses")

# 统计各类型总丰度
type_abund <- virus_abund %>%
  group_by(Virus_Type) %>%
  summarise(Total_Abundance = sum(Abundance), .groups = "drop")

# 计算百分比
type_abund$Percentage <- type_abund$Total_Abundance / sum(type_abund$Total_Abundance) * 100

# 绘制饼图
p2 <- ggplot(type_abund, aes(x = "", y = Total_Abundance, fill = Virus_Type)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y", start = 0) +
  labs(title = "Viral Type Proportion in Human Gut Virome",
       fill = "Viral Type") +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5, size = 12, face = "bold"))

# 添加百分比标签
p2 <- p2 + geom_text(aes(label = paste0(round(Percentage, 1), "%")), 
                     position = position_stack(vjust = 0.5),
                     size = 4, color = "white")

# 保存饼图
ggsave("./virus_results/virus_type_proportion.pdf", 
       plot = p2, 
       width = 6, 
       height = 6, 
       dpi = 300)

# 同时保存为PNG格式（便于预览）
ggsave("./virus_results/virus_type_proportion.png", 
       plot = p2, 
       width = 6, 
       height = 6, 
       dpi = 300)

# 生成可视化统计报告
cat("生成可视化统计报告...\n")
sink("./virus_results/visualization_summary.txt")
cat("病毒组数据可视化统计报告\n")
cat("========================\n\n")
cat("1. 数据概览:\n")
cat("   - 病毒种类总数:", nrow(virus_abund), "\n")
cat("   - 前10种病毒展示在柱状图中\n\n")

cat("2. 病毒类型分布:\n")
for(i in 1:nrow(type_abund)) {
  cat("   - ", type_abund$Virus_Type[i], ": ", 
      type_abund$Total_Abundance[i], " (", 
      round(type_abund$Percentage[i], 1), "%)\n", sep = "")
}
cat("\n")

cat("3. 前10种高丰度病毒:\n")
for(i in 1:nrow(top10_virus)) {
  cat("   ", i, ". ", top10_virus$Virus_Name[i], ": ", 
      top10_virus$Abundance[i], "\n", sep = "")
}
cat("\n")

cat("4. 输出图表:\n")
cat("   - 前10病毒丰度柱状图: top10_virus_abundance.pdf/png\n")
cat("   - 病毒类型占比饼图: virus_type_proportion.pdf/png\n")
sink()

cat("=== 数据可视化完成 ===\n")
cat("输出文件:\n")
cat("  - 柱状图: ./virus_results/top10_virus_abundance.pdf\n")
cat("  - 饼图: ./virus_results/virus_type_proportion.pdf\n")
cat("  - 统计报告: ./virus_results/visualization_summary.txt\n")

cat("\n可视化分析完成！可以查看生成的图表和统计报告。\n")