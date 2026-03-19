#!/bin/bash
set -e

SAMPLE=$1
BAM=$2
CODE=$3

source config/config.sh

echo "=== Preprocessing: $SAMPLE ==="

samtools sort -@ 4 -m 2G \
    -T /tmp/${CODE}_sort \
    -o $OUTDIR/${SAMPLE}.sort.bam \
    $BAM

gatk AddOrReplaceReadGroups \
    -I $OUTDIR/${SAMPLE}.sort.bam \
    -O $OUTDIR/${SAMPLE}.rg.bam \
    -RGID $CODE -RGLB lib1 -RGPL ILLUMINA -RGPU $CODE -RGSM $SAMPLE

gatk MarkDuplicates \
    --java-options "-Xmx$MEMORY" \
    -I $OUTDIR/${SAMPLE}.rg.bam \
    -O $OUTDIR/${SAMPLE}.dedup.bam \
    -M $OUTDIR/${SAMPLE}_metrics.txt

samtools index $OUTDIR/${SAMPLE}.dedup.bam
