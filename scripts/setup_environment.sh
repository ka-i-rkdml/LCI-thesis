#!/bin/bash
# ------------------------------------------------------------
# Script: setup_environment.sh
# Purpose: Set up WSL2 Ubuntu environment for RNA-seq variant calling
# Author: Chia-I Lee
# Notes:
#   - Install packages: samtools, bcftools, Java, Python
#   - Install GATK
#   - Set up reference genome (hg38)
#   - Install SnpEff and build GRCh38.113 database
#   - Some steps are first-time only / optional for subsequent runs
#   - Reference genome download and preparation included
# ------------------------------------------------------------

# =========================
# 1️⃣ install WSL2 & Ubuntu (first-time only)
# =========================
wsl --install
wsl --install -d Ubuntu
wsl --list
wsl -d Ubuntu

# User account & password: set during Ubuntu installation
# Ctrl+C 可中斷當前命令

# =========================
# 2️⃣ Update system & install basic packages (first-time only)
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
# 3️⃣ Install GATK (first-time only)
# =========================
# downloas GATK zip → https://github.com/broadinstitute/gatk/releases
# unzip to ~/tools/gatk-4.6.2.0
cd ~/tools/gatk-4.6.2.0
export PATH=$PWD:$PATH
echo 'export PATH=~/tools/gatk-4.6.2.0:$PATH' >> ~/.bashrc
source ~/.bashrc
gatk --help  

# =========================
# 4️⃣ Download reference genome (hg38) (first-time only)
# =========================
mkdir -p ~/reference/hg38_ensembl
mkdir -p ~/reference/hg38_ucsc
cd ~/reference/hg38_ensembl

# Ensembl FASTA + GTF (Ensembl release 113)
wget -c ftp://ftp.ensembl.org/pub/release-113/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
wget -c ftp://ftp.ensembl.org/pub/release-113/gtf/homo_sapiens/Homo_sapiens.GRCh38.113.gtf.gz
gunzip *.gz
mv Homo_sapiens.GRCh38.dna.primary_assembly.fa hg38.fa
mv Homo_sapiens.GRCh38.113.gtf hg38.gtf

# Build indexes
samtools faidx hg38.fa
gatk CreateSequenceDictionary -R hg38.fa -O hg38.dict

# UCSC chr-based reference
cd ~/reference/hg38_ucsc
wget -c https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz
gunzip hg38.fa.gz
samtools faidx hg38.fa
gatk CreateSequenceDictionary -R hg38.fa -O hg38.dict

# ------------------------
# 5️⃣ Install SnpEff and build GRCh38.113 database
# ------------------------
cd ~
mkdir -p snpEff
cd snpEff

# Download SnpEff
wget -c https://downloads.sourceforge.net/project/snpeff/snpEff_latest_core.zip
unzip -q snpEff_latest_core.zip
cd snpEff

# Create database folders
cd ~/snpEff/data
mkdir -p GRCh38.113/sequences
mkdir -p GRCh38.113/genes

# Download GTF + decompress
cd GRCh38.113/genes
wget -c http://ftp.ensembl.org/pub/release-113/gtf/homo_sapiens/Homo_sapiens.GRCh38.113.gtf.gz
gunzip Homo_sapiens.GRCh38.113.gtf.gz

# Download DNA FASTA + decompress
cd ../sequences
wget -c http://ftp.ensembl.org/pub/release-113/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
gunzip Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz

# Organize files in GRCh38.113 folder
cd ~/snpEff/data/GRCh38.113
mv genes/Homo_sapiens.GRCh38.113.gtf ./genes.gtf
mv sequences/Homo_sapiens.GRCh38.dna.primary_assembly.fa ./sequences.fa
rm -r genes sequences

# Configure snpEff.config
echo "GRCh38.113.genome : Homo_sapiens_GRCh38.113" >> ~/snpEff/snpEff.config
echo "GRCh38.113.gtf : data/GRCh38.113/genes.gtf" >> ~/snpEff/snpEff.config
echo "GRCh38.113.fa  : data/GRCh38.113/sequences.fa" >> ~/snpEff/snpEff.config
tail ~/snpEff/snpEff.config

# Build SnpEff database
cd ~/snpEff
java -Xmx12g -jar snpEff.jar build -gtf22 -v GRCh38.113

echo "✅ Environment setup complete: GATK, reference genome, and SnpEff GRCh38.113 ready to use."
