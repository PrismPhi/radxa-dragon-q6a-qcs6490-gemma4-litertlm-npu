# NPU経路の説明

このプロジェクトは **Radxa Dragon Q6A（非公式）/ Qualcomm QCS6490** 上で
Gemma 4 E2B を LiteRT-LM 形式で動かすことを目的にしています。

採用した実用経路は **ctx1024 Direct NPU** です。

## 要約

このrepoの主成果物は、独自ONNX runnerや外部QNN専用runnerではありません。
Gemma4をLiteRT-LMの `.litertlm` として扱い、patched LiteRT-LM runtimeと
wrapperから実行します。

役割分担はおおむね以下です。

| 処理 | 実行場所 | メモ |
| --- | --- | --- |
| tokenizer / prompt処理 | CPU | LiteRT-LM側の通常処理です。 |
| embedding / LLM graph呼び出し | NPU経路 | LiteRT / LiteRT-LM Qualcomm NPU backendからQNN HTP dispatchへ到達します。 |
| Gemma4 `prefill_*` / `decode` main graph | NPU経路 | 採用版はGemma4 Direct signatureを使います。 |
| position / mask / param helper | CPU | runtime側で生成・bindします。 |
| KV cache bookkeeping / copy | CPU補助 | 速度上の重要なoverheadです。 |
| sampling / invalid-token guard | CPU | 固定token置換ではなく、valid候補から再sampleします。 |
| text streaming / log | CPU | stdoutには生成text、backend logは別扱いです。 |

## なぜDirect NPUなのか

既存のGemma3向けNPU経路は、`TF_LITE_AUX` という補助TFLite modelを前提にしていました。
そこではmask生成、RoPE生成、cache updateなどのsignatureが使われます。
このrepoではこの古い経路を **Gemma3 AUX** 型と呼びます。

一方、Gemma4 E2Bのcontractは異なります。主なsignatureは以下です。

- `prefill_128`
- `prefill_1024`
- `decode`
- `verify`

Gemma4 E2Bは、Gemma3 AUX型の `decode_mask`、`decode_rope`、
`decode_cache_update` に合わせるmodelではありません。`embeddings`、
`input_pos`、`mask`、`param_tensor`、`per_layer_embeddings`、KV cache tensorを
main graphへ直接渡す構造です。

そのため、Gemma4をGemma3 AUX型に無理に合わせるのではなく、Gemma4 Direct routeを
追加する方針にしました。

## 実際にNPUを使っている部分

採用版では、Gemma4のprefill/decode graphをLiteRT-LM NPU backend経由で呼びます。
Q6AではQualcomm QNN HTP dispatchまで到達します。

patched runtimeでは、以下のようなmarkerが出る想定です。

```text
Q6A_GEMMA4_DIRECT_MODE_SELECTED
Q6A_GEMMA4_CONTRACT_OK
Q6A_GEMMA4_PREFILL128_START
Q6A_GEMMA4_PREFILL128_DONE
Q6A_GEMMA4_DECODE_START
Q6A_GEMMA4_DECODE_DONE
Q6A_GEMMA4_LOGITS_READ_OK
```

このrepoにはQualcomm libraryを含めていないため、実際のlogは各自のQAIRT/QNN環境に依存します。

## なぜctx1024なのか

このプロジェクトでは複数のcontext長とrouteを試しました。

ctx1024を採用した理由は以下です。

- short / medium promptでctx4096より明確に速かった
- invalid-token guard追加後、実用上の安定性が上がった
- QNN context payload実験より構成が単純だった
- 外部runnerではなくLiteRT-LM `.litertlm` 実行に近い形を保てた

ただし、ctx1024は万能ではありません。長いpromptには長context routeが必要です。

## 試したが採用しなかったもの

| Route | 結果 |
| --- | --- |
| full Gemma4 decode/verify QNN context | 調査・実験したが、より速い実用生成routeとしては採用せず。 |
| `.litertlm` 内QNN payload context | tiny / Gemma4-like graphでHTP invokeは実証。Gemma4生成速度routeにはならず。 |
| CPU+NPU speculative / MTP hybrid | verify probeは到達。実用defaultには採用せず。 |
| WebGPU / Vulkan GPU backend | WebGPU accelerator登録とTurnip Adreno 643検出までは到達。Gemma4 graph partitioningが安定せず不採用。 |
| ctx4096 Direct NPU | 長context比較には有用。ただしshort / medium promptではctx1024より遅い。 |

## このrepoが主張しないこと

このrepoは以下を主張しません。

- full Gemma4 decode/verify QNN-context generationが完成している
- QCS6490がLiteRT Qualcomm NPUの公式サポート対象である
- NPU routeが全promptでCPUより速い
- Qualcomm binaryやGemma model weightをこのrepoで再配布できる

主張はもっと狭いです。

> テストしたQ6A環境では、ctx1024 Gemma4 Direct NPU routeが、このプロジェクトで見つかった
> 最も実用的なNPU routeでした。このrepoは、そのruntime patch、wrapper、再現手順を保存します。
