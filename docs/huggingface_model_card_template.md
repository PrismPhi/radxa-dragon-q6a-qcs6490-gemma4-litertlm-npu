# Gemma4 E2B Q6A QCS6490 ctx1024 NPU LiteRT-LM

This is a Q6A/QCS6490-oriented LiteRT-LM `.litertlm` artifact derived from
Gemma 4 E2B.

## Artifact

- File: `gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm`
- SHA256: `0d72585954b3855df20735b666926b5617c0e4a43528be6c00abe06fa0812347`
- Target hardware: Radxa Dragon Q6A / Qualcomm QCS6490
- Runtime route: ctx1024 Direct NPU

## License

Gemma 4 E2B and the LiteRT-LM artifact family are Apache-2.0 licensed as
published by Google / LiteRT community. Include the Apache-2.0 license and any
required NOTICE content in this model repository.

## Modifications

This artifact is intended for the Q6A practical runtime:

- ctx1024 practical route
- Q6A/QCS6490 NPU execution through LiteRT-LM Direct path
- compatible with the patched runtime described in the GitHub repository

## Runtime Requirements

This model repository does not include Qualcomm QAIRT/QNN runtime libraries.
Users must provide them from their own properly licensed Q6A/QAIRT environment.

## Smoke Test

```bash
printf '%s' 'MSsx44Gv77yf55+t44GP562U44GI44Gm' | base64 -d > /tmp/q6a_prompt.txt
/home/radxa/bin/q6a-gemma4-npu run \
  ~/q6a-gemma4-npu/packages/gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm \
  --backend npu \
  --temperature 0 \
  --prompt-file /tmp/q6a_prompt.txt
```

Expected output:

```text
2
```
