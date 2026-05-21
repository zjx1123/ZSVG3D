#!/usr/bin/env bash
# Generate data/scannet/feats_3d.pkl with PointNeXt on GPU.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SCAN_DATA_DIR="${SCAN_DATA_DIR:-$ROOT/data/vil3dref/referit3d/scan_data}"

if [[ ! -d "$SCAN_DATA_DIR/pcd_with_global_alignment" ]]; then
  echo "[ERROR] Missing ScanNet preprocessed data."
  echo "  Expected: $SCAN_DATA_DIR/pcd_with_global_alignment/*.pth"
  echo ""
  echo "Download vil3dref referit3d data (~several GB):"
  echo "  https://www.dropbox.com/s/n0m5bpfvea1fg7w/referit3d.tar.gz?dl=1"
  echo ""
  echo "Then extract so the layout is:"
  echo "  data/vil3dref/referit3d/scan_data/pcd_with_global_alignment/"
  echo "  data/vil3dref/referit3d/scan_data/instance_id_to_name/"
  echo ""
  echo "On AutoDL: upload referit3d.tar.gz to /root/autodl-tmp, then:"
  echo "  mkdir -p data/vil3dref && tar -xzf /root/autodl-tmp/referit3d.tar.gz -C data/vil3dref"
  exit 1
fi

export SCAN_DATA_DIR
echo "Using SCAN_DATA_DIR=$SCAN_DATA_DIR"
echo "GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null || echo 'N/A')"

python preprocess/process_feat_3d.py

echo "Done. Output: $ROOT/data/scannet/feats_3d.pkl"
ls -lh "$ROOT/data/scannet/feats_3d.pkl"
