# CPU Comparison Guide

CPU is an important baseline for this project. The goal is not to claim that
NPU always wins; the goal is to find the fastest practical route on Q6A.

## Recommended CPU Baseline

Use the official LiteRT-LM CPU backend with a fixed thread count and CPU affinity
so results are repeatable.

Example:

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

The base64 prompt is:

```text
あなたは何ができますか？
```

If you are running commands through SSH automation, prefer a UTF-8 prompt file.
That avoids Windows/SSH/PTY quoting issues with Japanese text.

## What To Measure

For a fair comparison, keep these constant:

- same prompt,
- same temperature,
- same output-token budget,
- same CPU affinity,
- same thermal condition,
- same warm/cold policy.

Record:

- exit status,
- generated text,
- wall-clock elapsed time,
- time to first token if available,
- decode tokens/s if available,
- temperature or throttling symptoms,
- whether NPU/QNN markers appeared.

CPU runs should not show QNN/HTP markers. If they do, you are not measuring a
clean CPU baseline.

## Practical Interpretation

The observed project result was:

- ctx1024 Direct NPU was the adopted practical NPU route,
- ctx4096 Direct NPU was slower but useful for long-context comparison,
- CPU speculative remained a valuable fallback/baseline,
- CPU can be competitive for some prompts because it avoids NPU dispatch and
  KV-copy overhead.

That last point matters. A small model on a heterogeneous edge board can have
enough CPU-side overhead that the NPU route is not automatically faster for
every case.

## Recommended Public Benchmark Set

Use these prompts when comparing routes:

| Case | Prompt |
| --- | --- |
| Math smoke | `1+1は？短く答えて` |
| Capital smoke | `日本の首都は？短く答えて` |
| Ability short | `あなたは何ができますか？短く答えてください。` |
| Free generation | Any 64-token-ish open-ended prompt |
| Long prompt | A prompt close to the intended practical context length |

For public results, report approximate numbers and include logs. Q6A thermal
state and storage/runtime layout can move the numbers enough that over-precise
claims are not helpful.
