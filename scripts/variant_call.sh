#!/bin/bash
set -e

SAMPLE=$1
source config/config.sh

echo "=== Variant Calling: $SAMPLE ==="

gatk HaplotypeCaller \
    -R $REF \
    -I $OUTDIR/${SAMPLE}.BQSR.bam \
    -O $OUTDIR/${SAMPLE}.g.vcf.gz \
    -ERC GVCF
