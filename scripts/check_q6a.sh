#!/usr/bin/env bash
set -euo pipefail

ROOT="${Q6A_GEMMA4_NPU_ROOT:-${HOME}/q6a-gemma4-npu}"
MODEL="$ROOT/packages/gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm"
RUNTIME="$ROOT/runtime/litert_lm_main_q6a_gemma4_npu"

required=(
  "$MODEL"
  "$RUNTIME"
  "$ROOT/runtime/libGemmaModelConstraintProvider.so"
  "$ROOT/runtime/libLiteRtDispatch_Qualcomm.so"
  "$ROOT/runtime/libQnnHtp.so"
  "$ROOT/runtime/libQnnHtpPrepare.so"
  "$ROOT/runtime/libQnnHtpV68.so"
  "$ROOT/runtime/libQnnHtpV68Stub.so"
  "$ROOT/runtime/libQnnHtpV68Skel.so"
  "$ROOT/runtime/libQnnSystem.so"
)

missing=0
for f in "${required[@]}"; do
  if [[ -r "$f" ]]; then
    echo "OK $f"
  else
    echo "MISSING $f"
    missing=1
  fi
done

echo
df -h "$ROOT" 2>/dev/null || true
echo

if [[ -x "$RUNTIME" ]]; then
  echo "Runtime marker check:"
  marker_output="$(strings "$RUNTIME" | grep -E 'Q6A_FINAL|Q6A_GEMMA4_DIRECT' | head -40 || true)"
  if [[ -n "$marker_output" ]]; then
    echo "$marker_output"
  else
    echo "MISSING Q6A runtime markers in $RUNTIME"
    echo "This usually means you are using a stock or incompatible litert_lm_main."
    missing=1
  fi
fi

exit "$missing"
