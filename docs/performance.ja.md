# 性能メモ

ここにある数値はプロジェクト中の観測値であり、普遍的なbenchmarkではありません。
Q6Aの温度、CPU affinity、prompt長、生成token数、QAIRT/QNN library versionによって変わります。

## 採用routeのsmoke結果

cleanup後の採用route smoke:

| 項目 | 値 |
| --- | --- |
| Prompt | `1+1は？短く答えて` |
| Output | `2` |
| Route | ctx1024 Direct NPU |
| Status | 0 |
| Time to first token | 約2.14秒 |
| Prefill speed | 約9.13 tokens/s |
| Decode speed | 約6.08 tokens/s |

過去のctx1024 acceptanceでも、おおむね同じ傾向でした。

| Prompt | Output | TTFT | Decode |
| --- | --- | --- | --- |
| `1+1は？短く答えて` | `2` | 約2.45秒 | 約5.12 tokens/s |
| `日本の首都は？短く答えて` | `東京` | 約2.40秒 | 約5.25 tokens/s |

## Route比較

| Route | 役割 | 観測結果 |
| --- | --- | --- |
| ctx1024 Direct NPU | 採用した実用default | short smokeで約5.1-6.1 decode tokens/s |
| ctx4096 / prefill1024 Direct NPU | 長context比較route | decode約2.7-2.9 tokens/s、TTFT約4.6秒 |
| official CPU backend | baseline / fallback | promptによっては十分競争力あり。固定thread/affinityで各自測定推奨 |
| CPU speculative | 実験・比較baseline | 有用だがNPU package defaultには採用せず |
| QNN payload context | HTP invoke実証 | tiny / Gemma4-like payloadはinvoke成功。Gemma4生成routeにはならず |
| WebGPU / Vulkan GPU | 調査対象 | accelerator登録は成功。Gemma4 delegate partitioningが安定せず |

## ctx1024を採用した理由

ctx1024 Direct NPUは以下のバランスが最もよかったため採用しました。

- short / medium promptで速い
- invalid-token resampling後の安定性
- QNN-context実験よりpackageが単純
- LiteRT-LM `.litertlm` 実行に近い
- NPU route markerが明確

ctx4096は長contextが必要な場合には有用ですが、日常的なshort / medium promptでは
最速ではありませんでした。

## CPU比較について

CPUは弱いbaselineではありません。Q6A上の小型LLM推論では、NPU routeにも以下のCPU側処理が残ります。

- tokenizer / prompt処理
- input tensor準備
- mask / position / parameter helper
- KV cache bookkeeping / copy
- sampling
- dispatch overhead

そのため、promptによってはCPUがかなり競争力を持ちます。CPU測定方法は
`docs/cpu_comparison.ja.md` を参照してください。

## 推奨する解釈

- default実用NPU routeとしてctx1024 Direct NPUを使う
- 長contextが必要な時だけ長context routeを使う
- CPU speculativeは真面目なbaseline / fallbackとして扱う
- tiny QNN payloadの成功を、full Gemma4 decode/verify QNN-context完成と誤解しない
