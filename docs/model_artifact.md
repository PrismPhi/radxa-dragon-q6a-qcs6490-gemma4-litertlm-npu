# Model Artifact

The Q6A ctx1024 model artifact is not stored in this GitHub repository. It is
published separately on Hugging Face:

<https://huggingface.co/PrismPhi/gemma4-e2b-q6a-qcs6490-litertlm-npu>

Original local artifact name:

```text
gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm
```

Original SHA256:

```text
0d72585954b3855df20735b666926b5617c0e4a43528be6c00abe06fa0812347
```

## Recommended Hosting

Host the `.litertlm` on a model hosting service such as Hugging Face, not in the
GitHub repository. Include:

- Apache-2.0 license
- NOTICE
- Source attribution
- SHA256
- Hardware target
- Known limitations
- Runtime compatibility notes

## Model Lineage To Document

- Upstream base: Google Gemma 4 E2B instruction-tuned model
- LiteRT-LM artifact family: Gemma 4 E2B LiteRT-LM
- Local adopted route: ctx1024 Direct NPU for Q6A/QCS6490

## Do Not Bundle

Do not bundle Qualcomm QAIRT/QNN runtime libraries with the model artifact unless
you have independently verified redistribution rights.

## Source References

See `docs/artifact_sources.md` for the list of upstream/source locations and the
current status of the separate Q6A ctx1024 artifact publication.
