#!/bin/bash
set -e

# ===== Usage =====
# bash run_pipeline.sh SAMPLE BAM CODE

SAMPLE=$1
BAM=$2
CODE=$3

# 載入設定檔
source config/config.sh

# ===== Run modules =====
bash scripts/preprocess.sh $SAMPLE $BAM $CODE
bash scripts/bqsr.sh $SAMPLE
bash scripts/variant_call.sh $SAMPLE
bash scripts/filter.sh $SAMPLE
bash scripts/annotation.sh $SAMPLE

echo "=== Pipeline completed: $SAMPLE ==="
