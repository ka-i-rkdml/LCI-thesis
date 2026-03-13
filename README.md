# RNA-seq Variant Calling Pipeline

Code accompanying the Master's thesis of Ka-I Li.

## Overview

This repository contains scripts used for RNA-seq–based variant calling and downstream variant analysis.

Variant calling was performed using GATK following the Best Practices workflow for RNA-seq short variant discovery:  
https://gatk.broadinstitute.org/hc/en-us/articles/360035531192-RNAseq-short-variant-discovery-SNPs-Indels

## Environment

Analysis was performed on **Ubuntu 24.04.2 LTS (WSL2 on Windows)** using:

- Java 17.0.17  
- GATK 4.6.2.0  
- bcftools 1.19  
- samtools 1.19.2  
- SnpEff 4.3t  

## Variant Selection

Variants unique to resistant sublines were evaluated. Functional variants were defined as variants annotated with **HIGH** or **MODERATE** predicted impact. Final variants were restricted to biallelic sites with total depth ≥15 and ≥5 supporting reads for the alternative allele.

## Code

RNA-seq variant calling scripts are available in the repository under:

`scripts/RNA-seq-gatk-variant-calling/`

## Reproducibility

All commands and parameters used in the analysis are documented in the provided scripts.

## Citation

If you use this code, please cite:

Lee, C.-I. (2026). *LCI-thesis*. GitHub repository.

## License

MIT License. See `LICENSE` for details.
