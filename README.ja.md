# Radxa Dragon Q6A（非公式）/ QCS6490 Gemma4 LiteRT-LM NPU

[English README](README.md)

Radxa Dragon Q6A / Qualcomm QCS6490 上で Gemma 4 E2B を LiteRT-LM 形式で
動かすための、非公式の実用runtime patch・wrapper・再現メモです。

これは **非公式のcommunity project** です。Radxa、Qualcomm、Google、Gemma、
LiteRT、LiteRT-LMの公式releaseではなく、vendor support対象でもありません。

このプロジェクトで最終的に採用した実用経路は **ctx1024 Direct NPU** です。
Gemma4 decode / verify 全体の QNN context 化も調査・実験しましたが、最速の
実用経路としては採用していません。

## テスト済み環境

- Board: Radxa Dragon Q6A
- RAM: 12GB
- SoC: Qualcomm QCS6490 / QCM6490 family
- OS: Ubuntu 24.04.4 LTS
- Runtime: patched LiteRT-LM with Qualcomm NPU backend / QNN HTP dispatch
- Tested QAIRT/QNN runtime: `2.42.0.251225135753_193295`

このrouteには `docs/runtime_patch.ja.md` で説明しているpatched runtimeが必須です。
ctx1024 `.litertlm` artifactは、元の検証時source snapshotのstock LiteRT-LM binaryで
そのまま動く前提ではありません。同等のGemma4 Direct supportを新しいupstreamへportした場合は別途検証が必要です。

また、これはQ6A/QCS6490向けの **非公式Ubuntu Linux NPU route** です。
範囲と注意点は `docs/linux_q6a_npu_notes.ja.md` を参照してください。

このプロジェクトと文書の作成には、OpenAI Codexをかなり使用しています。
詳細は `docs/project_provenance.ja.md` を参照してください。

## このリポジトリに含まれるもの

- LiteRT-LM runtime patch: `patches/runtime.patch`
- Q6A用runner script: `scripts/q6a-gemma4-npu`
- Q6A install / check script
- 再現手順とbenchmark概要
- licenseとthird-party notice

## 再現性について

このrepositoryだけで、cleaned runtime layoutとQ6A smoke flowを再現するための
手順は追えます。ただし、model artifact、patched runtime binaryまたは互換build環境、
Qualcomm QAIRT/QNN libraryは別途用意する必要があります。

`.litertlm` model artifactとQualcomm runtime libraryは、このGitHub repositoryでは
意図的に再配布していません。`docs/reproducibility_checklist.ja.md` と
`docs/artifact_sources.ja.md` を参照してください。

採用したQ6A ctx1024 `.litertlm` artifactはHugging Faceで別途公開しています。
<https://huggingface.co/PrismPhi/gemma4-e2b-q6a-qcs6490-litertlm-npu>

## このリポジトリに含まれないもの

- Gemma model weights
- `.litertlm` model container
- Qualcomm QAIRT/QNN runtime libraries
- QNN context binaries
- 大容量log、build cache、実験用一時file

これは意図的です。model artifactとQualcomm runtime libraryには、それぞれ別の
license・配布条件があります。

## 想定するQ6A上の配置

```text
~/q6a-gemma4-npu/
  packages/
    gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm
  runtime/
    litert_lm_main_q6a_gemma4_npu
    q6a-gemma4-npu
    libGemmaModelConstraintProvider.so
    libLiteRtDispatch_Qualcomm.so
    libQnnHtp.so
    libQnnHtpPrepare.so
    libQnnHtpV68.so
    libQnnHtpV68Skel.so
    libQnnHtpV68Stub.so
    libQnnSystem.so
```

wrapperは以下に入ります。

```text
/home/radxa/bin/q6a-gemma4-npu
```

## Quick Start

1. model artifactを配置します。

```bash
mkdir -p ~/q6a-gemma4-npu/packages
hf download PrismPhi/gemma4-e2b-q6a-qcs6490-litertlm-npu \
  gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm \
  --local-dir ~/q6a-gemma4-npu/packages
```

2. runtime binaryとQNN libraryを配置します。

```bash
mkdir -p ~/q6a-gemma4-npu/runtime
cp litert_lm_main_q6a_gemma4_npu ~/q6a-gemma4-npu/runtime/
cp libGemmaModelConstraintProvider.so ~/q6a-gemma4-npu/runtime/
cp libLiteRtDispatch_Qualcomm.so ~/q6a-gemma4-npu/runtime/
cp libQnn*.so ~/q6a-gemma4-npu/runtime/
```

patched runtimeを自分でbuildする場合は `docs/build_runtime.ja.md` を参照してください。
要約すると、公式LiteRT-LMをcloneし、
`scripts/apply_runtime_patch.sh /path/to/LiteRT-LM` を実行してから
`//runtime/engine:litert_lm_main` をbuildし、生成binaryを
`litert_lm_main_q6a_gemma4_npu` として配置します。

3. wrapperをinstallします。

```bash
./scripts/install_q6a.sh
```

4. smoke testを実行します。

```bash
./scripts/run_smoke.sh
```

直接実行する場合:

```bash
printf '%s' 'MSsx44Gv77yf55+t44GP562U44GI44Gm' | base64 -d > /tmp/q6a_prompt.txt
/home/radxa/bin/q6a-gemma4-npu run \
  ~/q6a-gemma4-npu/packages/gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm \
  --backend npu \
  --temperature 0 \
  --prompt-file /tmp/q6a_prompt.txt
```

base64 promptの内容:

```text
1+1は？短く答えて
```

期待される出力:

```text
2
```

## Runtimeの挙動

- default route: ctx1024 Direct NPU
- wrapperは `--backend npu` を受け付けます
- `--max-num-tokens` は「生成したい出力token数」として扱い、ctx1024の安全範囲へclampします
- 無効なsampled token IDは、固定ID置換ではなくlogits上位のvalid候補から再選択します
- 生成textはstdoutへstreamし、backend logは別に保存します

## 既知の制限

- 最速の実用経路はctx1024 Direct NPUであり、full Gemma4 QNN-context decodeではありません。
- この検証済みartifact/runtime combinationではpatched LiteRT-LM runtimeが必須です。
  新しいupstream LiteRT-LM NPU supportで動くかは別途compatibility verificationが必要です。
- 長いpromptには、別途長context routeが必要です。
- Qualcomm QAIRT/QNN libraryはこのrepoでは再配布しません。
- patched runtimeを再buildするには、`patches/runtime.patch` と互換性のあるLiteRT-LM checkoutが必要です。
- このpatchで確認したLiteRT-LM source commit:
  `497e7e28bd89c2b4e0d88e75035b045a21bc33fa`

## 日本語ドキュメント

- `docs/reproduce.ja.md`
- `docs/reproducibility_checklist.ja.md`
- `docs/artifact_sources.ja.md`
- `docs/build_runtime.ja.md`
- `docs/runtime_patch.ja.md`
- `docs/linux_q6a_npu_notes.ja.md`
- `docs/npu_route.ja.md`
- `docs/performance.ja.md`
- `docs/cpu_comparison.ja.md`
- `docs/model_artifact.ja.md`
- `docs/distribution_policy.ja.md`
- `docs/project_provenance.ja.md`
- `CONTACT.ja.md`

## English Docs

- `docs/reproduce.md`
- `docs/build_runtime.md`
- `docs/runtime_patch.md`
- `docs/model_artifact.md`
- `docs/npu_route.md`
- `docs/performance.md`
- `docs/cpu_comparison.md`
- `docs/distribution_policy.md`
- `LICENSE_AUDIT.md`
