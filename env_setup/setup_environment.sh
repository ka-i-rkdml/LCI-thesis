#!/bin/bash
# ------------------------------------------------------------
# Script: setup_environment.sh
# Purpose: Set up WSL2 Ubuntu environment for RNA-seq variant calling
# Notes:
#   - Installs WSL2 (Windows only, first-time)
#   - Installs Ubuntu, basic packages, GATK, reference genomes, SnpEff
#   - First-time only steps will be skipped if already done
#   - Safe to run multiple times
# ------------------------------------------------------------

echo "🟢 Starting environment setup..."

# =========================
# 1. Install WSL2 & Ubuntu (first-time)
# =========================
if [ -z "$WSL_INTEROP" ]; then
    echo "💻 Detected Windows environment. Installing WSL2 and Ubuntu (first-time only)..."
    wsl --install
    wsl --install -d Ubuntu
    echo "✅ WSL2 & Ubuntu installation complete. Please set your Ubuntu user/password."
    echo "After first login, re-run this script inside Ubuntu."
    exit 0
else
    echo "🐧 Detected WSL Ubuntu environment. Skipping WSL install."
fi

# User account & password: set during Ubuntu installation
# Ctrl+C can interrupt current running code

# =========================
# 2. Update system & install basic packages (first-time only)
# =========================
sudo apt update && sudo apt upgrade -y

sudo apt install -y \
    samtools \
    bcftools \
    openjdk-11-jdk \
    openjdk-17-jdk \
    wget \
    python3 \
    python-is-python3 \
    unzip \
    screen

# =========================
# 3. Install GATK (first-time only)
# =========================
mkdir -p ~/tools
cd ~/tools
if [ ! -d "gatk-4.6.2.0" ]; then
    echo "🔹 Download GATK manually from https://github.com/broadinstitute/gatk/releases"
    echo "Unzip to ~/tools/gatk-4.6.2.0 and re-run this script"
    exit 1
fi
cd gatk-4.6.2.0
export PATH=$PWD:$PATH
grep -qxF 'export PATH=~/tools/gatk-4.6.2.0:$PATH' ~/.bashrc || \
    echo 'export PATH=~/tools/gatk-4.6.2.0:$PATH' >> ~/.bashrc
source ~/.bashrc
gatk --help

# =========================
# 4. Download reference genome (first-time only)
# =========================
if [ ! -f ~/reference/hg38_ensembl/hg38.fa ]; then
    cd ~/reference/hg38_ensembl
    wget -c ftp://ftp.ensembl.org/pub/release-113/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
    wget -c ftp://ftp.ensembl.org/pub/release-113/gtf/homo_sapiens/Homo_sapiens.GRCh38.113.gtf.gz
    gunzip *.gz
    mv Homo_sapiens.GRCh38.dna.primary_assembly.fa hg38.fa
    mv Homo_sapiens.GRCh38.113.gtf hg38.gtf
    samtools faidx hg38.fa
    gatk CreateSequenceDictionary -R hg38.fa -O hg38.dict
fi

# UCSC reference
if [ ! -f ~/reference/hg38_ucsc/hg38.fa ]; then
    cd ~/reference/hg38_ucsc
    wget -c https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz
    gunzip hg38.fa.gz
    samtools faidx hg38.fa
    gatk CreateSequenceDictionary -R hg38.fa -O hg38.dict
fi

# ------------------------
# 5. Install SnpEff and build GRCh38.113 database  (first-time only)
# ------------------------
SNPEFF_DIR=~/snpEff
if [ ! -f "$SNPEFF_DIR/snpEff.jar" ]; then
    mkdir -p $SNPEFF_DIR
    cd $SNPEFF_DIR
    wget -c https://downloads.sourceforge.net/project/snpeff/snpEff_latest_core.zip
    unzip -q snpEff_latest_core.zip
fi

# Build database if not exist
DB_DIR=$SNPEFF_DIR/data/GRCh38.113
if [ ! -f "$DB_DIR/sequences.fa" ] || [ ! -f "$DB_DIR/genes.gtf" ]; then
    mkdir -p $DB_DIR/sequences $DB_DIR/genes
    cd $DB_DIR/genes
    wget -c http://ftp.ensembl.org/pub/release-113/gtf/homo_sapiens/Homo_sapiens.GRCh38.113.gtf.gz
    gunzip Homo_sapiens.GRCh38.113.gtf.gz
    cd ../sequences
    wget -c http://ftp.ensembl.org/pub/release-113/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
    gunzip Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
    cd $DB_DIR
    mv genes/Homo_sapiens.GRCh38.113.gtf ./genes.gtf
    mv sequences/Homo_sapiens.GRCh38.dna.primary_assembly.fa ./sequences.fa
    rm -r genes sequences
fi

# Configure snpEff
CFG_LINE1="GRCh38.113.genome : Homo_sapiens_GRCh38.113"
CFG_LINE2="GRCh38.113.gtf : data/GRCh38.113/genes.gtf"
CFG_LINE3="GRCh38.113.fa  : data/GRCh38.113/sequences.fa"
grep -qxF "$CFG_LINE1" $SNPEFF_DIR/snpEff.config || echo "$CFG_LINE1" >> $SNPEFF_DIR/snpEff.config
grep -qxF "$CFG_LINE2" $SNPEFF_DIR/snpEff.config || echo "$CFG_LINE2" >> $SNPEFF_DIR/snpEff.config
grep -qxF "$CFG_LINE3" $SNPEFF_DIR/snpEff.config || echo "$CFG_LINE3" >> $SNPEFF_DIR/snpEff.config

# Build database
cd $SNPEFF_DIR
java -Xmx12g -jar snpEff.jar build -gtf22 -v GRCh38.113

echo "✅ Environment setup complete: GATK, reference genome, and SnpEff GRCh38.113 ready to use."
