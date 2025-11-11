# 🧬 Genome Annotation of *Arabidopsis thaliana*

This repository contains the workflow, scripts, and results for the **genome annotation** of an eukaryote genome, e.g., *Arabidopsis thaliana*, carried out as a continuation of the [Genome Assembly course](https://github.com/mathilde733/Assembly_Annotation_Course.git). 

Datasets used are from PacBio HiFi reads (WGS) and Illumina reads (RNA-seq). \
Accession number: Had-6b, genetic group originating from Africa. \
Raw data are from: [Qichao Lian et al. A pan-genome of 69 Arabidopsis thaliana accessions reveals a conserved genome structure throughout the global species range](https://www.nature.com/articles/s41588-024-01715-9) and [Jiao WB, Schneeberger K. Chromosome-level assemblies of multiple Arabidopsis genomes reveal hotspots of rearrangements with altered evolutionary dynamics](http://dx.doi.org/10.1038/s41467-020-14779-y) 


## Project Overview

**Objectives:**
---
### First step is the transposable elements annotation and classification
Steps including:
- TE annotation using EDTA
- Visualizing and comparing TE annotations from EDTA (visualization using R)
- Refining TE classifications using TEsorter
- Generate and visualizing TE dynamics (in R)

### Second step is to annotate genes using the MAKER pipeline
Steps including:
- Ab initio gene prediction using Augustus and GeneMark
- RNAseq Data to improve accuracy of gene models predicted by the Ab initio methods
- Protein-homology-based annotation using Interproscan
- Final gene model refinement ensuring biologically accurate annotations.\
Quality assessment of gene annotations using BUSCO and visualization of gene annotation using Geneious 

### Third step is the orthology based gene functional annotation and genome comparisons
Steps including:
- Sequence homology to functionally validated proteins using the Uniprot database and TAIR10
- Comparative genomics using Orthofinder and GENESPACE (in R)
- Visualization of the results, e.g., summary statistics results, dotplots and syntenic maps (also called [Riparian plots](https://htmlpreview.github.io/?https://github.com/jtlovell/tutorials/blob/main/riparianGuide.html))

---

## ⚙️ Tools and Software
- [EDTA version 2.2](https://github.com/oushujun/EDTA), see [Benchmarking transposable element annotation methods for creation of a streamlined, comprehensive pipeline](https://genomebiology.biomedcentral.com/articles/10.1186/s13059-019-1905-y)
- [TEsorter version 1.3.0](https://github.com/zhangrengang/TEsorter)
- [Parse RepeatMasker](https://github.com/4ureliek/Parsing-RepeatMasker-Outputs)
- R version 4.5.1 using several packages, e.g., library [circlize](https://jokergoo.github.io/circlize/) for circos plot; library(ggplot) for landscape graph
- [MAKER pipeline version 3.01.03](https://github.com/Yandell-Lab/maker)
- MPI version 4.1.1
- [Augustus version 3.4.0](https://github.com/Gaius-Augustus/Augustus)
- [Interproscan version 5.70-102.0](https://interproscan-docs.readthedocs.io/en/v5/)
- [BUSCO version 5.4.2](https://busco.ezlab.org)
- [AGAT](https://github.com/NBISweden/AGAT)
- [Geneious](https://www.geneious.com/)
- [BLAST version 2.15.0](https://blast.ncbi.nlm.nih.gov/Blast.cgi)
- Uniprot database and *A.thaliana* TAIR10 representative gene models were given
- [Orthofinder](https://github.com/davidemms/OrthoFinder)
- [GENESPACE](https://github.com/jtlovell/GENESPACE) which is a R package

Some of the tools used in this workflow were run within Apptainer containers to ensure reproducibility and consistent environments. The other softwares were installed via modules.
```apptainer exec --bind /data:/data /containers/apptainer/``` or ```module avail/load name```

