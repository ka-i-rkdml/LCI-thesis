#!/bin/bash
# ------------------------------------------------------------
# Script: setup_environment.sh
# Purpose: Set up WSL2 Ubuntu environment for RNA-seq variant calling
# Author: Ka-I Li
# Notes:
#   - Some steps are first-time only / optional for subsequent runs
#   - Reference genome download and preparation included
# ------------------------------------------------------------

# =========================
# 1️⃣ WSL2 & Ubuntu 安裝 (第一次使用才需)
# =========================
# wsl --install
# wsl --install -d Ubuntu
# wsl --list
# wsl -d Ubuntu

# User account & password: set during Ubuntu installation
# Ctrl+C 可中斷當前命令

# =========================
# 2️⃣ 更新 Linux 系統與安裝套件 (第二次可跳過)
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
# 3️⃣ GATK 安裝 (第一次才需)
# =========================
# 下載 GATK zip → https://github.com/broadinstitute/gatk/releases
# 解壓縮至 ~/tools/gatk-4.6.2.0（或其他目錄）
# cd ~/tools/gatk-4.6.2.0
# export PATH=$PWD:$PATH

# 永久加入 PATH
echo 'export PATH=~/tools/gatk-4.6.2.0:$PATH' >> ~/.bashrc
source ~/.bashrc

gatk --help   # 確認 GATK 可用

# =========================
# 4️⃣ 建立 reference 目錄
# =========================
mkdir -p ~/reference/hg38_ensembl
mkdir -p ~/reference/hg38_ucsc

# =========================
# 5️⃣ 下載參考基因組 FASTA + GTF (第一次才需)
# =========================
# Ensembl release 113
cd ~/reference/hg38_ensembl
wget -c ftp://ftp.ensembl.org/pub/release-113/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
wget -c ftp://ftp.ensembl.org/pub/release-113/gtf/homo_sapiens/Homo_sapiens.GRCh38.113.gtf.gz

# 解壓縮
gunzip Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
gunzip Homo_sapiens.GRCh38.113.gtf.gz

# 改名方便管理
mv Homo_sapiens.GRCh38.dna.primary_assembly.fa hg38.fa
mv Homo_sapiens.GRCh38.113.gtf Homo_sapiens.GRCh38.113.gtf

# =========================
# 6️⃣ 建立 FASTA index & GATK dict
# =========================
samtools faidx hg38.fa
gatk CreateSequenceDictionary -R hg38.fa -O hg38.dict

# =========================
# 7️⃣ UCSC hg38 下載 (chr1, chr2...) 可選
# =========================
cd ~/reference/hg38_ucsc
wget -c https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz
gunzip hg38.fa.gz
samtools faidx hg38.fa
gatk CreateSequenceDictionary -R hg38.fa -O hg38.dict

# 檢查 contig 名稱
grep "^>" hg38.fa | head
