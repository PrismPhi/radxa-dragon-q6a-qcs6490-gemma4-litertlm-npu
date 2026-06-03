# Build The Patched Runtime

The simplest reproduction route is to use a prebuilt patched runtime binary.
If you want to rebuild, apply `patches/runtime.patch` to a compatible LiteRT-LM
source tree.

## Tested Build Environment

- Radxa Dragon Q6A
- 12 GB RAM
- Qualcomm QCS6490 / QCM6490 family
- Ubuntu 24.04.4 LTS
- QAIRT/QNN runtime `2.42.0.251225135753_193295`
- Bazel aarch64 optimized build

The runtime patch is not optional for the Q6A Gemma4 Direct NPU route. The
patched binary adds the Gemma4 Direct execution path needed by the ctx1024
artifact.

## Source Tree

The patch targets:

```text
runtime/executor/llm_litert_npu_compiled_model_executor.cc
```

The original build was performed on Q6A with Bazel and an aarch64 optimized
target. The tested source snapshot for this public reproduction is:

```text
LiteRT-LM commit: 497e7e28bd89c2b4e0d88e75035b045a21bc33fa
Commit subject: Get quant param from decode signature.
```

As of 2026-06-03, the patch does not apply directly to the latest upstream
LiteRT-LM `main` checkout. Use the commit above, or manually port the patch.

## Full Source Build Flow

After obtaining the official LiteRT-LM source tree yourself, apply this
repository's runtime patch to that checkout.

Example layout:

```text
~/src/LiteRT-LM/
~/src/radxa-dragon-q6a-qcs6490-gemma4-litertlm-npu/
```

Clone the upstream source and this patch repository:

```bash
mkdir -p ~/src
cd ~/src
git clone https://github.com/google-ai-edge/LiteRT-LM.git
cd LiteRT-LM
git checkout 497e7e28bd89c2b4e0d88e75035b045a21bc33fa
cd ..
git clone https://github.com/PrismPhi/radxa-dragon-q6a-qcs6490-gemma4-litertlm-npu.git
```

If you are cloning on Windows, disable automatic CRLF conversion for the
LiteRT-LM checkout or build directly on Q6A/Linux:

```bash
git -c core.autocrlf=false clone https://github.com/google-ai-edge/LiteRT-LM.git
```

If the patch does not apply to the latest upstream tree, use the recorded
snapshot above or manually port the patch.

## Apply Patch With The Helper Script

To verify compatibility without modifying the LiteRT-LM checkout:

```bash
~/src/radxa-dragon-q6a-qcs6490-gemma4-litertlm-npu/scripts/apply_runtime_patch.sh \
  --check-only ~/src/LiteRT-LM
```

To apply the patch:

```bash
~/src/radxa-dragon-q6a-qcs6490-gemma4-litertlm-npu/scripts/apply_runtime_patch.sh \
  ~/src/LiteRT-LM
```

The helper script runs `git apply --check` first and refuses to patch a dirty
target file. With `--check-only`, it does not modify any files.

## Apply Patch Manually

You can also apply the patch manually:

```bash
cd ~/src/LiteRT-LM
git apply --ignore-space-change --ignore-whitespace --check \
  ~/src/radxa-dragon-q6a-qcs6490-gemma4-litertlm-npu/patches/runtime.patch
git apply --ignore-space-change --ignore-whitespace \
  ~/src/radxa-dragon-q6a-qcs6490-gemma4-litertlm-npu/patches/runtime.patch
```

If the patch does not apply cleanly, inspect the target file manually. LiteRT-LM
may have changed since the original Q6A build. In that case, do not continue
with a stock runtime and expect the Q6A Gemma4 Direct NPU route to work. Use a
compatible source snapshot or port the patch.

## Build

```bash
bazel build -c opt --jobs=4 //runtime/engine:litert_lm_main
```

Copy the result:

```bash
mkdir -p ~/q6a-gemma4-npu/runtime
cp bazel-bin/runtime/engine/litert_lm_main \
  ~/q6a-gemma4-npu/runtime/litert_lm_main_q6a_gemma4_npu
```

Then install this repository's wrapper:

```bash
cd ~/src/radxa-dragon-q6a-qcs6490-gemma4-litertlm-npu
./scripts/install_q6a.sh
```

Place the ctx1024 `.litertlm` artifact under:

```text
~/q6a-gemma4-npu/packages/gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm
```

Copy your own properly licensed QNN/LiteRT runtime libraries into:

```text
~/q6a-gemma4-npu/runtime/
```

You can use:

```bash
./scripts/collect_qnn_libs.sh /path/to/your/licensed/qnn/libs
```

## Marker Check

```bash
strings ~/q6a-gemma4-npu/runtime/litert_lm_main_q6a_gemma4_npu \
  | grep -E 'Q6A_FINAL|Q6A_GEMMA4_DIRECT'
```

Expected marker examples. `Q6A_FINAL_*` is a historical marker prefix retained
inside the original local runtime patch:

```text
Q6A_FINAL_UNSAFE_TOKEN_POLICY=resample
Q6A_FINAL_SAMPLE_RESAMPLED
Q6A_GEMMA4_DIRECT_MODE_SELECTED
Q6A_GEMMA4_CONTRACT_OK
```

Finally run:

```bash
./scripts/check_q6a.sh
./scripts/run_smoke.sh
```
