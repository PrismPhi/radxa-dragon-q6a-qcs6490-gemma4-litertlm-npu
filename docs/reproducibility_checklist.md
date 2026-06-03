# Reproducibility Checklist

Use this checklist before opening an issue or publishing a result.

## Environment

- [ ] Board is Radxa Dragon Q6A, 12 GB RAM variant.
- [ ] SoC is Qualcomm QCS6490 / QCM6490 family.
- [ ] OS is Ubuntu 24.04.4 LTS, or a clearly documented compatible Linux image.
- [ ] fastrpc / cdsp / adsprpc device plumbing is working.
- [ ] Qualcomm QAIRT/QNN HTP libraries are available from your own licensed environment.
- [ ] QAIRT/QNN runtime is compatible with the tested version
      `2.42.0.251225135753_193295`.

This project is an **unofficial Linux/Q6A NPU route**. It is not an official
Radxa, Qualcomm, or Google supported configuration.

## Required Artifacts

- [ ] `gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm`
- [ ] `litert_lm_main_q6a_gemma4_npu`
- [ ] `q6a-gemma4-npu`
- [ ] `libGemmaModelConstraintProvider.so`
- [ ] `libLiteRtDispatch_Qualcomm.so`
- [ ] QNN HTP libraries:
  - `libQnnSystem.so`
  - `libQnnHtp.so`
  - `libQnnHtpPrepare.so`
  - `libQnnHtpV68.so`
  - `libQnnHtpV68Stub.so`
  - `libQnnHtpV68Skel.so`

The `.litertlm` file and Qualcomm libraries are intentionally not included in
this GitHub repository. See `docs/artifact_sources.md` for where each required
piece should come from.

## Runtime Patch Requirement

- [ ] The runtime binary was built from LiteRT-LM with `patches/runtime.patch`.
- [ ] The patch was applied with `scripts/apply_runtime_patch.sh` or equivalent
      `git apply --check` + `git apply` commands.
- [ ] LiteRT-LM source checkout is the tested commit
      `497e7e28bd89c2b4e0d88e75035b045a21bc33fa`, or the patch has been
      manually ported and marker checks pass.
- [ ] The binary is not a stock `litert_lm_main`.
- [ ] `strings` finds Q6A/Gemma4 Direct markers:

```bash
strings ~/q6a-gemma4-npu/runtime/litert_lm_main_q6a_gemma4_npu \
  | grep -E 'Q6A_GEMMA4_DIRECT|Q6A_FINAL_UNSAFE_TOKEN_POLICY'
```

Expected examples:

```text
Q6A_GEMMA4_DIRECT_MODE_SELECTED
Q6A_GEMMA4_CONTRACT_OK
Q6A_FINAL_UNSAFE_TOKEN_POLICY=resample
```

## Smoke Test

- [ ] `scripts/check_q6a.sh` passes.
- [ ] `scripts/run_smoke.sh` returns `2` for `1+1は？短く答えて`.
- [ ] stderr/logs include the ctx1024 Direct NPU route marker.
- [ ] no unexpected CPU-only fallback is hidden.

## Known Non-Reproducible Pieces

The following are not reproduced automatically by this repository:

- conversion from original safetensors to the ctx1024 `.litertlm`,
- Qualcomm library acquisition,
- exact original Bazel cache/source snapshot,
- full Gemma4 decode/verify QNN-context route,
- GPU/WebGPU route.

Those are intentionally out of scope for the cleaned public repository.
