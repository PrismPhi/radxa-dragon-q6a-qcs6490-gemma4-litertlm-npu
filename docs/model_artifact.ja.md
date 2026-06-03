# Model Artifact

Q6A ctx1024 model artifactは、このGitHub repositoryには保存しません。
Hugging Faceで別途公開しています。

<https://huggingface.co/PrismPhi/gemma4-e2b-q6a-qcs6490-litertlm-npu>

元のlocal artifact名:

```text
gemma4_e2b_q6a_qcs6490_ctx1024_npu.litertlm
```

元のSHA256:

```text
0d72585954b3855df20735b666926b5617c0e4a43528be6c00abe06fa0812347
```

## 推奨hosting

`.litertlm` はGitHub repositoryではなく、Hugging Faceなどのmodel hosting serviceへ置くことを推奨します。

model cardには以下を含めてください。

- Apache-2.0 license
- NOTICE
- source attribution
- SHA256
- hardware target
- known limitations
- runtime compatibility notes

## 記録すべきlineage

- upstream base: Google Gemma 4 E2B instruction-tuned model
- LiteRT-LM artifact family: Gemma 4 E2B LiteRT-LM
- local adopted route: ctx1024 Direct NPU for Q6A/QCS6490

## 同梱しないもの

Qualcomm QAIRT/QNN runtime libraryは、再配布権限を個別に確認できない限り、
model artifactへ同梱しないでください。

## source参照

upstream/source locationと、Hugging Faceで公開したQ6A ctx1024 artifactの状態は
`docs/artifact_sources.ja.md` を参照してください。
