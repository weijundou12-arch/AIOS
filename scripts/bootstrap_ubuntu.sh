#!/usr/bin/env bash
set -euo pipefail

echo "[AIOS] Installing base dependencies..."
sudo apt-get update
sudo apt-get install -y python3 python3-venv python3-pip cargo nodejs npm sqlite3

echo "[AIOS] Bootstrap complete."
