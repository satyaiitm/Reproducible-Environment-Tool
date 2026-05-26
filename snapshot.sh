#!/bin/bash
set -euo pipefail


# ======= set up the upload folder======
DATE=$(date +%y-%m-%d_%H-%M-%S)
SNAPSHOTS_DIR="env_snapshot_$DATE"
mkdir -p "$SNAPSHOT_DIR"

# ======= capture the packages info =====
pip freeze > "$SNAPSHOT_DIR/pip_requirements.txt"


# =========== capture the CUDA and GPU info
nvidia-smi > "$SNAPSHOT_DIR/gpu_info.txt" 2>/dev/null || echo "nvidia not found"

# ====== capture system info
uname -a > "$SNAPSHOT_DIR/system_info.txt"
lsb_release -a >> "$SNAPSHOT_DIR/system_info.txt" 2>/dev/null
python --version >> "$SNAPSHOT_DIR/system_info.txt"
which python >> "$SNAPSHOT_DIR/system_info.txt"


#  ======= capture environment variables
printenv | grep -E "CUDA|PYTHON" > " $SNAPSHOT_DIR/env_variables.txt"

# ===== metadata JSON

cat > "$SNAPSHOT_DIR/metadata.json"<< EOF
{
"snapshot_date : "$DATE",
"hostname" : "$(hostname)",
"user" : "$(whoami)",
"python_version" : "$(python --version 2>&1)"
}
EOF

# ==== compress
tar -czf "env_snapshot_$DATE.tar.gz" "$SNAPSHOT_DIR"
rm -rf "$SNAPSHOT_DIR"
echo "Snapshot saved : env_snapshot_$DATE.tar.gz"

