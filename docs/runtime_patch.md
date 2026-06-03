# Runtime Patch Notes

This project requires a **patched LiteRT-LM runtime**.

The ctx1024 `.litertlm` artifact and Q6A NPU route are not expected to work with
a stock LiteRT-LM binary from the original tested source snapshot unless
equivalent Gemma4 Direct support is ported.

## Tested Environment

The original working environment was:

| Item | Value |
| --- | --- |
| Board | Radxa Dragon Q6A |
| RAM | 12 GB |
| SoC | Qualcomm QCS6490 / QCM6490 family |
| OS | Ubuntu 24.04.4 LTS |
| Runtime path | LiteRT-LM with Qualcomm NPU backend / QNN HTP dispatch |
| Required device plumbing | fastrpc / cdsp / adsprpc working |

Other QCS6490/QCM6490 Linux images may work, but they should be treated as
untested until the smoke test and NPU markers pass.

## Why Stock LiteRT-LM Is Not Enough

The public model artifact uses the Gemma4 Direct contract. The older NPU
executor path in LiteRT-LM was strongly shaped around a Gemma3-style AUX model.
That older path expects helper signatures such as mask generation, RoPE
generation, and cache update helpers.

Gemma4 E2B is different:

- no Gemma3-style `TF_LITE_AUX` requirement,
- direct `prefill_128` / `prefill_1024` / `decode` signatures,
- direct KV cache input/output binding,
- CPU-side construction of `input_pos`, `mask`, and `param_tensor`,
- CPU-side sampling and safety handling.

Without the runtime patch, the model is likely to fail due to missing AUX
sections, signature mismatch, unsupported route selection, or invalid state
handling.

## What The Patch Adds

The patch in `patches/runtime.patch` contains the practical Q6A/Gemma4 runtime
changes, including:

- Gemma4 Direct route selection,
- contract checks for Gemma4 signatures,
- direct `prefill_128` / `prefill_1024` / `decode` invocation,
- KV cache binding and state handling for the direct contract,
- ctx1024 safety budget handling,
- invalid sampled token resampling,
- runtime markers for Q6A/Gemma4/NPU debugging.

This patch is intentionally kept as a patch rather than a complete vendored
LiteRT-LM tree, so the GitHub repository does not redistribute large source
snapshots or third-party build products.

## Required Binary

The expected runtime binary name is:

```text
litert_lm_main_q6a_gemma4_npu
```

It should be placed under:

```text
~/q6a-gemma4-npu/runtime/
```

The wrapper calls this patched binary. If you replace it with a stock
`litert_lm_main`, the Q6A Gemma4 NPU route should be considered unverified.
Newer upstream LiteRT-LM releases may add or change NPU support; verify the
Gemma4 Direct contract and markers before treating them as compatible.

## Marker Check

Before testing generation, check that the binary contains the Q6A/Gemma4 markers:

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

The `Q6A_FINAL_*` prefix is a historical marker name retained from the local
runtime experiments. It does not mean this repository publishes a final upstream
LiteRT-LM implementation.
