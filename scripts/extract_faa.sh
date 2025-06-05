#!/bin/bash


TAR_FILE="gtdb_proteins_aa_reps_r226.tar.gz"
OUT_DIR="./selected_faa"
ACCESSION_FILE="accession_list.txt"

mkdir -p "$OUT_DIR"

# 获取所有归档中文件路径列表
echo "🔍 Indexing tar file..."
tar -tzf "$TAR_FILE" > all_faa_files.txt

# 遍历 accession 列表查找匹配
while read acc; do
    match=$(grep "${acc}" all_faa_files.txt | head -n 1)
    if [ -n "$match" ]; then
        echo "📦 Extracting: $match"
        tar -xvzf "$TAR_FILE" -C "$OUT_DIR" "$match"
    else
        echo "❌ Not found: $acc"
    fi
done < "$ACCESSION_FILE"
