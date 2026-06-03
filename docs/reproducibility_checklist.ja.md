# 再現性チェックリスト

issueを開く前、または自分の結果を公開する前に、このチェックリストを確認してください。

## 環境

- [ ] BoardはRadxa Dragon Q6Aの12GB RAM版
- [ ] SoCはQualcomm QCS6490 / QCM6490 family
- [ ] OSはUbuntu 24.04.4 LTS、または互換性を明記したLinux image
- [ ] fastrpc / cdsp / adsprpc のdevice plumbingが動作している
- [ ] Qualcomm QAIRT/QNN HTP libraryを、自分のlicensed環境から用意している
- [ ] QAIRT/QNN runtimeが、動作確認済みversion
      `2.42.0.251225135753_193295` と互換である

このプロジェクトは **非公式のLinux/Q6A NPU route** です。Radxa、Qualcomm、
Googleによる公式サポート構成ではありません。

## 必要なartifact

- [ ] `gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm`
- [ ] `litert_lm_main_q6a_gemma4_npu`
- [ ] `q6a-gemma4-npu`
- [ ] `libGemmaModelConstraintProvider.so`
- [ ] `libLiteRtDispatch_Qualcomm.so`
- [ ] QNN HTP libraries:
  - `libQnnSystem.so`
  - `libQnnHtp.so`
  - `libQnnHtpPrepare.so`
  - `libQnnHtpV68.so`
  - `libQnnHtpV68Stub.so`
  - `libQnnHtpV68Skel.so`

`.litertlm` fileとQualcomm libraryは、このGitHub repositoryには意図的に含めていません。
各必要物の入手先は `docs/artifact_sources.ja.md` を参照してください。

## runtime patch必須

- [ ] runtime binaryはLiteRT-LMに `patches/runtime.patch` を適用してbuildしている
- [ ] patch適用には `scripts/apply_runtime_patch.sh`、または同等の
      `git apply --check` + `git apply` commandを使っている
- [ ] LiteRT-LM source checkoutは確認済みcommit
      `497e7e28bd89c2b4e0d88e75035b045a21bc33fa` を使う。あるいはpatchを
      手動portし、marker checkまで通している
- [ ] stock `litert_lm_main` ではない
- [ ] `strings` でQ6A/Gemma4 Direct markerが見える

```bash
strings ~/q6a-gemma4-npu/runtime/litert_lm_main_q6a_gemma4_npu \
  | grep -E 'Q6A_GEMMA4_DIRECT|Q6A_FINAL_UNSAFE_TOKEN_POLICY'
```

期待される例:

```text
Q6A_GEMMA4_DIRECT_MODE_SELECTED
Q6A_GEMMA4_CONTRACT_OK
Q6A_FINAL_UNSAFE_TOKEN_POLICY=resample
```

## smoke test

- [ ] `scripts/check_q6a.sh` が通る
- [ ] `scripts/run_smoke.sh` で `1+1は？短く答えて` に対して `2` が返る
- [ ] stderr / logsにctx1024 Direct NPU route markerが出る
- [ ] CPU-only fallbackが隠れていない

## このrepoだけでは自動再現しないもの

以下はcleaned public repositoryの範囲外です。

- original safetensorsからctx1024 `.litertlm` への変換
- Qualcomm libraryの入手
- 元のBazel cache / source snapshotの完全再現
- full Gemma4 decode/verify QNN-context route
- GPU / WebGPU route
