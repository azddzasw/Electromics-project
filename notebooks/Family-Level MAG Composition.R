library(ggplot2)
library(tidyverse)

# Step 1: 读取丰度数据（宽格式）
wide_df <- read.csv("data/relative_abundance.csv", 
                    sep = ",", stringsAsFactors = FALSE)
colnames(wide_df)[1] <- "Sample"  # 重命名第一列为 Sample

# Step 2: 转换为长格式
long_df <- pivot_longer(wide_df,
                        cols = starts_with("MAG"),
                        names_to = "MAG_ID",
                        values_to = "abundance")

# 🔍 Step 3: 统计每个 MAG 总丰度，筛选前 20 高丰度的 MAG
top_MAGs <- long_df %>%
  group_by(MAG_ID) %>%
  summarise(total_abundance = sum(abundance)) %>%
  arrange(desc(total_abundance)) %>%
  slice_head(n = 10) %>%
  pull(MAG_ID)

# 🧠 Step 4: 合并低丰度 MAG 为 "Others"
long_df <- long_df %>%
  mutate(MAG_ID = ifelse(MAG_ID %in% top_MAGs, MAG_ID, "Others"))

# 🧹 Step 5: 重新聚合合并后的 abundance
plot_df <- long_df %>%
  group_by(Sample, MAG_ID) %>%
  summarise(abundance = sum(abundance), .groups = "drop")

# 🔗 Step 6: 读取分类表，并提取 MAG → family 的映射关系
taxonomy <- read.csv("data/gtdb_taxonomy.tsv", sep = "\t", stringsAsFactors = FALSE)
mag2family <- taxonomy %>% select(user_genome, family)

# 🔄 Step 7: 替换 MAG_ID 为对应的 family
plot_df_labeled_family <- plot_df %>%
  left_join(mag2family, by = c("MAG_ID" = "user_genome")) %>%
  mutate(family = ifelse(is.na(family), "Others", family))  # 如果找不到则归为 Others

# 📊 Step 8: 按 family 聚合 abundance
plot_df_family <- plot_df_labeled_family %>%
  group_by(Sample, family) %>%
  summarise(abundance = sum(abundance), .groups = "drop")

# 🎨 Step 9: 绘制 family-level 堆积柱状图
p_family <- ggplot(plot_df_family, aes(x = Sample, y = abundance, fill = family)) +
  geom_bar(stat = "identity") +
  theme_minimal(base_size = 12) +
  labs(title = "Family-Level MAG Composition per Sample", 
       x = "Sample", y = "Relative Abundance") +
  scale_fill_brewer(palette = "Set3") +  # 适合分类较多
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
    axis.text.y = element_text(size = 10),
    legend.position = "bottom",
    legend.key.size = unit(0.4, "cm"),
    legend.text = element_text(size = 9),
    legend.title = element_blank(),
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    plot.margin = margin(1, 1, 1, 1, "cm")
  ) +
  guides(fill = guide_legend(nrow = 3, byrow = TRUE))

# ✅ 显示图形
print(p_family)

# 💾 可选：保存图像
#ggsave("family_composition_barplot.png", plot = p_family, width = 14, height = 8, dpi = 300)

