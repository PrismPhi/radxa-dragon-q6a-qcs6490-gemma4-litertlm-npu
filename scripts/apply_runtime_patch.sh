#!/usr/bin/env bash
set -euo pipefail

CHECK_ONLY=0
if [[ $# -eq 2 && "$1" == "--check-only" ]]; then
  CHECK_ONLY=1
  shift
fi

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 [--check-only] /path/to/LiteRT-LM" >&2
  exit 2
fi

LITERT_LM_DIR="$1"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PATCH_FILE="$REPO_DIR/patches/runtime.patch"
TARGET_FILE="$LITERT_LM_DIR/runtime/executor/llm_litert_npu_compiled_model_executor.cc"
GIT_APPLY_ARGS=(--ignore-space-change --ignore-whitespace)

if [[ ! -d "$LITERT_LM_DIR/.git" ]]; then
  echo "Not a git checkout: $LITERT_LM_DIR" >&2
  exit 2
fi

if [[ ! -r "$PATCH_FILE" ]]; then
  echo "Missing patch: $PATCH_FILE" >&2
  exit 2
fi

if [[ ! -r "$TARGET_FILE" ]]; then
  echo "Missing expected LiteRT-LM target file:" >&2
  echo "  $TARGET_FILE" >&2
  echo "The upstream LiteRT-LM layout may have changed." >&2
  exit 2
fi

cd "$LITERT_LM_DIR"

if ! git diff --quiet --ignore-cr-at-eol --ignore-space-at-eol -- \
  runtime/executor/llm_litert_npu_compiled_model_executor.cc; then
  echo "Target file has local modifications. Commit, stash, or reset them first:" >&2
  echo "  runtime/executor/llm_litert_npu_compiled_model_executor.cc" >&2
  exit 2
fi

echo "Checking patch against: $LITERT_LM_DIR"
git apply "${GIT_APPLY_ARGS[@]}" --check "$PATCH_FILE"

if [[ "$CHECK_ONLY" -eq 1 ]]; then
  echo "Patch check passed. No files were modified."
  exit 0
fi

echo "Applying patch..."
git apply "${GIT_APPLY_ARGS[@]}" "$PATCH_FILE"

echo "Patch applied."
echo
echo "Next build command:"
echo "  cd \"$LITERT_LM_DIR\""
echo "  bazel build -c opt --jobs=4 //runtime/engine:litert_lm_main"
echo
echo "After build, copy:"
echo "  bazel-bin/runtime/engine/litert_lm_main"
echo "to:"
echo "  ~/q6a-gemma4-npu/runtime/litert_lm_main_q6a_gemma4_npu"
