# Third-Party Notices

This repository is a patch and integration project. It intentionally does not
include proprietary runtime libraries or model weights.

## Google Gemma 4 E2B

- Project/model: Gemma 4 E2B
- Upstream: Google
- License: Apache-2.0 as indicated by the current Google/Hugging Face Gemma 4
  E2B model pages. Recheck the upstream model card before redistributing a
  derived `.litertlm` artifact.
- References:
  - https://ai.google.dev/gemma/terms
  - https://ai.google.dev/gemma/apache_2
  - https://huggingface.co/google/gemma-4-e2b-it
  - https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm

The Q6A ctx1024 `.litertlm` artifact is not stored in this GitHub repository. If you
publish a model artifact separately, include the Apache-2.0 license, NOTICE,
source attribution, and a clear modified-artifact statement.

## Google LiteRT-LM / LiteRT

- Project: LiteRT-LM / LiteRT
- Upstream: Google AI Edge
- License: Apache-2.0
- References:
  - https://github.com/google-ai-edge/LiteRT-LM
  - https://github.com/google-ai-edge/LiteRT

The patch in `patches/runtime.patch` is intended for a LiteRT-LM source tree.

## Qualcomm QAIRT / QNN Runtime

- Components commonly needed on Q6A:
  - `libLiteRtDispatch_Qualcomm.so`
  - `libQnnSystem.so`
  - `libQnnHtp.so`
  - `libQnnHtpPrepare.so`
  - `libQnnHtpV68.so`
  - `libQnnHtpV68Stub.so`
  - `libQnnHtpV68Skel.so`

These libraries are not redistributed by this repository. Users must obtain
them from their own Q6A device image, Qualcomm SDK, or another properly
licensed source. Do not upload these libraries to this repository unless you
have confirmed redistribution rights.

## Radxa Dragon Q6A

This project targets Radxa Dragon Q6A with Qualcomm QCS6490/QCM6490-class HTP.
Radxa and Qualcomm trademarks belong to their respective owners.

The Linux/Q6A NPU route described here is unofficial and does not imply vendor
support.
