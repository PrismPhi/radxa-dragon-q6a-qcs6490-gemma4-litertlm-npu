# Radxa Dragon Q6Aでの再現手順

この手順は、採用した実用runtime layoutを再現するためのものです。
Qualcomm HTP / QNN runtimeが動作するRadxa Dragon Q6Aを前提にしています。

## 必要なもの

- Radxa Dragon Q6A / QCS6490
- 12GB RAM版で動作確認
- Ubuntu 24.04.4 LTSで動作確認
- `/dev/adsprpc-smd` / fastrpc / cdsp が動作していること
- 自分のlicense環境から入手したQualcomm QNN/HTP runtime libraries
- 動作確認したQAIRT/QNN runtime version:
  `2.42.0.251225135753_193295`
- Q6A ctx1024 `.litertlm` artifact:
  `gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm`
- patched runtime binary:
  `litert_lm_main_q6a_gemma4_npu`

各fileのupstream/source locationは、準備前に `docs/artifact_sources.ja.md` を
確認してください。

patched runtimeは必須です。`docs/runtime_patch.ja.md` を参照してください。
stock LiteRT-LM `litert_lm_main` で、このQ6A Gemma4 Direct NPU artifactが
そのまま動く前提ではありません。

## Install

modelとruntime fileをQ6Aへコピーした上で実行します。

```bash
git clone https://github.com/PrismPhi/radxa-dragon-q6a-qcs6490-gemma4-litertlm-npu.git
cd radxa-dragon-q6a-qcs6490-gemma4-litertlm-npu
./scripts/install_q6a.sh
./scripts/check_q6a.sh
./scripts/run_smoke.sh
```

install scriptはQualcomm libraryをdownloadしません。必要なlibraryは以下へ配置してください。

```text
~/q6a-gemma4-npu/runtime/
```

## 期待されるsmoke output

math smoke prompt:

```text
1+1は？短く答えて
```

期待される出力:

```text
2
```

stderr / logに期待されるroute marker:

```text
Q6A_GEMMA4_NPU_ROUTE_SELECTED=ctx1024_direct_q6a_package
```

## Original runのchecksum

- Q6A ctx1024 `.litertlm`:
  `0d72585954b3855df20735b666926b5617c0e4a43528be6c00abe06fa0812347`
- Patched runtime:
  `aadac7a2ebc34cdf899d8eaf4eeab3fdd0e103e470540399b580b40afcac1c91`
- Public wrapper:
  `7be2f30731800d4045f11c6e76801e665cb55452892ff8fbe33493085e5eb15d`

sourceからrebuildした場合、runtime checksumは変わる可能性があります。
