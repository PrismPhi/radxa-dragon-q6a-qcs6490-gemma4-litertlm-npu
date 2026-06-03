# NPU Route Explained

This project targets **Radxa Dragon Q6A (Unofficial) / Qualcomm QCS6490** with
Gemma 4 E2B in LiteRT-LM format.

The adopted practical route is called **ctx1024 Direct NPU**.

## Short Version

The final practical runtime does not use a custom ONNX runner or an external
QNN-only runner as the main result. It keeps the model as a LiteRT-LM
`.litertlm` package and runs through a patched LiteRT-LM runtime/wrapper.

The workload is split like this:

| Component | Runs On | Notes |
| --- | --- | --- |
| Tokenization and prompt handling | CPU | Standard LiteRT-LM-side work. |
| Embedding and LLM graph invocation | NPU path | Through LiteRT/LiteRT-LM Qualcomm NPU backend and QNN HTP dispatch. |
| Gemma4 `prefill_*` / `decode` main graph | NPU path | The practical adopted route uses Gemma4 Direct signatures. |
| Position, mask, parameter helpers | CPU | Built/bound by runtime-side code. |
| KV bookkeeping/copy | CPU-side helper work | Still a meaningful source of overhead. |
| Sampling and invalid-token guard | CPU | The final wrapper/runtime resamples invalid token IDs instead of using a fixed replacement. |
| Text streaming and logs | CPU | User-facing output is streamed to stdout; backend logs are kept separate. |

## Why "Direct" NPU?

The older Gemma3-style NPU path expected an auxiliary TFLite model with
signatures such as mask generation, RoPE generation, and cache update helpers.
That style is referred to here as the **Gemma3 AUX** path.

Gemma4 E2B uses a different contract. The relevant model signatures are closer
to:

- `prefill_128`
- `prefill_1024`
- `decode`
- `verify`

The Gemma4 package does not rely on a Gemma3-style `TF_LITE_AUX` model for
`decode_mask`, `decode_rope`, or `decode_cache_update`. Instead, the Gemma4
graph accepts direct inputs such as embeddings, `input_pos`, `mask`,
`param_tensor`, per-layer embeddings, and KV cache tensors.

That is why this runtime adds a Gemma4 Direct route instead of trying to force
Gemma4 into the older Gemma3 AUX contract.

## What Actually Uses the NPU?

The successful practical route invokes the Gemma4 prefill/decode graph through
the LiteRT-LM NPU backend path. On Q6A, the backend reaches Qualcomm QNN HTP
dispatch.

Expected log markers from the patched runtime include strings similar to:

```text
Q6A_GEMMA4_DIRECT_MODE_SELECTED
Q6A_GEMMA4_CONTRACT_OK
Q6A_GEMMA4_PREFILL128_START
Q6A_GEMMA4_PREFILL128_DONE
Q6A_GEMMA4_DECODE_START
Q6A_GEMMA4_DECODE_DONE
Q6A_GEMMA4_LOGITS_READ_OK
```

The public package does not include Qualcomm libraries, so exact logs depend on
your local QAIRT/QNN installation.

## Why ctx1024?

Several context and route variants were tried during the project.

The adopted ctx1024 route was the best practical balance:

- substantially faster than the long-context ctx4096 route in short/medium use,
- stable enough after adding output-token guards,
- simpler than the experimental QNN-context payload routes,
- closer to normal LiteRT-LM model execution than an external runner.

Long-context prompts still need a longer-context route. The ctx1024 package is
the practical default, not a universal replacement for every prompt length.

## Routes Tried But Not Adopted

| Route | Result |
| --- | --- |
| Full Gemma4 decode/verify QNN context | Investigated, but not adopted as a working faster generation route. |
| QNN payload context inside `.litertlm` | HTP invocation was proven with tiny/Gemma4-like payloads, but not adopted for Gemma4 generation speed. |
| CPU+NPU speculative / MTP hybrid | Verify probing worked, but it did not become the practical default. |
| WebGPU/Vulkan GPU backend | WebGPU accelerator loaded and Turnip Adreno 643 was detected, but Gemma4 graph partitioning was not stable enough to adopt. |
| ctx4096 Direct NPU | Useful long-context comparison route, but slower than ctx1024 for short/medium prompts. |

## Important Non-Claims

This repository does not claim that:

- full Gemma4 decode/verify QNN-context generation is complete,
- QCS6490 is an officially supported LiteRT Qualcomm NPU target,
- the NPU route is always faster than CPU for every prompt,
- bundled Qualcomm binaries or Gemma model weights can be redistributed here.

The practical claim is narrower:

> On the tested Q6A setup, the ctx1024 Gemma4 Direct NPU route was the fastest
> practical NPU route found during this project, and the repo preserves the
> runtime patch, wrapper, and reproduction notes needed to recreate it locally.
