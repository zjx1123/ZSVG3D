#!/usr/bin/env bash
# Minimal deps for ZSVG3D preprocess/process_feat_3d.py
set -eu

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

for f in install.sh install_zsvg3d_minimal.sh requirements.txt; do
  [ -f "$f" ] && sed -i 's/\r$//' "$f"
done

# RTX 4090 = sm_89; required when nvidia-smi shows no GPU during build
export TORCH_CUDA_ARCH_LIST="${TORCH_CUDA_ARCH_LIST:-8.9}"
export LD_LIBRARY_PATH="/root/miniconda3/lib/python3.8/site-packages/torch/lib:${LD_LIBRARY_PATH:-}"

pip install multimethod==1.7 shortuuid easydict PyYAML ninja

verify_import() {
  cd /root/ZSVG3D
  python -c "from models.pcd_classifier import PcdClassifier; print('OK')"
}

if verify_import 2>/dev/null; then
  echo "PointNeXt deps already OK, skip CUDA compile."
  exit 0
fi

if ! nvidia-smi >/dev/null 2>&1; then
  echo "WARN: No GPU visible. AutoDL: stop 无卡模式 / pick GPU instance."
  echo "      Building with TORCH_CUDA_ARCH_LIST=$TORCH_CUDA_ARCH_LIST"
fi

cd openpoints/cpp/pointnet2_batch
python setup.py install
cd "$ROOT"

cd openpoints/cpp/chamfer_dist
python setup.py install --user
cd "$ROOT"

cd /root/ZSVG3D
verify_import
echo "Done."
