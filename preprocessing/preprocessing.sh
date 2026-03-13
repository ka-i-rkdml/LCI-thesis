#!/bin/bash
# ------------------------------------------------------------
# Script: preprocessing.sh
# Purpose: Preprocess RNA-seq BAM files for variant calling
# Input: BAM from STAR alignment (Partek or similar)
# Output: sorted, deduplicated, RG-added, split BAM ready for BQSR
# Tools: samtools 1.19.2, GATK 4.6.2.0
# Notes:
#   - Keep Java options and thread counts adjustable
#   - Optional steps (download dbSNP, chromosome map) are marked
# ------------------------------------------------------------

# Move BAM to WSL home directory (optional, speed up)
# mv "/mnt/c/Users/.../sample.bam" ~/

cd ~  # working dir

# 1️⃣ Sort BAM and create index
samtools sort \
    -@ 4 \
    -m 2G \
    -T /tmp/sample_sort \
    --write-index \
    -o sample.sort.bam \
    sample.bam

# 2️⃣ Add Read Groups
gatk AddOrReplaceReadGroups \
    -I sample.sort.bam \
    -O sample.rg.bam \
    -RGID sampleID -RGLB lib1 -RGPL ILLUMINA -RGPU unit1 -RGSM sample

samtools view -H sample.rg.bam | grep '@RG'   # check RG

# 3️⃣ Mark Duplicates
gatk MarkDuplicates \
    --java-options "-Xmx8g -XX:ParallelGCThreads=4" \
    -I sample.rg.bam \
    -O sample.dedup.bam \
    -M sample.metrics.txt

samtools index sample.dedup.bam

# 4️⃣ Split NCigar Reads (for RNA-seq)
gatk SplitNCigarReads \
    --java-options "-Xmx6g -XX:ParallelGCThreads=3" \
    -R ~/reference/hg38_ucsc/hg38.fa \
    -I sample.dedup.bam \
    -O sample.split.bam

samtools sort -@ 4 -m 2G --write-index -o sample.split.sorted.bam sample.split.bam
