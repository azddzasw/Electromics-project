#!/bin/bash
LOCAL_BASE="$(cd "$(dirname "$0")/.." && pwd)"
#LOCAL_BASE=~/Electromics-project
echo "LOCAL_BASE = $LOCAL_BASE"

# 通用配置
REMOTE_USER=swenbo
REMOTE_HOST=front.migale.inrae.fr
REMOTE_BASE=/home/swenbo/work/Electromics-project

# 子目录
DIRS=("data" "results" "models")

echo " upload：${DIRS[@]}"
for dir in "${DIRS[@]}"; do
    SRC="${LOCAL_BASE}/${dir}/"
    DST="${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_BASE}/${dir}/"
    echo "sync ：$SRC → $DST"
    rsync -avz --delete -e ssh "$SRC" "$DST"
done

echo "done"

