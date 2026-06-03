# Performance Notes

These numbers are project observations, not a universal benchmark. Q6A thermal
state, CPU affinity, prompt length, output length, and local QAIRT/QNN library
versions can all change the result.

## Adopted Route Smoke

Adopted-route smoke after cleanup:

| Item | Value |
| --- | --- |
| Prompt | `1+1は？短く答えて` |
| Output | `2` |
| Route | ctx1024 Direct NPU |
| Status | 0 |
| Time to first token | about 2.14 s |
| Prefill speed | about 9.13 tokens/s |
| Decode speed | about 6.08 tokens/s |

Earlier ctx1024 acceptance runs were in the same rough range:

| Prompt | Output | TTFT | Decode |
| --- | --- | --- | --- |
| `1+1は？短く答えて` | `2` | about 2.45 s | about 5.12 tokens/s |
| `日本の首都は？短く答えて` | `東京` | about 2.40 s | about 5.25 tokens/s |

## Route Comparison

| Route | Role | Observed Result |
| --- | --- | --- |
| ctx1024 Direct NPU | Adopted practical default | about 5.1-6.1 decode tokens/s on short smoke prompts |
| ctx4096 / prefill1024 Direct NPU | Long-context comparison route | about 2.7-2.9 decode tokens/s, with TTFT around 4.6 s in project logs |
| Official CPU backend | Baseline and fallback | Competitive for some prompts; measure locally with fixed threads and affinity |
| CPU speculative | Experimental/fallback baseline | Useful comparison route, but not adopted as the NPU package default |
| QNN payload context | HTP invoke proof | Tiny/Gemma4-like payload invoke worked, but full Gemma4 generation did not move to this route |
| WebGPU/Vulkan GPU | Investigated | Accelerator registered, but Gemma4 delegate partitioning was not stable enough |

## Why ctx1024 Was Chosen

ctx1024 Direct NPU was chosen because it gave the best practical combination of:

- short/medium prompt speed,
- acceptable stability after invalid-token resampling,
- simpler packaging than QNN-context experiments,
- normal-ish LiteRT-LM `.litertlm` execution,
- clear NPU route markers.

ctx4096 remains useful when longer context matters, but it was not the fastest
route for everyday short/medium prompts.

## CPU Comparison

CPU is not a weak baseline here. For small LLM execution on Q6A, CPU can be
competitive because the NPU route still has CPU-side work:

- tokenizer and prompt handling,
- input tensor preparation,
- mask/position/parameter helpers,
- KV cache bookkeeping/copy,
- sampling,
- dispatch overhead.

Use `docs/cpu_comparison.md` for a reproducible CPU baseline command.

## Recommended Interpretation

The practical conclusion is:

- Use ctx1024 Direct NPU as the default practical NPU route.
- Use a long-context route only when the prompt actually needs it.
- Keep CPU speculative as a serious baseline/fallback, not as an afterthought.
- Do not treat tiny QNN payload success as proof that full Gemma4 decode/verify
  QNN-context generation is complete.
