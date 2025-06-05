#!/bin/bash

# =================== config ===================
REMOTE_USER="swenbo"                   
REMOTE_HOST="front.migale.inrae.fr"        
REMOTE_DIR="/work_projet/electromic/atlas-results/genomes/annotations/genes/"         
LOCAL_DIR="data/all_fna"                  

# ==============================================

echo " start connecting to server $REMOTE_USER@$REMOTE_HOST..."
echo " download：$REMOTE_DIR"
echo " local position：$LOCAL_DIR"

mkdir -p "$LOCAL_DIR"

rsync -avz \
    --include="*/" \
    --include="*.fna" \
    --exclude="*" \
    "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR" \
    "$LOCAL_DIR"

echo "✅ finiehed, saved to：$LOCAL_DIR"
