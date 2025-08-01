# bonjour
library(arrow)
library(tidyverse)
library(pheatmap)
library(ComplexHeatmap)
library(circlize)
library(ggplot2)

# ====================== read data ======================
# Coverage Matrix
parquet_path <- "data/genome/median_coverage_genomes.parquet"
coverage_df <- read_parquet(parquet_path)
coverage_matrix <- coverage_df %>%
  column_to_rownames("index") %>%
  as.matrix()

# read annotation
anno <- read.delim("data/class_anno/annotations.tsv", sep = "\t", header = TRUE)

# ====================== build KO × MAG matrix ======================
ko_table <- anno %>%
  filter(!is.na(ko_id) & ko_id != "") %>%
  group_by(fasta, ko_id) %>%
  summarise(count = n(), .groups = "drop") %>%
  pivot_wider(names_from = ko_id, values_from = count, values_fill = 0)

print(ko_table[1:5, 1:5])

# change to matrix，MAG/KO
mag_ko_matrix <- ko_table %>%
  column_to_rownames("fasta") %>%
  as.matrix()

# ====================== build sample × KO matrix ======================
common_mags <- intersect(rownames(mag_ko_matrix), colnames(coverage_matrix))
coverage_sub <- coverage_matrix[, common_mags]
mag_ko_sub <- mag_ko_matrix[common_mags, ]
# sample × MAG * MAG × KO → sample × KO
sample_ko_matrix <- as.matrix(coverage_sub) %*% mag_ko_sub

# ====================== anode/cathode dict ====================== 
meta_df <- data.frame(
  MAGLab_Name = c(
    "R1J142A", "R2J142A", "R3J142A", "R4J147A", "R5J141A", "R6J143A",
    "R4J147C", "R5J141C", "R6J143C",
    "Sg1AJ36C", "Sg1BJ36C", "Sg1CJ36C",
    "NSg1AJ41C", "NSg1BJ41C", "NSg1CJ41C"
  ),
  Compartment = c(
    rep("Anode", 6),
    rep("Cathode", 9)
  ),
  stringsAsFactors = FALSE
)
# build mag dict for anode/cathode
sample_to_polarity <- setNames(meta_df$Compartment, meta_df$MAGLab_Name)
build_mag_polarity_dict <- function(coverage_matrix) {
  sapply(colnames(coverage_matrix), function(mag) {
    samples_present <- rownames(coverage_matrix)[coverage_matrix[, mag] > 0]
    polarities <- sample_to_polarity[samples_present]
    polarities <- polarities[!is.na(polarities)]
    if (length(polarities) == 0) return(NA)
    return(names(which.max(table(polarities))))
  })
}

# ====================== Heatmap  ======================
top_kos <- names(sort(colMeans(sample_ko_matrix), decreasing = TRUE)[1:50])
mat <- log1p(sample_ko_matrix[, top_kos])
mat_mean <- median(mat)
mat_sd <- sd(mat)

Heatmap(mat,
        name = "Abundance",
        col = colorRamp2(c(mat_mean - mat_sd, mat_mean, mat_mean + mat_sd),
                         c("blue", "white", "red")),
        cluster_rows = TRUE,
        cluster_columns = TRUE,
        row_names_gp = gpar(fontsize = 6),
        show_column_names = FALSE,
        #column_names_gp = gpar(fontsize = 3, facing = "vertical"),
        heatmap_legend_param = list(title = "log1p Abundance"),
        column_title = "Top 50 KO")


# -------- Electrogenic KO annotations --------
# pilA - K02652: Type IV pili structural protein
#  - Function: Forms conductive pili (nanowires) for long-range extracellular electron transfer (EET)
#  - Microorganism: Geobacter sulfurreducens
#  - DOI: 10.1128/JB.06366-11 
# pilB - K02653: Type IV pili assembly ATPase
#  - Function: Powers pili extension/retraction

# mtrA - K05912: Decaheme cytochrome in Mtr complex
# mtrB - K05913: Outer membrane anchor protein in Mtr complex
# mtrC - K05914: Terminal outer membrane cytochrome
#  - Function: Forms MtrABC complex for transmembrane electron transfer to extracellular acceptors
#  - DOI: 10.1038/s41579-019-0173-x
#  - https://doi.org/10.1128/AEM.01941-20

# nuoA - K00330, nuoB - K00331, nuoC - K00332: NADH:quinone oxidoreductase subunits
#  - Function: Electron transport complex I; mediates intracellular electron flow
#  - Microorganism: Pseudomonas aeruginosa and others
#  - Note: Indirectly contributes to electron availability for EET
#  - Evidence: DOI: 10.3389/fmicb.2019.00075 (PMID: 30815045)
# ---------------------------------------------

# ====================== Nidec KO Annotation and Screening  ======================
electro_KOs <- c("K02652", "K02653", "K05912", "K05913", "K05914", "K00330", "K00331", "K00332")

electrogenic_mags <- ko_table %>%
  pivot_longer(-fasta, names_to = "KO", values_to = "count") %>%
  filter(KO %in% electro_KOs & count > 1) %>%
  distinct(fasta)

# ====================== Annotation classification  ======================
tax <- read.delim("data/class_anno/gtdb_taxonomy.tsv", sep = "\t")
#electro_taxa <- left_join(electrogenic_mags, tax, by = c("fasta" = "user_genome"))
electro_taxa <- left_join(electrogenic_mags, tax, by = c("fasta" = "user_genome")) %>%
  mutate(genus = ifelse(is.na(genus) | genus == "", "None", genus))
print(electro_taxa)

# ====================== Calculate Spearman competition correlation for Geobacter  ======================
electro_abund <- coverage_matrix[, electrogenic_mags$fasta, drop = FALSE]
geo_id <- electro_taxa %>%
  filter(str_detect(genus, "Geobacter")) %>%
  pull(fasta)

if (length(geo_id) > 0) {
  geo_vec <- electro_abund[, geo_id[1]]
  cor_res <- apply(electro_abund, 2, function(x) cor(x, geo_vec, method = "spearman"))
  cor_df <- data.frame(MAG = names(cor_res), Spearman = cor_res) %>%
    left_join(tax, by = c("MAG" = "user_genome")) %>%
    arrange(Spearman)

  print(cor_df)
}
# select anode sample
mag_polarity <- build_mag_polarity_dict(coverage_matrix)

# select data
cor_df <- data.frame(MAG = names(cor_res), Spearman = cor_res) %>%
  left_join(tax, by = c("MAG" = "user_genome")) %>%
  filter(MAG != geo_id[1]) %>%                          
  mutate(Polarity = mag_polarity[MAG]) %>%
  #filter(Polarity != "Cathode") %>%
  filter(Spearman >= 0) %>% ########filter########                        
  mutate(Genus = ifelse(is.na(genus), "Unknown", genus)) %>%
  arrange(Spearman)
 


# ====================== plot  ======================
cor_df %>%
  mutate(Genus = ifelse(is.na(genus) | genus == "", "Unknown", genus)) %>%
  top_n(-10, Spearman) %>%
  ggplot(aes(x = reorder(MAG, Spearman), y = Spearman, fill = Genus)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  theme_minimal() +
  labs(title = "Positively related MAGs",
       y = "Spearman correlation", x = "MAG ID", fill = "Genus")


# -------- Wood-Ljungdahl Pathway check--------
woodljungdahl_core_kos <- c(
  "K00198",  # CO₂ → HCOOH
  "K00600",  # HCOOH + THF → formyl-THF
  "K00297",  # ormyl-THF → methylene-THF
  "K01491",  # methylene-THF → methyl-THF
  "K00194",  # CO₂ → CO
  "K00197"   # CO + CH₃- + CoA → acetyl-CoA
)

kos_present <- intersect(woodljungdahl_core_kos, colnames(mag_ko_matrix))
mag_has_all <- rowSums(mag_ko_matrix[, kos_present, drop = FALSE] > 0) == length(kos_present)
mags_with_all <- rownames(mag_ko_matrix)[mag_has_all]
# at least one reaction
mag_has_any <- rowSums(mag_ko_matrix[, kos_present, drop = FALSE] > 0) >= 1
mags_with_any <- rownames(mag_ko_matrix)[mag_has_any]

# Get all cathode sample names
cathode_samples <- names(sample_to_polarity)[sample_to_polarity == "Cathode"]

# check MAG in cathode
mags_in_cathode <- mags_with_all[sapply(mags_with_all, function(mag) {
  any(coverage_matrix[cathode_samples, mag] > 0, na.rm = TRUE)
})]

# output
mags_with_all <- mags_in_cathode  
print(mags_with_all)

# count
cat("number of MAG：", length(mags_with_all), "\n")

#output at least one
mags_with_any <- mags_in_cathode
print(mags_with_any)
cat("Number of MAGs with at least 1 WLP KO in cathode:", length(mags_with_any), "\n")
