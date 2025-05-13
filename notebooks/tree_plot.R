# 安装必要的包（如果还没装）
#install.packages(c("ggtree", "treeio", "ape", "data.tree", "tidyverse"))

# 📦 加载必要的包
library(tidyverse)
library(data.tree)
library(ape)
library(ggtree)
library(treeio)

# 1️⃣ 读取 taxonomy 表
taxonomy <- read.csv("data/gtdb_taxonomy.tsv", sep = "\t", stringsAsFactors = FALSE)

# 2️⃣ 处理 family 列，合并缺失值和稀有 family 为 "Other"
# 统计每个 family 出现次数
family_counts <- taxonomy %>%
  count(family, name = "count")

# 设定阈值，比如出现次数小于 5 的归为 "Other"
rare_families <- family_counts %>%
  filter(is.na(family) | count < 5) %>%
  pull(family)

# 更新 taxonomy，把稀有和 NA 的 family 归为 "Other"
taxonomy <- taxonomy %>%
  mutate(family = ifelse(is.na(family) | family %in% rare_families, "Other", family))

# 3️⃣ 构造 pathString（用于 data.tree）
taxonomy$pathString <- paste("Life", 
                             taxonomy$Domain,
                             taxonomy$phylum,
                             taxonomy$class,
                             taxonomy$order,
                             taxonomy$family,
                             taxonomy$genus,
                             taxonomy$user_genome,  # 叶节点是 MAG
                             sep = "/")

# 4️⃣ 创建 data.tree 节点对象并转换为 phylo 树
tree_node <- as.Node(taxonomy)
phylo_tree <- as.phylo(tree_node)

# 5️⃣ 准备 tip 信息（为每个 MAG 叶子打上 family 标签）
tip_df <- data.frame(label = phylo_tree$tip.label)

tip_df <- tip_df %>%
  left_join(taxonomy %>% select(user_genome, family),
            by = c("label" = "user_genome"))

# 补充 NA（保险起见）
tip_df$family[is.na(tip_df$family)] <- "Other"

# 6️⃣ 绘制圆形分类树
#p_tree <- ggtree(phylo_tree, layout = "circular", size = 0.6) %<+% tip_df +
  geom_tiplab(aes(color = family), size = 2, offset = 0.01) +
  scale_color_brewer(palette = "Set3") +
  theme(legend.position = "right") +
  ggtitle("Circular Taxonomic Tree")

print(p_tree)

p <- ggtree(phylo_tree, layout = "circular", size = 0.6) %<+% tip_df +
  geom_tippoint(aes(color = family), size = 2) +
  scale_color_brewer(palette = "Set3") +
  theme(legend.position = "right",hjust = 0.5) +
  ggtitle("Circular Taxonomic Tree") +
    theme(
      legend.position = "right",
      plot.title = element_text(hjust = 0.5, size = 16, face = "bold")  # ✅ 关键：标题居中
    )

print(p)

# 8️⃣ （可选）保存图到文件
#ggsave("circular_tree_by_family.png", plot = p_tree, width = 10, height = 10, dpi = 300)
