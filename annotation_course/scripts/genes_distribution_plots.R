# Load libraries
library(data.table)
library(ggplot2)

# Load pangenome matrix
pangene_matrix <- readRDS("pangenome_matrix.rds")
setDT(pangene_matrix)

# Identify accession columns (genomes)
acc_cols <- c("Are_6", "Est_0", "Etna_2", "Had_6b", "TAIR10")

# Convert to binary presence/absence
pangene_binary <- pangene_matrix[, lapply(.SD, function(x) as.numeric(lengths(x) > 0)), .SDcols = acc_cols]

# Calculate presence counts
presence_counts <- rowSums(pangene_binary)
num_accessions <- length(acc_cols)

# Classify orthogroups
orthogroup_class <- ifelse(
  presence_counts == num_accessions, "Core",
  ifelse(presence_counts == 1, "Unique", "Accessory")
)

# Combine into summary table
pangenome_summary <- data.frame(
  pgID = pangene_matrix$pgID,
  repGene = pangene_matrix$repGene,
  Class = orthogroup_class,
  Presence = presence_counts
)

# Summarize counts
summary_table <- as.data.frame(table(pangenome_summary$Class))
colnames(summary_table) <- c("Category", "Orthogroup_Count")

# Print summary table
print(summary_table)


# Ajouter la classe à chaque gène via la colonne og
gene_summary <- pangene_matrix[, .(TotalGenes = .N), by = genome]
gene_summary

# Créer un résumé gènes par genome et classe
gene_summary_acc <- pangene_matrix[, .(TotalGenes = .N), by = .(genome)]

# Graphique empilé
ggplot(gene_summary_acc, aes(x = genome, y = TotalGenes)) +
  geom_col() +
  theme_minimal(base_size = 14) +
  xlab("Accession") +
  ylab("Nombre de gènes") +
  ggtitle("Distribution des gènes") +
  scale_fill_brewer(palette = "Set2")

# Compter le nombre de gènes dans chaque colonne d'accession
gene_counts <- data.table(
  genome = c("Are_6", "Est_0", "Etna_2", "Had_6b", "TAIR10"),
  TotalGenes = c(
    sum(lengths(pangene_matrix$Are_6)),
    sum(lengths(pangene_matrix$Est_0)),
    sum(lengths(pangene_matrix$Etna_2)),
    sum(lengths(pangene_matrix$Had_6b)),
    sum(lengths(pangene_matrix$TAIR10))
  )
)

# Graphique
ggplot(gene_counts, aes(x = genome, y = TotalGenes)) +
  geom_col() +
  theme_minimal(base_size = 14) +
  xlab("Accession") +
  ylab("Nombre de gènes") +
  ggtitle("Distribution des gènes")


# Optional: visualize distribution
ggplot(pangenome_summary, aes(x = Presence)) +
  geom_histogram(binwidth = 1, fill = "steelblue", color = "white") +
  theme_minimal() +
  xlab("Number of Accessions Containing Orthogroup") +
  ylab("Count of Orthogroups") +
  ggtitle("Distribution of Orthogroup Presence Across Accessions")


orthogroups <- read.delim("Orthogroups.tsv", header = TRUE, sep = "\t")
pangene_binary <- pangene_matrix[, lapply(.SD, function(x) as.numeric(lengths(x) > 0)), .SDcols = acc_cols]
presence_counts <- rowSums(pangene_binary)
num_accessions <- length(acc_cols)

orthogroup_class <- ifelse(
  presence_counts == num_accessions, "Core",
  ifelse(presence_counts == 1, "Unique", "Accessory")
)

pangenome_summary <- data.frame(
  pgID = pangene_matrix$pgID,
  repGene = pangene_matrix$repGene,
  Class = orthogroup_class,
  Presence = presence_counts
)

gene_counts <- orthogroups %>%
  pivot_longer(-Orthogroup, names_to = "Accession", values_to = "Gene") %>%
  filter(Gene != "" & !is.na(Gene)) %>%
  mutate(GeneCount = sapply(strsplit(Gene, ",\\s*"), length)) %>%
  group_by(Orthogroup) %>%
  summarise(TotalGenes = sum(GeneCount))

gene_counts <- gene_counts %>%
  rename(og = Orthogroup) %>%
  left_join(pangene_matrix[, .(pgID, og)], by = "og") %>%
  left_join(pangenome_summary[, c("pgID", "Class")], by = "pgID")

gene_summary <- gene_counts %>%
  group_by(Class) %>%
  summarise(TotalGenes = sum(TotalGenes, na.rm = TRUE))

gene_summary
orthogroup_summary <- as.data.frame(table(pangenome_summary$Class))
colnames(orthogroup_summary) <- c("Category", "Orthogroup_Count")

summary_table <- merge(orthogroup_summary, gene_summary, by.x = "Category", by.y = "Class", all.x = TRUE)
summary_table

library(ggplot2)

ggplot(summary_table, aes(x = Category, y = TotalGenes, fill = Category)) +
  geom_col(show.legend = FALSE) +
  theme_minimal() +
  ylab("Nombre total de gènes") +
  xlab("Catégorie d'orthogroupe") +
  ggtitle("Distribution des gènes par catégorie (Core / Accessory / Unique)")

library(dplyr)

# Repartons de ton objet gene_counts correct
gene_counts <- orthogroups %>%
  tidyr::pivot_longer(-Orthogroup, names_to = "Accession", values_to = "Gene") %>%
  filter(Gene != "" & !is.na(Gene)) %>%
  mutate(GeneCount = sapply(strsplit(Gene, ",\\s*"), length)) %>%
  group_by(Orthogroup) %>%
  summarise(TotalGenes = sum(GeneCount))

# Maintenant on fait les jointures
gene_counts <- gene_counts %>%
  rename(og = Orthogroup) %>%
  left_join(pangene_matrix[, .(pgID, og)], by = "og") %>%
  left_join(pangenome_summary[, c("pgID", "Class")], by = "pgID")



