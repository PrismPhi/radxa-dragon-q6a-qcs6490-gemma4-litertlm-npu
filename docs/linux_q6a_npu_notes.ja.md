# 非公式Linux Q6A NPUメモ

このプロジェクトの特徴は、**Radxa Dragon Q6A / QCS6490 のUbuntu Linux上で**
LiteRT-LM Gemma4 NPU routeを動かしている点です。

これは、一般的なAndroid中心のQualcomm NPU flowとは異なります。

## 動作したこと

- Radxa Dragon Q6A上のUbuntu 24.04.4 LTS
- QCS6490/QCM6490 familyのHTP runtime path
- QAIRT/QNN runtime `2.42.0.251225135753_193295`
- Qualcomm dispatch / QNN HTP library load
- LiteRT-LM NPU backend経由のGemma4 Direct prefill/decode route
- ctx1024 practical packageとwrapper

## 非公式である理由

- このプロジェクトの実用Gemma4 routeでは、QCS6490を公式サポートtargetとは扱っていません
- runtimeにlocal patchが必要です
- Qualcomm libraryは利用者自身の環境から用意します
- `.litertlm` artifactはこのGitHub repositoryでは再配布しません
- Radxa、Qualcomm、Googleのvendor supportを主張しません

## なぜ重要か

Q6A利用者にとって、この成果は単なるbenchmark値ではありません。Linux SBC的な環境から
LiteRT-LM NPU backendへ到達し、`.litertlm` routeでGemma4 tokenを生成できたこと自体が
実用的な出発点になります。

まだ実験的ですが、他のQCS6490 Linux deploymentにとっても参考になるはずです。
