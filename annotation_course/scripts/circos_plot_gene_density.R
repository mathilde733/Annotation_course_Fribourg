#!/usr/bin/env Rscript

###############################################################
## Circos plot : TEs (par superfamille) + gènes (depuis GFF3)
## Auteur : ChatGPT, adapté de ton code
###############################################################

# Chargement des packages
library(circlize)
library(dplyr)
library(grid)
library(data.table)
library(ComplexHeatmap) # pour la légende

###############################################################
## 1️⃣ Lecture des fichiers
###############################################################

# --- TE annotation GFF ---
gff_te <- "ERR11437317.asm.bp.p_ctg.fa.mod.EDTA.TEanno.gff3"
gff_data <- read.table(gff_te, header = FALSE, sep = "\t", stringsAsFactors = FALSE)

# Vérifier les types présents (superfamilles)
cat("Superfamilies présentes dans le GFF :\n")
print(table(gff_data$V3))

# --- Fichier .fai pour longueurs des scaffolds ---
custom_ideogram <- read.table("ERR11437317.asm.bp.p_ctg.fa.fai", header = FALSE, stringsAsFactors = FALSE)
colnames(custom_ideogram) <- c("chr", "end", "dummy1", "dummy2", "dummy3")
custom_ideogram$start <- 1
custom_ideogram <- custom_ideogram[, c("chr", "start", "end")]

# Garder les 20 plus longs scaffolds
custom_ideogram <- custom_ideogram[order(custom_ideogram$end, decreasing = TRUE), ][1:20, ]

###############################################################
## 2️⃣ Lecture du GFF des gènes (si séparé du GFF TE)
###############################################################

# Si EDTA a aussi annoté les gènes (sinon utiliser annotation officielle)
gff_gene <- "filtered.genes.renamed.gff3"

if (file.exists(gff_gene)) {
  gene_data <- read.table(gff_gene, header = FALSE, sep = "\t", stringsAsFactors = FALSE)
  genes <- gene_data %>%
    filter(V3 %in% c("gene", "mRNA")) %>%
    mutate(chrom = V1, start = V4, end = V5) %>%
    select(chrom, start, end) %>%
    filter(chrom %in% custom_ideogram$chr)
  cat("✅", nrow(genes), "gènes extraits\n")
} else {
  cat("⚠️ Aucun fichier GFF de gènes trouvé. Seules les TEs seront tracées.\n")
  genes <- NULL
}

###############################################################
## 3️⃣ Fonction pour filtrer par superfamille
###############################################################

filter_superfamily <- function(gff_data, superfamily, custom_ideogram) {
  filtered <- gff_data %>%
    filter(V3 == superfamily) %>%
    mutate(chrom = V1, start = V4, end = V5) %>%
    select(chrom, start, end) %>%
    filter(chrom %in% custom_ideogram$chr)
  return(filtered)
}

###############################################################
## 4️⃣ Circos plot
###############################################################

pdf("circos_TE_gene_density_5.pdf", width = 10, height = 10)

gaps <- c(rep(1, nrow(custom_ideogram) - 1), 5)
circos.clear()
circos.par(start.degree = 90, gap.degree = gaps, track.margin = c(0, 0))

# Initialisation avec le génome
circos.genomicInitialize(custom_ideogram)

# --- Densité des TE ---
circos.genomicDensity(filter_superfamily(gff_data, "Gypsy_LTR_retrotransposon", custom_ideogram),
                      count_by = "number", col = "darkgreen", track.height = 0.07, window.size = 1e5)

circos.genomicDensity(filter_superfamily(gff_data, "Copia_LTR_retrotransposon", custom_ideogram),
                      count_by = "number", col = "darkred", track.height = 0.07, window.size = 1e5)
circos.genomicDensity(filter_superfamily(gff_data, "helitron", custom_ideogram)
                      ,count_by = "number", col="orange", track.height=0.07, window.size = 1e5 )
circos.genomicDensity(filter_superfamily(gff_data, "LTR_retrotransposon", custom_ideogram)
                      ,count_by = "number", col="darkblue", track.height=0.07, window.size = 1e5 )
circos.genomicDensity(filter_superfamily(gff_data, "Mutator_TIR_transposon", custom_ideogram)
                      ,count_by = "number", col="purple", track.height=0.07, window.size = 1e5 )
circos.genomicDensity(filter_superfamily(gff_data, "rRNA_gene", custom_ideogram)
                      ,count_by = "number", col="blue", track.height=0.07, window.size = 1e5 )
circos.genomicDensity(genes,count_by = "number", col="black", track.height=0.07, window.size = 1e5 )



circos.clear()

# --- Légende ---
lgd <- Legend(
  title = "Tracks",
  at = c("Gypsy_LTR_retrotransposon", "Copia_LTR_retrotransposon", "helitron", 
         "LTR_retrotransposon", "Mutator_TIR_transposon", "rRNA gene", "Genes"),
  legend_gp = gpar(fill = c("darkgreen", "darkred", "orange", "darkblue", "purple", "blue", "black"))
)
draw(lgd, x = unit(0.5, "npc"), y = unit(0.5, "npc"), just = c("center"))

dev.off()

cat("🎉 Circos plot terminé : circos_TE_gene_density.pdf\n")

#to plot differently
# --- Gènes : track supplémentaire (en bleu) ---
if (!is.null(genes)) {
  circos.genomicTrackPlotRegion(genes, ylim = c(0, 1),
                                panel.fun = function(region, value, ...) {
                                  circos.genomicRect(region, ybottom = 0, ytop = 1,
                                                     col = "#377eb8AA", border = NA)
                                },
                                bg.border = NA, track.height = 0.05
  )
}
