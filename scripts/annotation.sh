#!/bin/bash
set -e

SAMPLE=$1
source config/config.sh

echo "=== Annotation: $SAMPLE ==="

java -Xmx$MEMORY -jar ~/snpEff/snpEff.jar \
    GRCh38.113 \
    $OUTDIR/${SAMPLE}.filtered.vcf.gz \
    > $OUTDIR/${SAMPLE}.ann.vcf
