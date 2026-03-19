# LCI-thesis: RNA-seq Variant Analysis Pipeline

## Overview
This repository contains scripts and workflows for RNA-seq variant calling, filtering, annotation, and resistant vs parental comparison.

## Workflow
BAM file → preprocessing → variant calling → filtering → annotatio

## Requirements
- OS: WSL2 / Ubuntu XX
- Tools:
  - GATK 4.2
  - samtools
  - bcftools
  - SnpEff
- Java version > 11

## Installation
Step-by-step environment setup

## Usage
Step-by-step commands

## Notes
- RNA-seq specific considerations
- Known limitations

## Reference Genome Strategy

Two versions of hg38 were used:
- Ensembl primary assembly (no "chr" prefix)
- UCSC hg38 (with "chr" prefix)

A chromosome name mapping step was performed using bcftools annotate to ensure compatibility between BAM and known-sites VCF.

## License

MIT License. See `LICENSE` for details.

## Citation
If used in publicationㄝplease cite:

Lee, C.-I. (2026). *LCI-thesis*. GitHub repository.
