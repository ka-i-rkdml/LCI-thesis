#!/bin/bash
# ------------------------------------------------------------
# Script: wsl2_manage.sh
# Purpose: Manage WSL2 resources, cleanup, and maintenance
# Author: Ka-I Li
# Notes:
#   - 分為 PowerShell 與 WSL2 Ubuntu 兩部分
#   - 設定 RAM/CPU/swap, 避免分析中斷, 清理中間檔案與快取, 壓縮 VHDX
# ------------------------------------------------------------

# =========================
# 1️⃣ WSL2 資源調整 (在 PowerShell 執行)
# =========================
: <<'POWERSHELL'
# 打開 PowerShell
notepad $env:USERPROFILE\.wslconfig

# 在記事本中加入
[wsl2]
memory=12GB
processors=10
swap=6GB
swapFile=C:\\wsl-swap.vhdx
localhostForwarding=true

# 儲存後關閉記事本
wsl --shutdown
# 再次啟動 Ubuntu 後可用 `free -h` 查看 RAM 是否正確
POWERSHELL

# =========================
# 2️⃣ JVM 參數說明 (Bash 註解)
# =========================
# -Xmx               -> 最大 Java heap size (RAM)
# -XX:ParallelGCThreads -> 控制 Java 同時使用 CPU 核心數做垃圾回收

# =========================
# 3️⃣ 安裝 tmux 防斷線 (WSL Ubuntu)
# =========================
sudo apt install -y tmux
# 啟動新會話
# tmux new -s bio
# 離開 tmux: Ctrl+B → D
# 回到 tmux: tmux attach -t bio

# =========================
# 4️⃣ 刪除中間檔案釋放空間 (WSL Ubuntu)
# =========================
# 中間 BAM
rm -f *.sort.bam.bai* *.sort.bam* *_rg.bam* *_dedup.bam* *_split.bam *_split.bai *_split.sorted.bam* *_split.sorted.bam.bai

# 中間 VCF
rm -f *_raw.vcf.gz* *_genotyped.vcf.gz* snps* indels* merged*

# MarkDuplicates metrics / BQSR table / snpEff zip
rm -f *_metrics.txt *_recal_data.table

# =========================
# 5️⃣ 清理系統與快取 (WSL Ubuntu)
# =========================
# apt 套件管理器快取
sudo apt-get clean
sudo apt-get autoclean
sudo apt-get autoremove

# Node.js 快取
npm cache clean --force
yarn cache clean

# Rust 快取
rm -rf ~/.cargo/registry/cache/*

# WSL 未使用區塊標記
sudo fstrim -v /

# =========================
# 6️⃣ WSL2 VHDX 壓縮 (在 PowerShell 執行)
# =========================
: <<'POWERSHELL'
# 關閉 WSL2
wsl --shutdown

# 查詢 WSL2 vhdx 位置
cd "$env:LOCALAPPDATA\WSL"
# 找到對應的 ext4.vhdx 檔案
# 例如: C:\Users\ASUS\AppData\Local\WSL\{UUID}\ext4.vhdx

# PowerShell 打開 diskpart
diskpart
select vdisk file="C:\Users\ASUS\AppData\Local\WSL\{UUID}\ext4.vhdx"
attach vdisk readonly
compact vdisk
detach vdisk
exit
POWERSHELL

echo "✅ WSL2 管理與清理完成"
