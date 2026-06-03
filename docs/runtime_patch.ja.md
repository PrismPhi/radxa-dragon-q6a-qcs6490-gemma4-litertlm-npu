# Runtime patchについて

このプロジェクトでは **patched LiteRT-LM runtime** が必須です。

ctx1024 `.litertlm` artifact と Q6A NPU route は、stock LiteRT-LM binaryで
そのまま動く前提ではありません。同等のGemma4 Direct supportを新しいupstreamへ
portした場合は、別途検証してください。

## テスト済み環境

元の動作確認環境は以下です。

| 項目 | 値 |
| --- | --- |
| Board | Radxa Dragon Q6A |
| RAM | 12GB |
| SoC | Qualcomm QCS6490 / QCM6490 family |
| OS | Ubuntu 24.04.4 LTS |
| Runtime path | LiteRT-LM Qualcomm NPU backend / QNN HTP dispatch |
| 必要なdevice plumbing | fastrpc / cdsp / adsprpc が動作すること |

他のQCS6490/QCM6490系Linux imageでも動く可能性はありますが、smoke testとNPU
markerが通るまでは未検証扱いにしてください。

## なぜstock LiteRT-LMでは足りないのか

このmodel artifactはGemma4 Direct contractを使います。既存のLiteRT-LM NPU executorは、
Gemma3 AUX型modelを強く前提にした経路でした。そこではmask生成、RoPE生成、
cache update helperなどのsignatureが必要になります。

Gemma4 E2Bは構造が異なります。

- Gemma3型 `TF_LITE_AUX` を要求しない
- `prefill_128` / `prefill_1024` / `decode` を直接呼ぶ
- KV cacheをdirect input/outputとしてbindする
- `input_pos`、`mask`、`param_tensor` をCPU側で作る
- samplingや安全処理もCPU側で行う

runtime patchなしでは、AUX section missing、signature mismatch、route selection未対応、
state handling不整合などで失敗する可能性が高いです。

## patchで追加していること

`patches/runtime.patch` には、Q6A/Gemma4向けの実用runtime変更が入っています。

- Gemma4 Direct route selection
- Gemma4 signatureのcontract check
- `prefill_128` / `prefill_1024` / `decode` の直接呼び出し
- Direct contract向けKV cache binding / state handling
- ctx1024 safety budget処理
- invalid sampled tokenの再sample
- Q6A/Gemma4/NPU debug marker

完全なLiteRT-LM source treeをvendorするのではなくpatchとして置いているのは、
巨大なsource snapshotやthird-party build productをGitHubへ含めないためです。

## 必要なbinary

想定するruntime binary名:

```text
litert_lm_main_q6a_gemma4_npu
```

配置先:

```text
~/q6a-gemma4-npu/runtime/
```

wrapperはこのpatched binaryを呼びます。stock `litert_lm_main` に差し替えた場合、
Q6A Gemma4 NPU routeは未検証と考えてください。新しいupstream LiteRT-LM releaseで
NPU supportが追加・変更されている場合でも、Gemma4 Direct contractとmarkerを確認してから
互換扱いにしてください。

## marker確認

生成testの前に、binaryにQ6A/Gemma4 markerが入っているか確認してください。

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

`Q6A_FINAL_*` はローカル実験時から残っているhistorical marker prefixです。
このrepoがupstream LiteRT-LMのfinal implementationを公開している、という意味ではありません。
