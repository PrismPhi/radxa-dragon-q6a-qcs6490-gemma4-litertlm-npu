# Radxa Dragon Q6A (Unofficial) / QCS6490 Gemma4 LiteRT-LM NPU

Unofficial practical Gemma 4 E2B LiteRT-LM runtime patches and scripts for
Radxa Dragon Q6A / Qualcomm QCS6490.

This is an **unofficial community project**. It is not an official Radxa,
Qualcomm, Google, Gemma, LiteRT, or LiteRT-LM release, and it is not vendor
supported.

[日本語README](README.ja.md)

The adopted practical route from this project is **ctx1024 Direct NPU**. Full
Gemma4 decode/verify QNN-context execution was investigated but was not adopted
as the fastest practical route.

## Tested Environment

- Board: Radxa Dragon Q6A
- RAM: 12 GB
- SoC: Qualcomm QCS6490 / QCM6490 family
- OS: Ubuntu 24.04.4 LTS
- Runtime: patched LiteRT-LM with Qualcomm NPU backend / QNN HTP dispatch
- Tested QAIRT/QNN runtime: `2.42.0.251225135753_193295`

This route requires the patched runtime described in `docs/runtime_patch.md`.
The ctx1024 `.litertlm` artifact is not expected to run through a stock
LiteRT-LM binary from the original tested source snapshot unless equivalent
Gemma4 Direct support is ported.

This is also an **unofficial Ubuntu Linux NPU route** for Q6A/QCS6490. See
`docs/linux_q6a_npu_notes.md` for the scope and caveats.

This project and its documentation were prepared with substantial assistance
from OpenAI Codex. See `docs/project_provenance.md`.

## What This Repository Contains

- LiteRT-LM runtime patch: `patches/runtime.patch`
- Q6A runner script: `scripts/q6a-gemma4-npu`
- Q6A install/check scripts
- Reproduction notes and benchmark summary
- License and third-party notices

## Reproducibility Status

This repository is sufficient to reproduce the cleaned runtime layout and Q6A
smoke flow **if** you separately provide the model artifact, patched runtime
binary or compatible build environment, and Qualcomm QAIRT/QNN libraries.

It is not a single-repository reproduction because `.litertlm` model artifacts
and Qualcomm runtime libraries are intentionally not redistributed here. See
`docs/reproducibility_checklist.md` and `docs/artifact_sources.md`.

The adopted Q6A ctx1024 `.litertlm` artifact is published separately on
Hugging Face:
<https://huggingface.co/PrismPhi/gemma4-e2b-q6a-qcs6490-litertlm-npu>.

## What This Repository Does Not Contain

- Gemma model weights
- `.litertlm` model containers
- Qualcomm QAIRT/QNN runtime libraries
- QNN context binaries
- Large experiment logs or build caches

This is intentional. Qualcomm runtime libraries and model artifacts have their
own licenses and distribution constraints.

## Expected Q6A Layout

```text
~/q6a-gemma4-npu/
  packages/
    gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm
  runtime/
    litert_lm_main_q6a_gemma4_npu
    q6a-gemma4-npu
    libGemmaModelConstraintProvider.so
    libLiteRtDispatch_Qualcomm.so
    libQnnHtp.so
    libQnnHtpPrepare.so
    libQnnHtpV68.so
    libQnnHtpV68Skel.so
    libQnnHtpV68Stub.so
    libQnnSystem.so
```

The wrapper is installed as:

```text
/home/radxa/bin/q6a-gemma4-npu
```

## Quick Start

1. Prepare the model artifact:

```bash
mkdir -p ~/q6a-gemma4-npu/packages
hf download PrismPhi/gemma4-e2b-q6a-qcs6490-litertlm-npu \
  gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm \
  --local-dir ~/q6a-gemma4-npu/packages
```

2. Prepare the runtime binary and QNN libraries:

```bash
mkdir -p ~/q6a-gemma4-npu/runtime
cp litert_lm_main_q6a_gemma4_npu ~/q6a-gemma4-npu/runtime/
cp libGemmaModelConstraintProvider.so ~/q6a-gemma4-npu/runtime/
cp libLiteRtDispatch_Qualcomm.so ~/q6a-gemma4-npu/runtime/
cp libQnn*.so ~/q6a-gemma4-npu/runtime/
```

If you need to build the patched runtime yourself, follow
`docs/build_runtime.md`. In short, clone official LiteRT-LM, run
`scripts/apply_runtime_patch.sh /path/to/LiteRT-LM`, build
`//runtime/engine:litert_lm_main`, then copy the binary as
`litert_lm_main_q6a_gemma4_npu`.

3. Install the wrapper:

```bash
./scripts/install_q6a.sh
```

4. Run a smoke test:

```bash
./scripts/run_smoke.sh
```

Or run directly:

```bash
printf '%s' 'MSsx44Gv77yf55+t44GP562U44GI44Gm' | base64 -d > /tmp/q6a_prompt.txt
/home/radxa/bin/q6a-gemma4-npu run \
  ~/q6a-gemma4-npu/packages/gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm \
  --backend npu \
  --temperature 0 \
  --prompt-file /tmp/q6a_prompt.txt
```

The base64 prompt is:

```text
1+1は？短く答えて
```

Expected answer:

```text
2
```

## Runtime Behavior

- Default route: ctx1024 Direct NPU
- `--backend npu` is accepted by the wrapper
- `--max-num-tokens` is treated as requested output tokens and clamped to the
  ctx1024 safety budget
- Invalid sampled token IDs are resampled from valid logits candidates
- The old fixed replacement token policy was removed
- Generated text streams on stdout; backend logs are saved separately

## Known Limits

- Best practical route is ctx1024 Direct NPU, not full QNN-context Gemma4 decode.
- A patched LiteRT-LM runtime is required for this tested artifact/runtime
  combination; newer upstream LiteRT-LM NPU support still needs separate
  compatibility verification.
- Long context prompts should use a separate long-context route if you build one.
- Qualcomm QAIRT/QNN libraries are not redistributed here.
- Rebuilding the patched runtime requires a LiteRT-LM checkout compatible with
  `patches/runtime.patch`.
- Tested LiteRT-LM source commit for this patch:
  `497e7e28bd89c2b4e0d88e75035b045a21bc33fa`.

## More Docs

- Japanese docs:
  - `README.ja.md`
  - `docs/reproduce.ja.md`
  - `docs/reproducibility_checklist.ja.md`
  - `docs/artifact_sources.ja.md`
  - `docs/build_runtime.ja.md`
  - `docs/runtime_patch.ja.md`
  - `docs/linux_q6a_npu_notes.ja.md`
  - `docs/npu_route.ja.md`
  - `docs/performance.ja.md`
  - `docs/cpu_comparison.ja.md`
  - `docs/model_artifact.ja.md`
  - `docs/distribution_policy.ja.md`
  - `docs/project_provenance.ja.md`
  - `CONTACT.ja.md`

- English docs:
  - `docs/reproduce.md`
  - `docs/reproducibility_checklist.md`
  - `docs/artifact_sources.md`
  - `docs/build_runtime.md`
  - `docs/runtime_patch.md`
  - `docs/linux_q6a_npu_notes.md`
  - `docs/model_artifact.md`
  - `docs/npu_route.md`
  - `docs/performance.md`
  - `docs/cpu_comparison.md`
  - `docs/distribution_policy.md`
  - `docs/project_provenance.md`
  - `LICENSE_AUDIT.md`
  - `CONTACT.md`
