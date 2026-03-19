# LCI-thesis: RNA-seq Variant Analysis Pipeline

## Overview
This repository contains scripts and workflows for RNA-seq variant calling, filtering, annotation, and resistant vs parental comparison.  
The pipeline is based on GATK 4.2.6.0 and SnpEff 4.3t.

## Usage

```bash run_pipeline.sh SAMPLE input.bam```

## Repository Structure
- preprocess → sort + mark duplicates
- BQSR → recalibration
- variant calling → HaplotypeCaller
- filtering → bcftools
- annotation → SnpEff

## Notes
- Reference genome and dbSNP must be prepared separately

## Configuration

All customizable parameters are stored in: config/config.sh

You can modify:
- reference genome path
- known sites (dbSNP)
- output directory

## Usage Notes/Optimization
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
