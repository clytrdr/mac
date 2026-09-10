---
name: clearcache
description: Survey disk usage on macOS, report reclaimable developer caches, and delete only the items the user approves.
---

## Survey

Record free space, then measure cache and application directories. These commands only inspect usage:

```bash
df -h /
du -sh ~/.npm ~/.cache ~/Library/Caches/* 2>/dev/null | sort -rh | head -20
du -sh ~/Library/Containers/* 2>/dev/null | sort -rh | head -5
du -sh ~/Library/Application\ Support/* 2>/dev/null | sort -rh | head -10
du -sh ~/.cache/* ~/.npm/* 2>/dev/null | sort -rh | head -15
find ~/Code -maxdepth 3 -type d \( -name .tox -o -name .mypy_cache -o -name .pytest_cache \) -prune -exec du -sh {} + 2>/dev/null | sort -rh
tmutil listlocalsnapshots /
```

## Cleanup targets

Prefer the owning tool's cleanup command. Otherwise, remove only the approved directory.

| Target | Path | Cleanup |
|---|---|---|
| npm | `~/.npm` | `npm cache clean --force`; see below for other directories |
| uv | `~/.cache/uv` | `uv cache clean` |
| pip | `~/Library/Caches/pip` | `pip cache purge`; remove directory if `pip` is unavailable |
| pre-commit | `~/.cache/pre-commit` | `pre-commit clean` |
| Homebrew | `~/Library/Caches/Homebrew` | `brew cleanup --prune=all` |
| pip-tools | `~/Library/Caches/pip-tools` | Remove directory |
| node-gyp, puccinialin, Cypress | `~/Library/Caches/{node-gyp,puccinialin,Cypress}` | Remove each approved directory |
| Playwright | `~/Library/Caches/{ms-playwright,ms-playwright-go}` | Remove each approved directory |
| Project caches and tox environments | `<project>/{.mypy_cache,.pytest_cache,.tox}` | Remove each approved directory |
| JetBrains old versions | See below | Remove older version directories only |

Braces in the table list alternative paths. Resolve each path separately before deletion.

**npm:** Report each `~/.npm/*` directory separately. The cleanup command clears `_cacache` but leaves `_npx` and `_prebuilds`; offer these separately. `_prebuilds` requires another binary download. `content-v2` and `index-v5` are inside `_cacache`, not directly under `~/.npm`.

**JetBrains:** Get the installed version and list cache and support directories:

```bash
defaults read /Applications/PyCharm.app/Contents/Info.plist CFBundleShortVersionString
ls ~/Library/Caches/JetBrains ~/Library/Application\ Support/JetBrains
```

Only offer directories older than the installed version, in either location. If none exist, report that and omit JetBrains from the cleanup options.

## Report and approval

Show targets in a table, largest first, with sizes and literal absolute paths. Ask one question about which groups to delete, and wait for explicit approval. Allow any combination or none:

- **Rebuildable caches:** npm `_cacache` and `_npx`, pre-commit, pip, pip-tools, uv, Homebrew, mypy, pytest, tox.
- **Downloaded binaries and toolchains:** npm `_prebuilds`, Cypress, Playwright, node-gyp, puccinialin. Explain that the next test or build needs to download them again.
- **JetBrains old versions:** Include only when older versions exist.

## Delete and verify

Delete only approved items. Keep deletion commands separate from survey commands. Each `rm -rf` call must use an explicit absolute path, with no `~`, environment variables, globs, or command substitution.

Compare `df -h /` and per-item `du -sh` results before and after deletion. Report a table with item, size before, and size after. Small changes may be hidden by `df -h` rounding; use per-item measurements in that case. A missing deleted path makes `du` exit non-zero; this is expected.

## Out of scope

- All Docker commands, including usage surveys and cleanup.
- Claude Desktop and `~/Library/Application Support/Claude`. Claude in Chrome needs the app's `chrome-native-host` helper.
- Browser caches and data, including `~/Library/Caches/Google` and Safari data. Report their sizes as out of scope.
- Active project environments such as `.venv` and `node_modules`, agent configuration (`~/.claude`, `~/.codex`, `~/.gemini`), and current JetBrains version directories.
- User files in Documents, Desktop, Downloads, Photos, or elsewhere.
