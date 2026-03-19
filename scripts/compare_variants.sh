#!/bin/bash
set -e

SAMPLE1=$1
SAMPLE2=$2

source config/config.sh

VCF1=$OUTDIR/${SAMPLE1}.filtered.vcf.gz
VCF2=$OUTDIR/${SAMPLE2}.filtered.vcf.gz

echo "=== Variant Comparison: $SAMPLE1 vs $SAMPLE2 ==="

# 取 intersection
bcftools isec -p $OUTDIR/isec_${SAMPLE1}_${SAMPLE2} \
    $VCF1 $VCF2

# 統計 overlap
bcftools stats $VCF1 > $OUTDIR/${SAMPLE1}.stats.txt
bcftools stats $VCF2 > $OUTDIR/${SAMPLE2}.stats.txt
