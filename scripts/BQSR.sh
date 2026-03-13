#!/bin/bash
# ------------------------------------------------------------
# Script: BQSR.sh
# Purpose: Base Quality Score Recalibration
# Input: split.sorted BAM
# Output: BQSR-corrected BAM
# Tools: GATK 4.6.2.0, bcftools
# Notes:
#   - Download dbSNP only first time
#   - Check chromosome naming consistency
# ------------------------------------------------------------

cd ~/reference

# 1️⃣ (Optional) Download dbSNP build 151
# wget http://ftp.ncbi.nlm.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/GATK/00-All.vcf.gz
# wget http://ftp.ncbi.nlm.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/GATK/00-All.vcf.gz.tbi
# bcftools index -f 00-All.vcf.gz

# 2️⃣ Rename chromosomes if needed
# nano chr_map.txt  # first-time only
# bcftools annotate --rename-chrs chr_map.txt 00-All.vcf.gz -Oz -o 00-All.chr.vcf.gz
# bcftools index -f 00-All.chr.vcf.gz
# tabix -p vcf 00-All.chr.vcf.gz

# 3️⃣ BaseRecalibrator
gatk BaseRecalibrator \
    --java-options "-Xmx10g -XX:ParallelGCThreads=8" \
    -I ~/sample.split.sorted.bam \
    -R ~/reference/hg38_ucsc/hg38.fa \
    --known-sites ~/reference/00-All.chr.vcf.gz \
    -O sample.recal_data.table

gatk ApplyBQSR \
    --java-options "-Xmx8g -XX:ParallelGCThreads=6" \
    -R ~/reference/hg38_ucsc/hg38.fa \
    -I ~/sample.split.sorted.bam \
    --bqsr-recal-file sample.recal_data.table \
    -O sample.BQSR.bam

samtools index sample.BQSR.bam
