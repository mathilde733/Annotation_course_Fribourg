# =============================================================================
# Analyse de la Distribution AED par Catégorie de Qualité
# =============================================================================

library(ggplot2)
library(dplyr)

# -----------------------------------------------------------------------------
# 1. Charger les données AED
# -----------------------------------------------------------------------------

# Lecture du fichier AED généré par MAKER
aed_data <- read.table("assembly.all.maker.renamed.gff.AED.txt", 
                       header = TRUE, 
                       sep = "\t")

# Afficher un aperçu des données
head(aed_data)
cat("Nombre total d'observations:", nrow(aed_data), "\n")

# -----------------------------------------------------------------------------
# 2. Calculer les proportions par catégorie de qualité
# -----------------------------------------------------------------------------

# Fonction pour calculer le pourcentage d'annotations dans chaque catégorie
calculate_quality_categories <- function(data) {
  
  # Extraire les valeurs CDF pour les seuils clés
  cdf_0.1 <- data$ERR11437317.asm.bp.p_ctg.all.maker.noseq.gff.renamed.gff[data$AED == 0.1]
  cdf_0.25 <- data$ERR11437317.asm.bp.p_ctg.all.maker.noseq.gff.renamed.gff[data$AED == 0.25]
  cdf_0.5 <- data$ERR11437317.asm.bp.p_ctg.all.maker.noseq.gff.renamed.gff[data$AED == 0.5]
  cdf_1.0 <- 1.0  # Par définition
  
  # Calculer les pourcentages par catégorie
  excellent <- cdf_0.1 * 100
  very_good <- (cdf_0.25 - cdf_0.1) * 100
  good <- (cdf_0.5 - cdf_0.25) * 100
  weak <- (cdf_1.0 - cdf_0.5) * 100
  
  # Créer un data frame avec les résultats
  quality_df <- data.frame(
    Categorie = c("Excellent\n(AED ≤ 0.1)", 
                  "Very good\n(0.1 < AED ≤ 0.25)", 
                  "Good\n(0.25 < AED ≤ 0.5)", 
                  "Weak\n(AED > 0.5)"),
    Pourcentage = c(excellent, very_good, good, weak),
    Couleur = c("#22c55e", "#84cc16", "#eab308", "#ef4444"),
    Ordre = 1:4
  )
  
  return(quality_df)
}

quality_categories <- calculate_quality_categories(aed_data)

# Afficher le tableau
print(quality_categories)

# -----------------------------------------------------------------------------
# 3. Créer le graphique en barres horizontales
# -----------------------------------------------------------------------------

# Réordonner les catégories pour l'affichage
quality_categories$Categorie <- factor(quality_categories$Categorie, 
                                       levels = rev(quality_categories$Categorie))

# Créer le graphique
p1 <- ggplot(quality_categories, aes(x = Categorie, y = Pourcentage, fill = Categorie)) +
  geom_bar(stat = "identity", width = 0.7) +
  geom_text(aes(label = sprintf("%.1f%%", Pourcentage)), 
            hjust = -0.1, size = 5, fontface = "bold") +
  scale_fill_manual(values = rev(quality_categories$Couleur)) +
  coord_flip() +
  labs(title = "Distribution of Annotations by AED Quality Category",
       subtitle = "A. thaliana",
       x = "",
       y = "Percentage (%)") +
  theme_minimal(base_size = 14) +
  theme(legend.position = "none",
        plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5, color = "gray40"),
        panel.grid.major.y = element_blank(),
        axis.text.y = element_text(size = 12),
        axis.text.x = element_text(size = 11)) +
  scale_y_continuous(limits = c(0, max(quality_categories$Pourcentage) * 1.15),
                     expand = c(0, 0))

# Afficher le graphique
print(p1)

# Sauvegarder
ggsave("AED_quality_categories_barplot.pdf", p1, width = 10, height = 6)

# -----------------------------------------------------------------------------
# 4. Variante : Graphique en camembert (pie chart)
# -----------------------------------------------------------------------------

p2 <- ggplot(quality_categories, aes(x = "", y = Pourcentage, fill = Categorie)) +
  geom_bar(stat = "identity", width = 1, color = "white", size = 2) +
  coord_polar("y", start = 0) +
  scale_fill_manual(values = quality_categories$Couleur) +
  geom_text(aes(label = sprintf("%.1f%%", Pourcentage)),
            position = position_stack(vjust = 0.5),
            size = 5, fontface = "bold", color = "white") +
  labs(title = "Distribution of AED Annotation Quality",
       subtitle = "A. thaliana",
       fill = "Catégory") +
  theme_void(base_size = 14) +
  theme(plot.title = element_text(face = "bold", size = 16, hjust = 0.5, margin = margin(b = 5)),
        plot.subtitle = element_text(hjust = 0.5, color = "gray40", margin = margin(b = 15)),
        legend.position = "right",
        legend.text = element_text(size = 10))

print(p2)

ggsave("AED_quality_categories_pie.png", p2, width = 10, height = 6, dpi = 300)

# -----------------------------------------------------------------------------
# 5. Graphique combiné avec métriques clés
# -----------------------------------------------------------------------------

library(gridExtra)
library(grid)

# Créer un tableau de statistiques
stats_table <- data.frame(
  Metrique = c("Excellent annotations", 
               "High-quality annotations",
               "Retained annotations (threshold 0.5)",
               "Low-support annotations"),
  Valeur = c(sprintf("%.1f%%", quality_categories$Pourcentage[1]),
             sprintf("%.1f%%", sum(quality_categories$Pourcentage[1:2])),
             sprintf("%.1f%%", sum(quality_categories$Pourcentage[1:3])),
             sprintf("%.1f%%", quality_categories$Pourcentage[4])),
  Seuil = c("AED ≤ 0.1", "AED ≤ 0.25", "AED ≤ 0.5", "AED > 0.5")
)

# Créer un tableau graphique
table_grob <- tableGrob(stats_table, rows = NULL, 
                        theme = ttheme_default(base_size = 11))

# Combiner graphique et tableau
combined_plot <- grid.arrange(
  p1, 
  table_grob,
  ncol = 1,
  heights = c(3, 1),
  top = textGrob("Comprehensive AED Quality Analysis", 
                 gp = gpar(fontsize = 18, fontface = "bold"))
)

ggsave("AED_quality_combined.png", combined_plot, width = 10, height = 10, dpi = 300)

