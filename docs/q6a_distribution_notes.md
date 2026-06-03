# Q6A Distribution Notes

This is the cleaned public version of the local distribution notes.

## Adopted Practical Route

- Hardware: Radxa Dragon Q6A / Qualcomm QCS6490
- RAM: 12 GB tested
- OS: Ubuntu 24.04.4 LTS tested
- Model family: Gemma 4 E2B LiteRT-LM
- Adopted route: ctx1024 Direct NPU
- Wrapper: `q6a-gemma4-npu`
- Runtime binary name: `litert_lm_main_q6a_gemma4_npu`
- Model artifact name: `gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm`

The runtime binary is a patched LiteRT-LM binary. A stock LiteRT-LM binary is
not sufficient for this Q6A Gemma4 Direct NPU package.

## Required Runtime Files

The runtime directory on Q6A must contain:

- `litert_lm_main_q6a_gemma4_npu`
- `libGemmaModelConstraintProvider.so`
- `libLiteRtDispatch_Qualcomm.so`
- `libQnnHtp.so`
- `libQnnHtpPrepare.so`
- `libQnnHtpV68.so`
- `libQnnHtpV68Skel.so`
- `libQnnHtpV68Stub.so`
- `libQnnSystem.so`

The Qualcomm libraries are not included in this repository.

## Smoke Test

Use a UTF-8 prompt file:

```bash
printf '%s' 'MSsx44Gv77yf55+t44GP562U44GI44Gm' | base64 -d > /tmp/q6a_prompt.txt
/home/radxa/bin/q6a-gemma4-npu run \
  ~/q6a-gemma4-npu/packages/gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm \
  --backend npu \
  --temperature 0 \
  --prompt-file /tmp/q6a_prompt.txt
```

The prompt is:

```text
1+1は？短く答えて
```

Expected output:

```text
2
```

## Important Notes

- The public runner defaults to ctx1024 Direct NPU.
- Invalid sampled token IDs are resampled from valid logits candidates.
- The old fixed replacement token policy was removed.
- `--max-num-tokens` is treated as requested output tokens and clamped to the
  ctx1024 safety budget.
- Backend logs are saved under the Q6A runtime root.
