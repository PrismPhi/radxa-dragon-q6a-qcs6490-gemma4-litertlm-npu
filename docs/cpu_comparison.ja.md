# CPU比較ガイド

このプロジェクトではCPU baselineが重要です。目的は「NPUが常に勝つ」と主張することではなく、
Q6A上で最も実用的なrouteを見つけることです。

## 推奨CPU baseline

official LiteRT-LM CPU backendを、固定thread数とCPU affinityで測ります。

例:

```bash
printf '%s' '44GC44Gq44Gf44Gv5L2V44GM44Gn44GN44G+44GZ44GL77yf' | base64 -d > /tmp/q6a_cpu_prompt.txt

export LITERT_LM_CPU_BIN=/path/to/litert-lm
export OFFICIAL_GEMMA4_LITERTLM=/path/to/gemma-4-E2B-it.litertlm
export XNNPACK_NUM_THREADS=4

taskset -c 4-7 "$LITERT_LM_CPU_BIN" run \
  "$OFFICIAL_GEMMA4_LITERTLM" \
  --backend cpu \
  --max-num-tokens 2048 \
  --temperature 0 \
  --prompt "$(cat /tmp/q6a_cpu_prompt.txt)"
```

base64 promptの内容:

```text
あなたは何ができますか？
```

SSH automationやWindows経由で実行する場合、日本語promptは直接引数に書くより
UTF-8 prompt file経由にする方が安全です。

## 測るべきもの

比較時は以下を揃えてください。

- 同じprompt
- 同じtemperature
- 同じ生成token budget
- 同じCPU affinity
- できるだけ同じ温度状態
- cold / warm条件

記録するもの:

- exit status
- 生成text
- elapsed time
- 可能ならtime to first token
- 可能ならdecode tokens/s
- 温度やthrottlingの兆候
- NPU / QNN markerが出ていないこと

CPU測定ではQNN/HTP markerが出ないはずです。出ている場合、純粋なCPU baselineではありません。

## 実用上の解釈

このプロジェクトの観測では:

- 採用した実用NPU routeはctx1024 Direct NPU
- ctx4096 Direct NPUは長context比較には有用だが遅い
- CPU speculativeはbaseline / fallbackとして重要
- promptによってはCPUも競争力がある

NPU routeにもCPU側overheadが残るため、すべてのpromptでNPUが自動的に勝つわけではありません。

## 公開benchmarkで推奨するprompt

| Case | Prompt |
| --- | --- |
| Math smoke | `1+1は？短く答えて` |
| Capital smoke | `日本の首都は？短く答えて` |
| Ability short | `あなたは何ができますか？短く答えてください。` |
| Free generation | 64 token程度の自由生成prompt |
| Long prompt | 実用想定に近い長めのprompt |

公開する数値は、過度に精密な主張よりも「条件とlog付きの概算」の方が有用です。
