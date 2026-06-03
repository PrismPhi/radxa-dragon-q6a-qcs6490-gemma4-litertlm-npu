# Reproduce On Radxa Dragon Q6A

This guide reproduces the adopted practical runtime layout. It assumes you have a
Radxa Dragon Q6A with a working Qualcomm HTP/QNN runtime.

## Requirements

- Radxa Dragon Q6A / QCS6490
- 12 GB RAM board variant tested
- Ubuntu 24.04.4 LTS tested
- Working `/dev/adsprpc-smd` / fastrpc / cdsp setup
- Qualcomm QNN/HTP runtime libraries from your own licensed environment
- Tested QAIRT/QNN runtime version:
  `2.42.0.251225135753_193295`
- Q6A ctx1024 `.litertlm` artifact:
  `gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm`
- Patched runtime binary:
  `litert_lm_main_q6a_gemma4_npu`

For exact upstream/source locations, see `docs/artifact_sources.md` before
collecting files.

The patched runtime is mandatory. See `docs/runtime_patch.md`. A stock
LiteRT-LM `litert_lm_main` is not expected to run this Q6A Gemma4 Direct NPU
artifact.

## Install

Copy the model and runtime files to Q6A, then run:

```bash
git clone https://github.com/PrismPhi/radxa-dragon-q6a-qcs6490-gemma4-litertlm-npu.git
cd radxa-dragon-q6a-qcs6490-gemma4-litertlm-npu
./scripts/install_q6a.sh
./scripts/check_q6a.sh
./scripts/run_smoke.sh
```

The install script does not download Qualcomm libraries. Place them under:

```text
~/q6a-gemma4-npu/runtime/
```

## Expected Smoke Output

The math smoke prompt is:

```text
1+1は？短く答えて
```

Expected output:

```text
2
```

Expected route marker in stderr/logs:

```text
Q6A_GEMMA4_NPU_ROUTE_SELECTED=ctx1024_direct_q6a_package
```

## Checksums From The Original Run

- Q6A ctx1024 `.litertlm`:
  `0d72585954b3855df20735b666926b5617c0e4a43528be6c00abe06fa0812347`
- Patched runtime:
  `aadac7a2ebc34cdf899d8eaf4eeab3fdd0e103e470540399b580b40afcac1c91`
- Public wrapper:
  `7be2f30731800d4045f11c6e76801e665cb55452892ff8fbe33493085e5eb15d`

Your runtime checksum may differ if you rebuild from source.
