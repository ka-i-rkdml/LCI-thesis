#!/bin/bash
# =========================================================
# Script: setup_environment_manual.sh
# Purpose: Manual environment setup for RNA-seq variant calling on Ubuntu
# Notes:
#   - Each step is "first-time only" but can be re-run safely
#   - No automatic checks or skips
# =========================================================

echo "🟢 Starting manual environment setup..."

# =========================
# 1. Update system and install basic packages
# =========================
echo "🔹 Updating system and installing basic packages..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y samtools bcftools openjdk-11-jdk openjdk-17-jdk wget python3 python-is-python3 unzip screen

# =========================
# 2. Install GATK (manual download required)
# =========================
echo "🔹 GATK installation (manual step)"
echo "Download GATK from: https://github.com/broadinstitute/gatk/releases"
echo "Unzip to: ~/tools/gatk-4.6.2.0"
echo "Then add to PATH manually:"
echo 'export PATH=~/tools/gatk-4.6.2.0:$PATH'
echo "Example: echo 'export PATH=~/tools/gatk-4.6.2.0:$PATH' >> ~/.bashrc && source ~/.bashrc"
echo "Check installation with: gatk --help"

# =========================
# 3. Download reference genome (Ensembl)
# =========================
echo "🔹 Download Ensembl reference genome (first-time only)"
mkdir -p ~/reference/hg38_ensembl
cd ~/reference/hg38_ensembl
wget -c ftp://ftp.ensembl.org/pub/release-113/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
wget -c ftp://ftp.ensembl.org/pub/release-113/gtf/homo_sapiens/Homo_sapiens.GRCh38.113.gtf.gz
gunzip *.gz
mv Homo_sapiens.GRCh38.dna.primary_assembly.fa hg38.fa
mv Homo_sapiens.GRCh38.113.gtf hg38.gtf

# Build indexes
samtools faidx hg38.fa
gatk CreateSequenceDictionary -R hg38.fa -O hg38.dict

# =========================
# 4. Download UCSC reference genome
# =========================
echo "🔹 Download UCSC reference genome"
mkdir -p ~/reference/hg38_ucsc
cd ~/reference/hg38_ucsc
wget -c https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz
gunzip hg38.fa.gz

# Build indexes
samtools faidx hg38.fa
gatk CreateSequenceDictionary -R hg38.fa -O hg38.dict

# =========================
# 5. Install SnpEff
# =========================
echo "🔹 Install SnpEff"
mkdir -p ~/snpEff
cd ~/snpEff
wget -c https://downloads.sourceforge.net/project/snpeff/snpEff_latest_core.zip
unzip -q snpEff_latest_core.zip

# =========================
# 6. Build GRCh38.113 database for SnpEff
# =========================
echo "🔹 Build SnpEff GRCh38.113 database (manual)"
mkdir -p ~/snpEff/data/GRCh38.113/sequences
mkdir -p ~/snpEff/data/GRCh38.113/genes

cd ~/snpEff/data/GRCh38.113/genes
wget -c http://ftp.ensembl.org/pub/release-113/gtf/homo_sapiens/Homo_sapiens.GRCh38.113.gtf.gz
gunzip Homo_sapiens.GRCh38.113.gtf.gz

cd ../sequences
wget -c http://ftp.ensembl.org/pub/release-113/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
gunzip Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz

cd ~/snpEff/data/GRCh38.113
mv genes/Homo_sapiens.GRCh38.113.gtf ./genes.gtf
mv sequences/Homo_sapiens.GRCh38.dna.primary_assembly.fa ./sequences.fa
rm -r genes sequences

# Configure snpEff
echo "GRCh38.113.genome : Homo_sapiens_GRCh38.113" >> ~/snpEff/snpEff.config
echo "GRCh38.113.gtf : data/GRCh38.113/genes.gtf" >> ~/snpEff/snpEff.config
echo "GRCh38.113.fa  : data/GRCh38.113/sequences.fa" >> ~/snpEff/snpEff.config

# Build database
cd ~/snpEff
java -Xmx12g -jar snpEff.jar build -gtf22 -v GRCh38.113

echo "✅ Manual environment setup complete."
