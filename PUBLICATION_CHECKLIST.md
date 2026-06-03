# Publication Checklist

Before publishing, verify the following.

- [x] Confirm no `.litertlm`, `.so`, `.safetensors`, `.bin`, `.onnx`, or archives are tracked in this GitHub repository.
- [x] Confirm `.gitignore` is active.
- [x] Confirm `LICENSE`, `NOTICE`, `THIRD_PARTY_NOTICES.md`, and `LICENSE_AUDIT.md` are present.
- [x] Replace placeholder GitHub/Hugging Face URLs in docs.
- [x] Publish the `.litertlm` artifact separately on Hugging Face with license, NOTICE, SHA256, and modification notes.
- [x] Keep Qualcomm runtime library acquisition as a user-provided step.
- [x] Make clear that the Ubuntu Linux Q6A/QCS6490 NPU route is unofficial.
- [x] Confirm the Codex/AI-assistance disclosure is acceptable.
- [x] Confirm contact guidance points to GitHub Issues and profile links, not
      private credentials or hard-coded personal URLs.
- [ ] Re-run `scripts/check_q6a.sh` and `scripts/run_smoke.sh` on a fully hydrated Q6A install immediately before tagging a release.
- [ ] If publishing a runtime binary as a release asset, confirm its source commit
      and patch level. Do not include Qualcomm QNN libraries.
- [ ] Recheck the upstream Gemma 4 E2B and LiteRT-LM artifact pages before a
      formal release tag, because upstream model cards and licenses can change.

Preferred public GitHub repository name:

```text
radxa-dragon-q6a-qcs6490-gemma4-litertlm-npu
```

Suggested GitHub repository description:

```text
Unofficial Ubuntu 24.04 LiteRT-LM NPU runtime for Gemma 4 E2B on Radxa Dragon Q6A / Qualcomm QCS6490.
```

Suggested Hugging Face model repo name:

```text
gemma4-e2b-q6a-qcs6490-litertlm-npu
```

Current Hugging Face model artifact repository:

```text
https://huggingface.co/PrismPhi/gemma4-e2b-q6a-qcs6490-litertlm-npu
```
