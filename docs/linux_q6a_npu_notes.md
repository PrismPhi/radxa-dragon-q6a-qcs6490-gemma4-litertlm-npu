# Unofficial Linux Q6A NPU Notes

This project is notable because it runs a LiteRT-LM Gemma4 NPU path on
**Ubuntu Linux on Radxa Dragon Q6A / QCS6490**.

That is different from the common Android-focused Qualcomm NPU flow.

## What Worked

- Ubuntu 24.04.4 LTS on Radxa Dragon Q6A.
- QCS6490/QCM6490-family HTP runtime path.
- QAIRT/QNN runtime `2.42.0.251225135753_193295`.
- Qualcomm dispatch / QNN HTP library loading.
- Gemma4 Direct prefill/decode route through the LiteRT-LM NPU backend.
- ctx1024 practical package and wrapper.

## What Makes It Unofficial

- QCS6490 was not treated as an officially supported target for the original
  practical Gemma4 route in this project.
- The runtime requires local patches.
- Qualcomm libraries are supplied from the user's own environment.
- The `.litertlm` artifact is not redistributed in this GitHub repository.
- The project does not claim vendor support from Radxa, Qualcomm, or Google.

## Why This Matters

For Q6A users, the useful result is not only the benchmark number. It is that a
Linux SBC-style workflow can reach the LiteRT-LM NPU backend and produce Gemma4
tokens through a `.litertlm`-based route.

This is still experimental, but it is a practical starting point for other
QCS6490 Linux deployments.
