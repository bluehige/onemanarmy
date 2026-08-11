# HANDOFF-CH01-PC-WEB-UI-PARITY

```yaml
handoff_id: HANDOFF-CH01-PC-WEB-UI-PARITY
recorded_at: 2026-08-10T19:00:03+09:00
branch: codex/ch01-redesign-v2
runtime_source_commit: 07b2fc92d09ebae1da413fb81a73aba947eab087
package_record_commit: bde38fb4ce4b78ff88af96f62a5c6fab29825f42
engine: Godot 4.6.3.stable.official.7d41c59c4
targets: [Windows Forward+, Web GL Compatibility]
aggregate_validation: PASS
windows_forward_plus_pck: "PASS (114 files)"
windows_exported_exe_headless_smoke: "PASS (exit 0)"
pages_workflow: "PASS (31377062188)"
pages_http: "PASS (200)"
human_e4: PENDING
physical_gamepad: NOT_RUN
long_soak: NOT_RUN
cross_gpu: NOT_RUN
```

## Recorded parity evidence

- 1280x720 title: `PASS`; mean error `0.00598663`, visible error `0.02357313`.
- 1280x720 story: `PASS`; mean error `0.00829525`, visible error `0.03226020`.
- Desktop Web canvas at 1280x720: browser overlays absent.
- Touch at 844x390, title to story: `PASS`.
- Portrait at 393x659, rotation overlay: `PASS`.
- Pages: [workflow run](https://github.com/bluehige/onemanarmy/actions/runs/31377062188) succeeded; [public build](https://bluehige.github.io/onemanarmy/?build=07b2fc9) returned HTTP `200`.

## Release artifact record

| Artifact | Bytes | SHA-256 |
|---|---:|---|
| EXE | 104518656 | `FDA69AD440435BD93D7C0DFCC43F717BADD5E051F1B3A19D60AA281E526B8CAB` |
| PCK | 29107508 | `E92BEACA263D3A599FE7A52496237CAC9B7E3B3549CCE141CE778E066E820FD7` |
| PLAYTEST_GUIDE.md | 2425 | `1F037D558B67280FE0D4CC6EF65128518E57D95EB11E6B8775BEEECA8EF671F5` |
| KNOWN_ISSUES.md | 1401 | `83B09CD58619A94BBB3A94353A490A90C9CBF56D997FDED2C05BDE36E53FE4DD` |
| ZIP (4 entries) | 65018685 | `C4C938A794005C03A5516171951643DE7898A40A4080EB13998C2995F54888CA` |
| ZIP sidecar | 98 | `2232B119CCD0AFC7C80D956C3ED688313CB77BE77A0BCE0FCB0912DAF3986AAE` |

## Boundary and follow-up

This release synchronizes the PC/Web baseline and fonts. It does **not** approve or claim a redesign of the current generic UI aesthetic. Do not infer product `KEEP` from automated results. Human E4 remains `PENDING`; physical-gamepad, long-soak, and cross-GPU validation remain `NOT_RUN`.
