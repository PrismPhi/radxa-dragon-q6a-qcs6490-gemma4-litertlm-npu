# 配布方針

## GitHub repository

公開してよいもの:

- source patch
- script
- documentation
- benchmark summary
- checksum

公開しないもの:

- `.litertlm`
- Qualcomm QAIRT/QNN libraries
- model weights
- 巨大log / archive
- credential / private path

## 任意のGitHub Release

patched runtime binaryは、関連するopen-source license上で再配布可能であり、
proprietary Qualcomm componentをbundleしていないことを確認できた場合のみ公開してください。

QNN shared libraryをreleaseへ含めないでください。

## Model hosting

`.litertlm` artifactは別のmodel hosting repositoryへ置くのが安全です。
model cardには以下を明記してください。

- upstream model
- license
- modifications
- hardware target
- runtime requirements
- SHA256
- Qualcomm runtime libraryを含まないこと

## Qualcomm runtime

利用者は、自分のQ6A image、SDK、または適切にlicensedされたsourceからQualcomm runtime componentを用意する必要があります。
