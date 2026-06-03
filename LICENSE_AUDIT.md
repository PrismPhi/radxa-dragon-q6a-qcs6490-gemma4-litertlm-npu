# License Audit And Publication Policy

This is not legal advice. It is the publication policy used for this repository.

## Safe To Publish In This GitHub Repository

- Source patches against LiteRT-LM
- Shell scripts and helper scripts written for this project
- Documentation
- Benchmark summaries
- SHA256 manifests that do not include private secrets

## Do Not Publish In This GitHub Repository

- `*.litertlm`
- Gemma weights or converted model weights
- Qualcomm QAIRT/QNN shared libraries (`libQnn*.so`, dispatch `.so`)
- QNN context binaries unless redistribution rights are confirmed
- Full work directories, logs with credentials, SSH details, tokens, or private paths
- Bazel caches or toolchain archives

## Recommended Artifact Split

Use two publication surfaces:

1. GitHub repository for source patches, scripts, and documentation.
2. A model hosting repository, such as Hugging Face, for the `.litertlm`
   artifact if you choose to redistribute it under the applicable model license.

Qualcomm runtime libraries must be supplied by the user from their own properly
licensed Q6A/QAIRT environment.

## Current License Recheck Notes

This repository keeps the licensing posture conservative:

- LiteRT-LM / LiteRT source patches are treated as Apache-2.0-derived patch
  material against the Google AI Edge source tree.
- Google Gemma 4 E2B model pages currently identify the model license as
  Apache-2.0, but the `.litertlm` artifact is still kept out of this GitHub
  repository. If it is published separately, include the license, NOTICE,
  source attribution, SHA256, hardware target, and a clear modification note.
- Qualcomm QAIRT/QNN shared libraries and context binaries are not published
  here. Users must supply them from their own licensed device image, SDK, or
  other properly licensed source.
- This is not an official Radxa, Qualcomm, or Google supported release.

Do not infer redistribution rights from the fact that the runtime worked on the
developer's Q6A. Runtime success and redistribution permission are separate
questions.

## Modification Notice

The runtime patch modifies LiteRT-LM NPU execution behavior for Gemma 4 E2B on
Q6A/QCS6490, including:

- Gemma4 Direct execution markers
- ctx1024-oriented practical route
- valid-vocabulary resampling for invalid sampled token IDs
- removal of fixed unsafe-token replacement with token `106`
- stdout/stderr behavior closer to stock LiteRT-LM CPU output

## Artifact Status

The local development package used during the closing run was:

- `gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm`
- SHA256: `0d72585954b3855df20735b666926b5617c0e4a43528be6c00abe06fa0812347`

That artifact is intentionally not included in this GitHub repository.
