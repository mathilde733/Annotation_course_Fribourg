# 🧬 Genome Annotation of *Arabidopsis thaliana*

This repository contains the workflow, scripts, and results for the **genome annotation** of an eukaryote genome, e.g., *Arabidopsis thaliana*, carried out as a continuation of the **Genome Assembly course**.

## Project Overview
After assembling the *A. thaliana* genome, this step focuses on the annotation. 

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

---

## ⚙️ Tools and Software
- [EDTA version 2.2](https://github.com/oushujun/EDTA), see [Benchmarking transposable element annotation methods for creation of a streamlined, comprehensive pipeline](https://genomebiology.biomedcentral.com/articles/10.1186/s13059-019-1905-y)
- [TEsorter version 1.3.0](https://github.com/zhangrengang/TEsorter)
- [Parse RepeatMasker](https://github.com/4ureliek/Parsing-RepeatMasker-Outputs)
- R version 4.5.1 using several packages, e.g., library [circlize](https://jokergoo.github.io/circlize/) for circos plot; library(ggplot) for landscape graph
- [MAKER pipeline version 3.01.03](https://github.com/Yandell-Lab/maker)
- MPI version 4.1.1-GCC-10.3.0
- Augustus version 3.4.0
- [Interproscan version 5.70-102.0](https://interproscan-docs.readthedocs.io/en/v5/)
- [BUSCO version 5.4.2](https://busco.ezlab.org)
- [AGAT](https://github.com/NBISweden/AGAT)
- [Geneious](https://www.geneious.com/)

