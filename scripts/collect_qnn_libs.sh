#!/usr/bin/env bash
set -euo pipefail

ROOT="${Q6A_GEMMA4_NPU_ROOT:-${HOME}/q6a-gemma4-npu}"
SRC="${1:-}"

if [[ -z "$SRC" ]]; then
  echo "Usage: $0 /path/to/licensed/qnn/libs" >&2
  echo "This script copies libraries from your own properly licensed QNN runtime." >&2
  exit 2
fi

mkdir -p "$ROOT/runtime"

for name in \
  libGemmaModelConstraintProvider.so \
  libLiteRtDispatch_Qualcomm.so \
  libQnnHtp.so \
  libQnnHtpPrepare.so \
  libQnnHtpV68.so \
  libQnnHtpV68Stub.so \
  libQnnHtpV68Skel.so \
  libQnnSystem.so; do
  if [[ -r "$SRC/$name" ]]; then
    cp "$SRC/$name" "$ROOT/runtime/"
    echo "copied $name"
  else
    echo "missing $SRC/$name"
  fi
done
