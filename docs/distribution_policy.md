# Distribution Policy

## GitHub Repository

Publish:

- Source patches
- Scripts
- Documentation
- Benchmark summaries
- Checksums

Do not publish:

- `.litertlm`
- Qualcomm QAIRT/QNN libraries
- model weights
- giant logs or archives
- credentials or private paths

## Optional GitHub Release

You may publish a patched runtime binary if you have verified that the binary is
redistributable under the relevant open-source licenses and does not bundle
proprietary Qualcomm components.

Do not publish QNN shared libraries in the release.

## Model Hosting

Use a separate model-hosting repo for the `.litertlm` artifact. The model card
should clearly state:

- Upstream model
- License
- Modifications
- Hardware target
- Runtime requirements
- SHA256
- No Qualcomm runtime libraries are included

## Qualcomm Runtime

Users must supply Qualcomm runtime components from their own Q6A image, SDK, or
properly licensed source.
