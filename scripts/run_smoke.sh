#!/usr/bin/env bash
set -euo pipefail

ROOT="${Q6A_GEMMA4_NPU_ROOT:-${HOME}/q6a-gemma4-npu}"
WRAPPER="${Q6A_GEMMA4_NPU_WRAPPER:-${HOME}/bin/q6a-gemma4-npu}"
PROMPT_FILE="/tmp/q6a_gemma4_math_prompt.txt"
trap 'rm -f "$PROMPT_FILE"' EXIT

printf '%s' 'MSsx44Gv77yf55+t44GP562U44GI44Gm' | base64 -d > "$PROMPT_FILE"

"$WRAPPER" run \
  "$ROOT/packages/gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm" \
  --backend npu \
  --temperature 0 \
  --max-num-tokens 16 \
  --prompt-file "$PROMPT_FILE"
