# Project Closeout Summary

The project ended with a practical runtime/package route rather than a full
Gemma4 QNN-context decode implementation.

## Adopted

- ctx1024 Direct NPU route
- patched LiteRT-LM runtime
- public wrapper with stock-like stdout behavior
- valid-vocabulary resampling for invalid sampled token IDs
- Q6A/QCS6490 runtime layout suitable for local installation

## Not Adopted

- Full Gemma4 decode/verify QNN context route
- GPU/WebGPU route
- CPU+NPU speculative hybrid as the default route
- QNN tiny payload route as a generation-speed route

## Why

The ctx1024 Direct NPU route gave the best practical balance of speed,
stability, and simplicity on Q6A. QNN context payload experiments were valuable
for proving HTP invocation through payloads, but they did not become the fastest
Gemma4 generation route.

## Smoke

- Prompt: `1+1は？短く答えて`
- Output: `2`
- Status: 0
- Decode speed observed after cleanup: about 6 tokens/s
