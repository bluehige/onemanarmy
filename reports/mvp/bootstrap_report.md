# MVP Bootstrap Report

- Date: 2026-08-06
- Repository: `bluehige/onemanarmy`
- Base branch: `main`
- Base commit: `d2e6b159b6b256165f0659d3f05b11fb7c1aaffa`
- Implementation branch: `codex/mvp-ch01-v1`
- Working tree location: `onemanarmy-mvp`

## Godot

- Required version: `4.6.3.stable.official.7d41c59c4`
- Portable executable: `.tools/godot/Godot_v4.6.3-stable_win64_console.exe`
- Download source: official `godotengine/godot-builds` release `4.6.3-stable`
- Archive SHA256: `e39986a178d585ce7ac198fb8de6ea436366dc0cc00e594810c2e3e104c04b90`
- Version check: PASS
- Existing PATH version: `4.5.2.stable.official.6ce3de25a` (not used)
- 4.6.3 export templates: not installed at bootstrap; required before P12 Windows export

## Repository gates

- Project Skills discovered: 7/7
- Skill frontmatter: PASS
- Skill SHA256 manifest: `reports/mvp/skill_install_manifest.json`
- Planning repository validator: PASS
- Implementation branch: PASS
- Forbidden runtime modules created: 0

The planning validator initially reported that the master execution plan lacked the
literal phrase `수동 전투·전술 게임`. The existing genre contract already prohibited
both systems; the same zero-percent lock was added to the master plan and the validator
then passed.

## Commands

```powershell
python scripts/validate_planning_repository.py
.\.tools\godot\Godot_v4.6.3-stable_win64_console.exe --version
git rev-parse origin/main
git branch --show-current
```

## P0 result

`PASS` — the repository, branch, seven project Skills, exact engine version, and
planning package are ready for implementation.
