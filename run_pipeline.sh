#!/bin/bash

set -e  # 有錯直接停

# ===== 使用方式 =====
# bash run_pipeline.sh SAMPLE BAM

# ===== 參數區 =====
SAMPLE=$1
BAM=$2

THREADS=8
MEM=10g

REF=~/reference/hg38_ucsc/hg38.fa
DBSNP=~/reference/00-All.chr.vcf.gz

OUTDIR=~/results/$SAMPLE
mkdir -p $OUTDIR

# ===== function 區 =====
preprocess_bam() {
    echo "=== Preprocessing BAM ==="

    samtools sort -@ $THREADS -m 2G \
        -o $OUTDIR/${SAMPLE}.sort.bam \
        $BAM

    gatk AddOrReplaceReadGroups \
        -I $OUTDIR/${SAMPLE}.sort.bam \
        -O $OUTDIR/${SAMPLE}.rg.bam \
        -RGID $BAM -RGLB H1993_lib1 -RGPL ILLUMINA -RGPU $BAM -RGSM $SAMPLE

    gatk MarkDuplicates \
        -I $OUTDIR/${SAMPLE}.rg.bam \
        -O $OUTDIR/${SAMPLE}.dedup.bam \
        -M $OUTDIR/${SAMPLE}_metrics.txt

    samtools index $OUTDIR/${SAMPLE}.dedup.bam
}

split_bam() {
    echo "=== SplitNCigarReads ==="

    gatk SplitNCigarReads \
        -R $REF \
        -I $OUTDIR/${SAMPLE}.dedup.bam \
        -O $OUTDIR/${SAMPLE}.split.bam

    samtools sort -@ $THREADS \
        -o $OUTDIR/${SAMPLE}.split.sorted.bam \
        $OUTDIR/${SAMPLE}.split.bam

    samtools index $OUTDIR/${SAMPLE}.split.sorted.bam
}

bqsr() {
    echo "=== BQSR ==="

    gatk BaseRecalibrator \
        -R $REF \
        -I $OUTDIR/${SAMPLE}.split.sorted.bam \
        --known-sites $DBSNP \
        -O $OUTDIR/${SAMPLE}.recal.table

    gatk ApplyBQSR \
        -R $REF \
        -I $OUTDIR/${SAMPLE}.split.sorted.bam \
        --bqsr-recal-file $OUTDIR/${SAMPLE}.recal.table \
        -O $OUTDIR/${SAMPLE}.BQSR.bam

    samtools index $OUTDIR/${SAMPLE}.BQSR.bam
}

call_variants() {
    echo "=== HaplotypeCaller ==="

    gatk HaplotypeCaller \
        -R $REF \
        -I $OUTDIR/${SAMPLE}.BQSR.bam \
        -O $OUTDIR/${SAMPLE}.g.vcf.gz \
        -ERC GVCF
}

# ===== 主程式 =====
main() {
    preprocess_bam
    split_bam
    bqsr
    call_variants
}

main
