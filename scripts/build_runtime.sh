#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 /path/to/LiteRT-LM" >&2
  exit 2
fi

LITERT_LM_DIR="$1"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="${Q6A_GEMMA4_NPU_ROOT:-${HOME}/q6a-gemma4-npu}"

"$REPO_DIR/scripts/apply_runtime_patch.sh" "$LITERT_LM_DIR"

cd "$LITERT_LM_DIR"
bazel build -c opt --jobs="${BAZEL_JOBS:-4}" //runtime/engine:litert_lm_main

mkdir -p "$ROOT/runtime"
cp bazel-bin/runtime/engine/litert_lm_main "$ROOT/runtime/litert_lm_main_q6a_gemma4_npu"
chmod +x "$ROOT/runtime/litert_lm_main_q6a_gemma4_npu"

echo "Built runtime:"
sha256sum "$ROOT/runtime/litert_lm_main_q6a_gemma4_npu"
