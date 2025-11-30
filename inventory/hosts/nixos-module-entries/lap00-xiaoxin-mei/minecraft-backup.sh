#!/usr/bin/env bash
set -euo pipefail

# --- 变量定义 ---
RCON_PASS=$(cat /var/lib/minecraft/rcon.pass)
RCON="mcrcon -H 127.0.0.1 -P 25575 -p zju-cst-mc-server"

BACKUP_DIR="/var/lib/minecraft-bakup"
SERVER_DIR="/var/lib/minecraft"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="$BACKUP_DIR/mc_backup_$DATE.tar.zst"

echo "[Start] Starting pure world backup at $DATE"

# --- 阶段 1: 锁定 ---
$RCON "say §eSystem: Starting automated backup..."
$RCON "save-off"
$RCON "save-all"

# --- 阶段 2: 等待落盘 ---
echo "Waiting 15s for disk I/O..."
sleep 15
sync

# --- 阶段 3: 极简压缩 ---
# 逻辑变更：进入 SERVER_DIR，然后只打包 world 目录
# 唯一需要排除的只有 world 内部的 session.lock
echo "Compressing world directory with zstd..."

tar --exclude='world/session.lock' \
    --use-compress-program=zstd \
    -cf "$BACKUP_FILE" \
    -C "$SERVER_DIR" world

# --- 阶段 4: 恢复 ---
echo "Re-enabling saves..."
$RCON "save-on"
$RCON "say §aSystem: Backup completed!"

# --- 阶段 5: 清理 ---
find "$BACKUP_DIR" -name "mc_backup_*.tar.zst" -mtime +7 -type f -delete

echo "[End] Process finished."
