library(data.table)
library(ggplot2)

# 1. Créer une matrice présence/absence pour chaque orthogroupe
og_presence <- pangene_matrix[, .(
  Are_6 = any(lengths(Are_6) > 0),
  Est_0 = any(lengths(Est_0) > 0),
  Etna_2 = any(lengths(Etna_2) > 0),
  Had_6b = any(lengths(Had_6b) > 0),
  TAIR10 = any(lengths(TAIR10) > 0)
), by = og]

# 2. Compter dans combien d'accessions chaque orthogroupe est présent
og_presence[, n_accessions := rowSums(.SD), .SDcols = c("Are_6", "Est_0", "Etna_2", "Had_6b", "TAIR10")]

# 3. Statistiques globales
cat("=== DISTRIBUTION DES ORTHOGROUPES ===\n")
table(og_presence$n_accessions)

# 4. Core genome (présent dans les 5 accessions)
core_og <- og_presence[n_accessions == 5, .N]
cat("\nCore genome (5/5 accessions):", core_og, "orthogroupes\n")

# 5. Orthogroupes uniques à chaque accession
unique_og <- og_presence[n_accessions == 1, .(
  Are_6_unique = sum(Are_6),
  Est_0_unique = sum(Est_0),
  Etna_2_unique = sum(Etna_2),
  Had_6b_unique = sum(Had_6b),
  TAIR10_unique = sum(TAIR10)
)]
print(unique_og)

# 6. Orthogroupes partagés avec TAIR10 (référence)
shared_with_ref <- og_presence[TAIR10 == TRUE, .N]
cat("\nOrthogroupes présents dans TAIR10:", shared_with_ref, "\n")

# 7. Pour chaque accession : combien partagés avec TAIR10, combien uniques
accession_summary <- data.table(
  Accession = c("Are_6", "Est_0", "Etna_2", "Had_6b"),
  Total = c(
    og_presence[Are_6 == TRUE, .N],
    og_presence[Est_0 == TRUE, .N],
    og_presence[Etna_2 == TRUE, .N],
    og_presence[Had_6b == TRUE, .N]
  ),
  Shared_with_TAIR10 = c(
    og_presence[Are_6 == TRUE & TAIR10 == TRUE, .N],
    og_presence[Est_0 == TRUE & TAIR10 == TRUE, .N],
    og_presence[Etna_2 == TRUE & TAIR10 == TRUE, .N],
    og_presence[Had_6b == TRUE & TAIR10 == TRUE, .N]
  ),
  Unique_to_accession = c(
    og_presence[Are_6 == TRUE & TAIR10 == FALSE, .N],
    og_presence[Est_0 == TRUE & TAIR10 == FALSE, .N],
    og_presence[Etna_2 == TRUE & TAIR10 == FALSE, .N],
    og_presence[Had_6b == TRUE & TAIR10 == FALSE, .N]
  )
)

print(accession_summary)

# 8. Graphique - Distribution de la présence des orthogroupes
ggplot(og_presence, aes(x = n_accessions)) +
  geom_bar(fill = "steelblue") +
  theme_minimal(base_size = 14) +
  xlab("Number of Accessions Containing Orthogroup") +
  ylab("Count of Orthogroups") +
  ggtitle("Distribution of Orthogroup Presence Across Accessions") +
  scale_x_continuous(breaks = 1:5)

