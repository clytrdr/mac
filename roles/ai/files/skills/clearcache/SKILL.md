---
name: clearcache
description: Survey disk usage on macOS, report reclaimable developer caches, and delete only the items the user approves.
---

## Survey

Record free space, then measure cache and application directories. These commands only inspect usage. Run them in one call:

```bash
df -h /
du -sh ~/.npm/* ~/.cache/* ~/Library/Caches/* 2>/dev/null | sort -rh | head -30
du -sh ~/Library/Application\ Support/* 2>/dev/null | sort -rh | head -10
find ~/Code -maxdepth 3 -type d \( -name .tox -o -name .mypy_cache -o -name .pytest_cache \) -prune -exec du -sh {} + 2>/dev/null | sort -rh
tmutil listlocalsnapshots /
brew cleanup --prune=all --dry-run
defaults read /Applications/PyCharm.app/Contents/Info.plist CFBundleShortVersionString
du -sh ~/Library/Caches/JetBrains/* ~/Library/Application\ Support/JetBrains/* 2>/dev/null
```

## Cleanup targets

Prefer the owning tool's cleanup command. Otherwise, remove only the approved directory.

| Target | Path | Cleanup | Group |
|---|---|---|---|
| npm cache | `~/.npm/_cacache` | `npm cache clean --force` | Rebuildable caches |
| npm npx | `~/.npm/_npx` | Remove directory | Rebuildable caches |
| npm prebuilds | `~/.npm/_prebuilds` | Remove directory | Downloaded binaries |
| uv | `~/.cache/uv` | `uv cache clean` | Rebuildable caches |
| pip | `~/Library/Caches/pip` | `pip cache purge` | Rebuildable caches |
| pip-tools | `~/Library/Caches/pip-tools` | Remove directory | Rebuildable caches |
| pre-commit | `~/.cache/pre-commit` | `pre-commit clean` | Rebuildable caches |
| Homebrew | `~/Library/Caches/Homebrew` | `brew cleanup --prune=all` | Rebuildable caches |
| Project caches and tox environments | `<project>/{.mypy_cache,.pytest_cache,.tox}` | Remove directory | Rebuildable caches |
| node-gyp, puccinialin, Cypress, Playwright | `~/Library/Caches/{node-gyp,puccinialin,Cypress,ms-playwright,ms-playwright-go}` | Remove directory | Downloaded binaries |
| JetBrains old versions | See below | Remove directory | JetBrains old versions |

Braces in the table list alternative paths.

**npm:** `npm cache clean --force` clears only `_cacache`. `content-v2` and `index-v5` are inside `_cacache`, not directly under `~/.npm`.

**Homebrew:** The cleanup command also removes old formula versions and other files outside the cache. Report any paths in the dry-run output that are outside `~/Library/Caches/Homebrew`.

**JetBrains:** Compare the PyCharm version with the cache and support directory names. Only offer directories older than the installed version, in either location. If none exist, report that and omit JetBrains from the cleanup options.

## Report and approval

Show targets in a table, largest first, with sizes and literal absolute paths. Ask one question about which groups to delete, and wait for explicit approval. Allow any combination or none of the groups in the table's Group column. For downloaded binaries, explain that the next test or build needs to download them again.

## Delete and verify

Delete only approved items. Keep deletion commands separate from survey commands. Each `rm -rf` call must use an explicit absolute path, with no `~`, environment variables, globs, brace expansion, or command substitution.

Use the survey sizes as the sizes before deletion. After deletion, run `df -h /` and `du -sh` on each item. Report free space before and after, and a table with item, size before, and size after. A missing deleted path makes `du` exit non-zero; this is expected.

## Out of scope

- All Docker commands, including usage surveys and cleanup.
- Claude Desktop and `~/Library/Application Support/Claude`. Claude in Chrome needs the app's `chrome-native-host` helper.
- Browser caches and data, including `~/Library/Caches/Google` and Safari data. Report their sizes as out of scope.
- Active project environments such as `.venv` and `node_modules`, agent configuration (`~/.claude`, `~/.codex`, `~/.gemini`), and current JetBrains version directories.
- User files in Documents, Desktop, Downloads, Photos, or elsewhere.
