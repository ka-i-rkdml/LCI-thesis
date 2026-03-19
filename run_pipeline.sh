#!/bin/bash

set -e  # 有錯直接停

# ===== 使用方式 =====
# bash run_pipeline.sh SAMPLE BAM

SAMPLE=$1
BAM=$2

THREADS=8
MEM=10g

REF=~/reference/hg38_ucsc/hg38.fa
DBSNP=~/reference/00-All.chr.vcf.gz

OUTDIR=~/results/$SAMPLE
mkdir -p $OUTDIR
