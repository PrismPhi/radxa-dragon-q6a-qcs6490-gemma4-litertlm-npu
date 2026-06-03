# Artifact入手先

このrepositoryには、model artifact、Qualcomm runtime library、upstream LiteRT-LM
source treeを同梱しません。利用者が各自で用意する必要があります。

## 何をどこから取るか

| Item | 入手先 | 検証済みversion / revision | 用途 | このrepoに含むか |
| --- | --- | --- | --- | --- |
| LiteRT-LM source tree | <https://github.com/google-ai-edge/LiteRT-LM> | `497e7e28bd89c2b4e0d88e75035b045a21bc33fa` | `patches/runtime.patch` を適用し、`litert_lm_main` をbuildする | いいえ |
| Gemma 4 E2B base model | <https://huggingface.co/google/gemma-4-e2b-it> | model family / license参照用。下のQ6A artifactを使うだけなら直接downloadは不要 | upstream model lineage / license参照 | いいえ |
| official LiteRT-LM Gemma4 artifact family | <https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm> | 参照用。採用版ctx1024 artifactそのものではない | Gemma4 `.litertlm` package familyの参照 | いいえ |
| Q6A ctx1024 NPU `.litertlm` | <https://huggingface.co/PrismPhi/gemma4-e2b-q6a-qcs6490-litertlm-npu> | SHA256 `0d72585954b3855df20735b666926b5617c0e4a43528be6c00abe06fa0812347` | このQ6A routeの採用model package | GitHubには含めない |
| patched runtime binary | このrepoのpatchを当ててLiteRT-LMからbuildする。または公開releaseがあればそこから取得 | 上記LiteRT-LM commit + `patches/runtime.patch` でbuild。元local SHAは `aadac7a2ebc34cdf899d8eaf4eeab3fdd0e103e470540399b580b40afcac1c91` | Q6A Gemma4 Direct NPU routeに必須 | binaryはgitに含めない |
| `libGemmaModelConstraintProvider.so` | 互換LiteRT-LM prebuilt/build output。通常はupstream source/LFS setup後の `prebuilt/linux_arm64` など | patched runtime buildと互換のもの | runtime companion library | いいえ |
| `libLiteRtDispatch_Qualcomm.so` | 互換LiteRT/LiteRT-LM Qualcomm NPU dispatch build/output | patched runtimeおよびQNN runtimeと互換のもの | Qualcomm NPU dispatch | いいえ |
| QNN HTP libraries (`libQnn*.so`) | Q6A image、Radxa QAIRT setup、Qualcomm AI Runtime SDK、または適切にlicensedされたsource | 検証済みQAIRT/QNN `2.42.0.251225135753_193295` | QNN/HTP backend runtime | いいえ |

動作確認したQ6A runtimeはQAIRT/QNN `2.42.0.251225135753_193295` です。
他versionでも動く可能性はありますが、`scripts/check_q6a.sh` とsmoke testが通るまでは
未検証として扱ってください。

QNN libraryは同じrelease由来の一式として扱ってください。
`libQnnHtp.so`、`libQnnSystem.so`、skel/stub library、LiteRT Qualcomm dispatch libraryを
無関係なreleaseから混在させるのは、version互換性を意図的にdebugする場合以外は避けてください。

model artifactについては、公開再現では以下が一番単純です。

```bash
hf download PrismPhi/gemma4-e2b-q6a-qcs6490-litertlm-npu \
  gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm \
  --local-dir ~/q6a-gemma4-npu/packages
sha256sum ~/q6a-gemma4-npu/packages/gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm
```

期待されるSHA256:

```text
0d72585954b3855df20735b666926b5617c0e4a43528be6c00abe06fa0812347
```

## upstream links

- LiteRT-LM source:
  <https://github.com/google-ai-edge/LiteRT-LM>
- Gemma 4 E2B base model:
  <https://huggingface.co/google/gemma-4-e2b-it>
- LiteRT-LM Gemma4 reference artifact family:
  <https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm>
- Radxa Dragon Q6A product/docs entry point:
  <https://radxa.com/products/dragon/q6a/>
- Radxa Dragon Q6A QAIRT usage notes:
  <https://docs.radxa.com/en/dragon/q6a/app-dev/npu-dev/qairt-usage>
- Qualcomm AI software portal:
  <https://www.qualcomm.com/developer/artificial-intelligence/software>
- Qualcomm AI Engine Direct SDK entry point:
  <https://www.qualcomm.com/developer/software/qualcomm-ai-engine-direct-sdk>

Qualcommのlinkは入口であり、再配布許可ではありません。自分のaccount、board image、
vendor packageで利用が許可されているSDK / runtime fileだけを使ってください。

## 重要な状態

local projectで採用したmodel fileは以下です。

```text
gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm
SHA256: 0d72585954b3855df20735b666926b5617c0e4a43528be6c00abe06fa0812347
```

このctx1024 Q6A artifactはHugging Faceで別途公開しています。

<https://huggingface.co/PrismPhi/gemma4-e2b-q6a-qcs6490-litertlm-npu>

GitHub repositoryには意図的に保存していません。採用版Q6A ctx1024 NPU generation routeを
再現するには、GitHub側のruntime / script repositoryと、Hugging Face側のmodel artifact
repositoryの両方が必要です。

## 推奨download flow

1. このrepositoryをcloneする
2. 公式LiteRT-LMをcloneする
3. `scripts/apply_runtime_patch.sh` でruntime patchを適用する
4. patched runtime binaryをbuildする
5. Hugging Faceのmodel artifact repositoryからQ6A ctx1024 `.litertlm` を取得する
6. 自分のlicensed Q6A/QAIRT環境からQualcomm runtime librariesを用意する
7. `scripts/check_q6a.sh` を実行する
8. `scripts/run_smoke.sh` を実行する

## Qualcomm libraryについて

Qualcomm runtime libraryをこのGitHub repositoryへuploadしないでください。
`scripts/collect_qnn_libs.sh` は、利用者がlocalで指定したpathからcopyするだけです。

RadxaはDragon Q6A向けQAIRT setup documentを公開しており、QualcommもQAIRT/QNNの
documentation / SDK materialを公開しています。利用権限のあるsourceだけを使ってください。
