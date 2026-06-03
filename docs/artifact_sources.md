# Artifact Sources

This repository does not bundle the model artifact, Qualcomm runtime libraries,
or upstream LiteRT-LM source tree. Users must obtain those pieces themselves.

## What To Get

| Item | Where to get it | Tested version / revision | Why it is needed | Included here? |
| --- | --- | --- | --- | --- |
| LiteRT-LM source tree | <https://github.com/google-ai-edge/LiteRT-LM> | `497e7e28bd89c2b4e0d88e75035b045a21bc33fa` | Apply `patches/runtime.patch` and build `litert_lm_main` | No |
| Gemma 4 E2B base model | <https://huggingface.co/google/gemma-4-e2b-it> | Model family/license reference; not directly required if using the Q6A artifact below | Upstream model lineage and license reference | No |
| Official LiteRT-LM Gemma4 artifact family | <https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm> | Reference family; not the adopted Q6A ctx1024 artifact | Reference family for Gemma4 `.litertlm` packaging | No |
| Q6A ctx1024 NPU `.litertlm` | <https://huggingface.co/PrismPhi/gemma4-e2b-q6a-qcs6490-litertlm-npu> | SHA256 `0d72585954b3855df20735b666926b5617c0e4a43528be6c00abe06fa0812347` | Adopted practical model package for this Q6A route | No |
| Patched runtime binary | Build from LiteRT-LM source using this repo's patch, or obtain from a release if one is published | Built from the LiteRT-LM commit above plus `patches/runtime.patch`; original local SHA was `aadac7a2ebc34cdf899d8eaf4eeab3fdd0e103e470540399b580b40afcac1c91` | Required runtime for the Q6A Gemma4 Direct NPU route | No binary in git |
| `libGemmaModelConstraintProvider.so` | Compatible LiteRT-LM prebuilt/build output, usually `prebuilt/linux_arm64` after the upstream source/LFS setup | Must be compatible with the patched runtime build | Runtime companion library | No |
| `libLiteRtDispatch_Qualcomm.so` | Compatible LiteRT/LiteRT-LM Qualcomm NPU dispatch build/output | Must be compatible with the patched runtime and QNN runtime | Qualcomm NPU dispatch | No |
| QNN HTP libraries (`libQnn*.so`) | Your Q6A image, Radxa QAIRT setup, Qualcomm AI Runtime SDK, or another properly licensed source | Tested QAIRT/QNN `2.42.0.251225135753_193295` | QNN/HTP backend runtime | No |

The tested Q6A runtime used QAIRT/QNN
`2.42.0.251225135753_193295`. Other versions may work, but should be treated as
untested until `scripts/check_q6a.sh` and the smoke test pass.

Use the QNN libraries as a matched set. Avoid mixing `libQnnHtp.so`,
`libQnnSystem.so`, skel/stub libraries, and LiteRT Qualcomm dispatch libraries
from unrelated releases unless you are intentionally debugging a version
compatibility issue.

For the model artifact, the simplest public reproduction path is:

```bash
hf download PrismPhi/gemma4-e2b-q6a-qcs6490-litertlm-npu \
  gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm \
  --local-dir ~/q6a-gemma4-npu/packages
sha256sum ~/q6a-gemma4-npu/packages/gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm
```

The expected SHA256 is:

```text
0d72585954b3855df20735b666926b5617c0e4a43528be6c00abe06fa0812347
```

## Upstream Links

- LiteRT-LM source:
  <https://github.com/google-ai-edge/LiteRT-LM>
- Gemma 4 E2B base model:
  <https://huggingface.co/google/gemma-4-e2b-it>
- LiteRT-LM Gemma4 reference artifact family:
  <https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm>
- Radxa Dragon Q6A product/docs entry point:
  <https://radxa.com/products/dragon/q6a/>
- Radxa Dragon Q6A QAIRT usage notes:
  <https://docs.radxa.com/en/dragon/q6a/app-dev/npu-dev/qairt-usage>
- Qualcomm AI software portal:
  <https://www.qualcomm.com/developer/artificial-intelligence/software>
- Qualcomm AI Engine Direct SDK entry point:
  <https://www.qualcomm.com/developer/software/qualcomm-ai-engine-direct-sdk>

The Qualcomm links are entry points, not redistribution permission. Use only SDK
and runtime files that your account, board image, or vendor package permits you
to use.

## Important Status

The exact adopted model file from the local project was:

```text
gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm
SHA256: 0d72585954b3855df20735b666926b5617c0e4a43528be6c00abe06fa0812347
```

That ctx1024 Q6A artifact is published separately on Hugging Face:

<https://huggingface.co/PrismPhi/gemma4-e2b-q6a-qcs6490-litertlm-npu>

It is intentionally not stored in this GitHub repository. Readers need both the
GitHub runtime/scripts repository and the Hugging Face model artifact repository
to reproduce the adopted Q6A ctx1024 NPU generation route.

## Suggested Download Flow

1. Clone this repository.
2. Clone official LiteRT-LM.
3. Apply the runtime patch with `scripts/apply_runtime_patch.sh`.
4. Build the patched runtime binary.
5. Download the Q6A ctx1024 `.litertlm` artifact from the Hugging Face model
   artifact repository.
6. Obtain Qualcomm runtime libraries from your own licensed Q6A/QAIRT
   environment.
7. Run `scripts/check_q6a.sh`.
8. Run `scripts/run_smoke.sh`.

## Notes On Qualcomm Libraries

Do not upload Qualcomm runtime libraries to this GitHub repository. The helper
script `scripts/collect_qnn_libs.sh` only copies libraries from a path that the
user provides locally.

Radxa publishes QAIRT setup documentation for Dragon Q6A, and Qualcomm publishes
QAIRT/QNN documentation and SDK materials. Use only sources you are licensed to
access.
