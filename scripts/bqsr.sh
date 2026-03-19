#!/bin/bash
set -e

SAMPLE=$1
source config/config.sh

echo "=== BQSR: $SAMPLE ==="

gatk BaseRecalibrator \
    -R $REF \
    -I $OUTDIR/${SAMPLE}.dedup.bam \
    --known-sites $DBSNP \
    -O $OUTDIR/${SAMPLE}.recal.table

gatk ApplyBQSR \
    -R $REF \
    -I $OUTDIR/${SAMPLE}.dedup.bam \
    --bqsr-recal-file $OUTDIR/${SAMPLE}.recal.table \
    -O $OUTDIR/${SAMPLE}.BQSR.bam

samtools index $OUTDIR/${SAMPLE}.BQSR.bam
