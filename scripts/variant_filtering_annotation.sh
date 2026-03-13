#!/bin/bash
# =========================================================
# Script: variant_filtering_annotation.sh
# Purpose: RNA-seq Variant Filtering + SnpEff Annotation
# Author: Ka-I Li
# Notes:
#   - Compatible with GATK 4 + SnpEff 4.3+
#   - Filters SNPs and INDELs separately and merges results
#   - Supports MLEAF filtering for multiple ALT alleles
# =========================================================

# ------------------------
# 1️⃣ Set paths and parameters
# ------------------------
REF=~/reference/hg38_ucsc/hg38.fa
INPUT_VCF=~/3_HNH3FDSX5_L4_genotyped.vcf.gz
OUTDIR=~/variants
MEM=10g

mkdir -p $OUTDIR

# ------------------------
# 2️⃣ Separate SNPs and Indels
# ------------------------
gatk --java-options "-Xmx$MEM" SelectVariants \
    -R $REF \
    -V $INPUT_VCF \
    -select-type SNP \
    -O $OUTDIR/snps.vcf.gz

gatk --java-options "-Xmx$MEM" SelectVariants \
    -R $REF \
    -V $INPUT_VCF \
    -select-type INDEL \
    -O $OUTDIR/indels.vcf.gz

# ------------------------
# 3️⃣ Filter SNPs
# Recommended thresholds: QD<2 || FS>30 || MQ<40 || MQRankSum<-12.5 || ReadPosRankSum<-8
# ------------------------
gatk --java-options "-Xmx$MEM" VariantFiltration \
    -R $REF \
    -V $OUTDIR/snps.vcf.gz \
    -O $OUTDIR/snps.filtered.vcf.gz \
    --filter-name "QD2" --filter-expression "vc.hasAttribute('QD') && vc.getAttribute('QD') < 2.0" \
    --filter-name "FS30" --filter-expression "vc.hasAttribute('FS') && vc.getAttribute('FS') > 30.0" \
    --filter-name "MQ40" --filter-expression "vc.hasAttribute('MQ') && vc.getAttribute('MQ') < 40.0" \
    --filter-name "MQRankSum-12.5" --filter-expression "vc.hasAttribute('MQRankSum') && vc.getAttribute('MQRankSum') < -12.5" \
    --filter-name "ReadPosRankSum-8" --filter-expression "vc.hasAttribute('ReadPosRankSum') && vc.getAttribute('ReadPosRankSum') < -8.0"

# ------------------------
# 4️⃣ Filter Indels
# Recommended thresholds: QD<2 || FS>200 || ReadPosRankSum<-20
# ------------------------
gatk --java-options "-Xmx$MEM" VariantFiltration \
    -R $REF \
    -V $OUTDIR/indels.vcf.gz \
    -O $OUTDIR/indels.filtered.vcf.gz \
    --filter-name "QD2" --filter-expression "vc.hasAttribute('QD') && vc.getAttribute('QD') < 2.0" \
    --filter-name "FS200" --filter-expression "vc.hasAttribute('FS') && vc.getAttribute('FS') > 200.0" \
    --filter-name "ReadPosRankSum-20" --filter-expression "vc.hasAttribute('ReadPosRankSum') && vc.getAttribute('ReadPosRankSum') < -20.0"

# ------------------------
# 5️⃣ Merge SNPs and Indels
# ------------------------
gatk MergeVcfs \
    -I $OUTDIR/snps.filtered.vcf.gz \
    -I $OUTDIR/indels.filtered.vcf.gz \
    -O $OUTDIR/merged.filtered.vcf.gz

# ------------------------
# 6️⃣ Filter MLEAF and retain PASS variants
# ------------------------
bcftools view -f PASS -i 'INFO/MLEAF[0]>=0.05 && INFO/MLEAF[1]>=0.05' \
    -Oz -o $OUTDIR/filtered.final.vcf.gz \
    $OUTDIR/merged.filtered.vcf.gz

bcftools index $OUTDIR/filtered.final.vcf.gz

# ------------------------
# 7️⃣ Inspect results
# ------------------------
echo "Top 10 MLEAF variants:"
bcftools query -f '%CHROM\t%POS\t%MLEAF\n' $OUTDIR/filtered.final.vcf.gz | head

# =========================================================
# 8️⃣ SnpEff Annotation
# =========================================================
SNPEFF_DIR=~/snpEff
ANN_DIR=~/ann
mkdir -p $ANN_DIR

# Assumes SnpEff is installed and GRCh38.113 database is built
java -Xmx12g -jar $SNPEFF_DIR/snpEff.jar -v GRCh38.113 \
    -canon \
    -no-intergenic -no-intron -no-upstream -no-downstream -no-utr \
    -lof \
    $OUTDIR/filtered.final.vcf.gz > $ANN_DIR/filtered.ann.vcf

echo "✅ Variant filtering and annotation completed."
