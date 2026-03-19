#!/bin/bash
set -e

SAMPLE=$1
source config/config.sh

echo "=== Filtering: $SAMPLE ==="

bcftools view -f PASS \
    $OUTDIR/${SAMPLE}.g.vcf.gz \
    -Oz -o $OUTDIR/${SAMPLE}.filtered.vcf.gz

bcftools index $OUTDIR/${SAMPLE}.filtered.vcf.gz
