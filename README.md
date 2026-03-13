# LCI-thesis: RNA-seq Variant Analysis Pipeline

## Overview
This repository contains scripts and workflows for RNA-seq variant calling, filtering, annotation, and resistant vs parental comparison.  
The pipeline is based on GATK 4 + SnpEff 4.3+.

## Repository Structure
env_setup/ # Setup software & environment  
preprocessing/ # BAM/FASTQ preprocessing  
variant_calling/ # Variant calling and filtering  
annotation/ # snpEff annotation  
comparison/ # Resistant vs Parental comparison  
scripts/ # Utility scripts  
docs/ # Flowcharts, figures, notes  

## Pipeline Workflow

1. **Setup Environment**
</>Bash
bash env_setup/install_tools.sh

2. **Preprocessing BAM/FASTQ**
bash preprocessing/preprocess_all.sh

3. **Variant Calling & Filtering**
</>Bash
bash variant_calling/run_variant_calling.sh

4. **Annotation with SnpEff**
</>Bash
bash annotation/run_annotation.sh

5. **Resistant vs Parental Comparison**
</>Bash
bash comparison/run_comparison.sh

## Usage Notes
- Recommended to run in WSL2 Ubuntu or Linux environment
- Requires Java >= 11 for GATK and SnpEff
- Adjust memory (-Xmx) according to available RAM
- Entry scripts assume input files are under ~/variants and ~/ann

## License

MIT License. See `LICENSE` for details.

## Reproducibility

All commands and parameters used in the analysis are documented in the provided scripts.

## Citation

If you use this code, please cite:

Lee, C.-I. (2026). *LCI-thesis*. GitHub repository.
