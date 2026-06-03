# Patched runtimeのbuild

最も簡単な再現方法は、事前にbuild済みのpatched runtime binaryを使うことです。
sourceから再buildする場合は、互換性のあるLiteRT-LM source treeへ
`patches/runtime.patch` を適用してください。

## テスト済みbuild環境

- Radxa Dragon Q6A
- 12GB RAM
- Qualcomm QCS6490 / QCM6490 family
- Ubuntu 24.04.4 LTS
- QAIRT/QNN runtime `2.42.0.251225135753_193295`
- Bazel aarch64 optimized build

このruntime patchは、Q6A Gemma4 Direct NPU routeでは必須です。
patched binaryは、ctx1024 artifactを動かすためのGemma4 Direct execution pathを追加します。

## 対象source file

patchの主対象:

```text
runtime/executor/llm_litert_npu_compiled_model_executor.cc
```

元のbuildはQ6A上でBazelを使って実行しました。このpublic reproductionで
確認したsource snapshotは以下です。

```text
LiteRT-LM commit: 497e7e28bd89c2b4e0d88e75035b045a21bc33fa
Commit subject: Get quant param from decode signature.
```

2026-06-03時点のupstream LiteRT-LM `main` checkoutには、このpatchは直接当たりません。
上記commitを使うか、patchを手動portしてください。

## sourceからbuildする全体の流れ

公式LiteRT-LM source treeを各自で取得した後、このrepositoryのruntime patchを
そのcheckoutへ適用します。

例:

```text
~/src/LiteRT-LM/
~/src/radxa-dragon-q6a-qcs6490-gemma4-litertlm-npu/
```

upstream sourceとこのpatch repositoryをcloneします。

```bash
mkdir -p ~/src
cd ~/src
git clone https://github.com/google-ai-edge/LiteRT-LM.git
cd LiteRT-LM
git checkout 497e7e28bd89c2b4e0d88e75035b045a21bc33fa
cd ..
git clone https://github.com/PrismPhi/radxa-dragon-q6a-qcs6490-gemma4-litertlm-npu.git
```

Windows上でcloneする場合は、LiteRT-LM checkoutではCRLF自動変換を無効化するか、
Q6A/Linux上でbuildしてください。

```bash
git -c core.autocrlf=false clone https://github.com/google-ai-edge/LiteRT-LM.git
```

latest upstreamにpatchが当たらない場合は、上記snapshotを使うか、patchを手動portしてください。

## helper scriptでpatch適用

LiteRT-LM checkoutを変更せず、互換性だけ確認する場合:

```bash
~/src/radxa-dragon-q6a-qcs6490-gemma4-litertlm-npu/scripts/apply_runtime_patch.sh \
  --check-only ~/src/LiteRT-LM
```

patchを適用する場合:

```bash
~/src/radxa-dragon-q6a-qcs6490-gemma4-litertlm-npu/scripts/apply_runtime_patch.sh \
  ~/src/LiteRT-LM
```

このscriptは先に `git apply --check` を実行し、target fileがdirtyな場合はpatchしません。
`--check-only` を付けた場合、fileは変更しません。

## 手動でpatch適用

手動で適用する場合:

```bash
cd ~/src/LiteRT-LM
git apply --ignore-space-change --ignore-whitespace --check \
  ~/src/radxa-dragon-q6a-qcs6490-gemma4-litertlm-npu/patches/runtime.patch
git apply --ignore-space-change --ignore-whitespace \
  ~/src/radxa-dragon-q6a-qcs6490-gemma4-litertlm-npu/patches/runtime.patch
```

patchがcleanに適用できない場合は、target fileを手動で確認してください。
LiteRT-LM側が当時から変更されている可能性があります。その場合、stock runtimeのまま
Q6A Gemma4 Direct NPU routeが動くとは考えないでください。互換snapshotを使うか、patchをportしてください。

## build

```bash
bazel build -c opt --jobs=4 //runtime/engine:litert_lm_main
```

生成物を配置します。

```bash
mkdir -p ~/q6a-gemma4-npu/runtime
cp bazel-bin/runtime/engine/litert_lm_main \
  ~/q6a-gemma4-npu/runtime/litert_lm_main_q6a_gemma4_npu
```

次に、このrepositoryのwrapperをinstallします。

```bash
cd ~/src/radxa-dragon-q6a-qcs6490-gemma4-litertlm-npu
./scripts/install_q6a.sh
```

ctx1024 `.litertlm` artifactは以下に配置します。

```text
~/q6a-gemma4-npu/packages/gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm
```

自分のlicensed環境から用意したQNN/LiteRT runtime libraryを以下へ配置します。

```text
~/q6a-gemma4-npu/runtime/
```

補助scriptも使えます。

```bash
./scripts/collect_qnn_libs.sh /path/to/your/licensed/qnn/libs
```

## marker確認

```bash
strings ~/q6a-gemma4-npu/runtime/litert_lm_main_q6a_gemma4_npu \
  | grep -E 'Q6A_FINAL|Q6A_GEMMA4_DIRECT'
```

期待されるmarker例:

```text
Q6A_FINAL_UNSAFE_TOKEN_POLICY=resample
Q6A_FINAL_SAMPLE_RESAMPLED
Q6A_GEMMA4_DIRECT_MODE_SELECTED
Q6A_GEMMA4_CONTRACT_OK
```

`Q6A_FINAL_*` は、元のローカルruntime patchから残っているhistorical marker prefixです。

最後に確認します。

```bash
./scripts/check_q6a.sh
./scripts/run_smoke.sh
```
