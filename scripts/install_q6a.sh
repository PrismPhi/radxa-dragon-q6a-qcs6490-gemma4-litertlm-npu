#!/usr/bin/env bash
set -euo pipefail

ROOT="${Q6A_GEMMA4_NPU_ROOT:-${HOME}/q6a-gemma4-npu}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$ROOT/packages" "$ROOT/runtime" "$ROOT/logs" "$ROOT/prompts" "$HOME/bin"

install -m 0755 "$REPO_DIR/scripts/q6a-gemma4-npu" "$ROOT/runtime/q6a-gemma4-npu"
install -m 0755 "$REPO_DIR/scripts/q6a-gemma4-npu" "$HOME/bin/q6a-gemma4-npu"

echo "Installed wrapper:"
echo "  $ROOT/runtime/q6a-gemma4-npu"
echo "  $HOME/bin/q6a-gemma4-npu"
echo
echo "Next, place these files manually:"
echo "  $ROOT/packages/gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm"
echo "  $ROOT/runtime/litert_lm_main_q6a_gemma4_npu"
echo "  $ROOT/runtime/lib*.so"
echo
echo "Then run:"
echo "  ./scripts/check_q6a.sh"
echo "  ./scripts/run_smoke.sh"
