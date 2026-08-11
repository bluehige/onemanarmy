# Validation matrix

## E0 — contract

Run:

```powershell
py -3 .agents/skills/onemanarmy-ui-ux/scripts/validate_contract.py --root .
```

This checks the shared font, canvas, renderer, shell boundary, theme tokens, exports, and automatic routing declaration. It does not judge visual quality.

If `py` is not on PATH, use `python`, `python3`, or the installed Python 3 launcher path. Record the actual launcher; do not skip the validator because one alias is absent.

### GUX-Q8 project application

Use the upstream weights and thresholds, with these project evidence anchors:

| Dimension | Weight | One-Man Formation evidence |
|---|---:|---|
| player intent | 18 | one player question and one primary decision per screen |
| hierarchy/readability | 14 | scene-first P0/P1/P2/P3 hierarchy and real-background contrast |
| affordance/mapping | 12 | visible focus/hit regions and input-specific behavior |
| feedback/state visibility | 14 | accepted input → state change → authored consequence |
| cognitive/physical load | 12 | no dashboard memory burden, precision drag, or repeated input |
| error prevention/recovery | 8 | cancel/retry/replay paths without narrative failure |
| accessibility/input/responsiveness | 12 | supported input completion, 44px touch targets, no clipping |
| visual identity/immersion | 10 | prompt-04 ink/paper hierarchy without generic combat HUD |

Calculate `weighted total = Σ(weight × score / 4)`. Structural `PASS` requires no Hygiene blocker, weighted total at least 80, and every dimension at least 3/4. This is still not E4 user approval.

## E1 — static captures

Capture the same title, story, choice, focus, hold, pull, cinematic, and consequence states. Record scene ID, text, state, viewport, branch, SHA, renderer, and build ID.

## E2 — real render and parity

- Export Windows and Web from the same clean source commit.
- Render actual Windows Forward+ and Web GL Compatibility at 1280×720 physical with the canonical 1920×1080 logical canvas. A Windows GL Compatibility diagnostic capture may isolate renderer rasterization, but it does not replace the shipping Windows capture.
- Compare each state pair: dimensions, crop, panel bounds, line wrapping, font fallback, baselines, focus bounds, and browser overlays.
- Acceptance: geometry within 2 physical pixels, font baseline within 1 physical pixel, identical strings/line wraps, no clipping, and no Web chrome over gameplay.
- Renderer-only antialiasing differences may use a documented perceptual tolerance; a different layout, font, wrap, or hierarchy never may.

For a deterministic whole-frame regression gate, run:

```powershell
& .\.tools\godot\Godot_v4.6.3-stable_win64_console.exe --headless --path . `
  --script res://tools/validators/compare_ui_captures.gd -- `
  --reference=<windows.png> --candidate=<web.png> --diff=<diff.png>
```

The pixel metric detects frame drift but does not identify font fallback or prove hierarchy quality; inspect the pair and diff alongside its result.

## E3 — interaction

- Windows: mouse, keyboard, and mapped gamepad path.
- Web desktop: pointer and keyboard path.
- Web mobile: real touch through title, dialogue, focus, choice, hold/pull, cinematic, and consequence.
- Confirm primary touch targets are at least 44×44 physical CSS pixels at 844×390.
- Confirm 393×659 portrait displays the rotate notice and hides the canvas.

## E4 — user evidence

Only an actual user test may decide whether the interface feels clear, premium, moving, or fun. Record confusion, first action, misclicks, reading effort, and the user's own verdict. Automated parity is necessary but not product approval.

## Evidence invalidation

Repeat affected evidence when source SHA, UI data, translation, input mapping, font, design asset, renderer, viewport, or export output changes.

Report separate verdicts for the previous public build and the current candidate when their evidence differs. Never merge a known-failing baseline with a pending candidate into one ambiguous verdict.
