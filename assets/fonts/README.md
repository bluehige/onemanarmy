# Bundled Korean font

- Family: Noto Sans KR variable (`wght`)
- Upstream: Google Fonts, `ofl/notosanskr/NotoSansKR[wght].ttf`
- Upstream URL: <https://github.com/google/fonts/tree/main/ofl/notosanskr>
- License: SIL Open Font License 1.1; see `OFL.txt`

| File | Purpose | Bytes | SHA-256 |
|---|---|---:|---|
| `NotoSansKR-VF.ttf` | Godot project-wide Korean UI font | 10,414,588 | `194018E6B2B293A7964F037B25C0249CE1418BC9AB3C971060A03AA57861E252` |
| `../../web/NotoSansKR-Shell.woff2` | Korean/ASCII subset for the HTML loader and rotate notice | 27,600 | `CB2426F5BB4594059B83B4692CAA830DAF846F5C8171D31AEEA36B3E92F39CC8` |

The WOFF2 file was generated from the bundled TTF with FontTools 4.63.0. It contains ASCII plus only the Korean and CJK characters used by the Web shell; the full Godot game continues to use the original TTF.
