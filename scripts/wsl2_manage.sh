#!/bin/bash
# ------------------------------------------------------------
# Script: wsl2_manage.sh
# Purpose: Manage WSL2 resources, cleanup, and maintenance
# Author: Chia-I Lee
# Notes:
#   - Divided into PowerShell and WSL2 Ubuntu sections
#   - Configure RAM/CPU/swap, prevent analysis interruption, 
#     cleanup intermediate files and caches, compress VHDX
# ------------------------------------------------------------

# =========================
# 1️⃣ WSL2 Resource Adjustment (Run in PowerShell)
# =========================
: <<'POWERSHELL'
# Open PowerShell
notepad $env:USERPROFILE\.wslconfig

# Add the following lines in Notepad
[wsl2]
memory=12GB
processors=10
swap=6GB
swapFile=C:\\wsl-swap.vhdx
localhostForwarding=true

# Save and close Notepad
wsl --shutdown
# After restarting Ubuntu, check RAM with `free -h`
POWERSHELL

# =========================
# 2️⃣ JVM Parameter Notes (Bash comments)
# =========================
# -Xmx                -> Maximum Java heap size (RAM)
# -XX:ParallelGCThreads -> Number of CPU threads for Java Garbage Collection

# =========================
# 3️⃣ Install tmux to prevent session loss (WSL Ubuntu)
# =========================
sudo apt install -y tmux
# Start a new session:
# tmux new -s bio
# Detach from session: Ctrl+B → D
# Reattach: tmux attach -t bio

# =========================
# 4️⃣ Remove intermediate files to free space (WSL Ubuntu)
# =========================
# Intermediate BAM files
rm -f *.sort.bam.bai* *.sort.bam* *_rg.bam* *_dedup.bam* *_split.bam *_split.bai *_split.sorted.bam* *_split.sorted.bam.bai

# Intermediate VCF files
rm -f *_raw.vcf.gz* *_genotyped.vcf.gz* snps* indels* merged*

# MarkDuplicates metrics, BQSR table, snpEff zip
rm -f *_metrics.txt *_recal_data.table

# =========================
# 5️⃣ Clean system and caches (WSL Ubuntu)
# =========================
# apt package manager caches
sudo apt-get clean
sudo apt-get autoclean
sudo apt-get autoremove

# Node.js caches
npm cache clean --force
yarn cache clean

# Rust caches
rm -rf ~/.cargo/registry/cache/*

# Trim unused blocks in WSL2 filesystem
sudo fstrim -v /
# =========================
# 6️⃣ Compress WSL2 VHDX (Run in PowerShell)
# =========================
: <<'POWERSHELL'
# Shut down WSL2
wsl --shutdown

# Navigate to WSL storage folder
cd "$env:LOCALAPPDATA\WSL"
# Find the corresponding ext4.vhdx file
# Example: C:\Users\ASUS\AppData\Local\WSL\{UUID}\ext4.vhdx

# Open diskpart in PowerShell
diskpart
select vdisk file="C:\Users\ASUS\AppData\Local\WSL\{UUID}\ext4.vhdx"
attach vdisk readonly
compact vdisk
detach vdisk
exit
POWERSHELL

echo "✅ WSL2 management and cleanup completed"
