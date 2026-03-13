#!/bin/bash
# ------------------------------------------------------------
# Script: variant_calling.sh
# Purpose: Call variants from RNA-seq BAM
# Input: BQSR-corrected BAM
# Output: raw VCF / genotyped VCF
# Tools: GATK HaplotypeCaller / GenotypeGVCFs
# Notes:
#   - ERC GVCF generates intermediate genomic VCF
#   - --dont-use-soft-clipped-bases: mandatory for RNA-seq
# ------------------------------------------------------------

# (Optional) Install libgomp for GATK acceleration
sudo apt update 
sudo apt install libgomp1

# 1️⃣ HaplotypeCaller
gatk HaplotypeCaller \
    --java-options "-Xmx10g -XX:ParallelGCThreads=8" \
    -R ~/reference/hg38_ucsc/hg38.fa \
    -I ~/sample.BQSR.bam \
    -O ~/sample_raw.vcf.gz \
    --dont-use-soft-clipped-bases true \
    --standard-min-confidence-threshold-for-calling 20 \
    --min-base-quality-score 20 \
    -ERC GVCF \
    -native-pair-hmm-threads 8

# 2️⃣ Genotype GVCF
gatk GenotypeGVCFs \
    --java-options "-Xmx8g -XX:ParallelGCThreads=6" \
    -R ~/reference/hg38_ucsc/hg38.fa \
    -V ~/sample_raw.vcf.gz \
    -O ~/sample_genotyped.vcf.gz
