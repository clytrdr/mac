---
name: clearcache
description: Survey disk usage on macOS, report reclaimable developer caches, and delete only the items the user approves.
---

Free up disk space on macOS by removing regenerable developer caches. Always survey first, report the findings, and get user approval before deleting anything.

## Workflow

1. **Survey**: Measure the current state. Do not delete anything in this step.
2. **Report**: Show a table of reclaimable items with sizes, sorted largest first.
3. **Confirm**: Ask the user which groups to delete. Wait for explicit approval.
4. **Delete**: Remove only the approved items.
5. **Verify**: Compare free space before and after. Report the reclaimed amount.

## Step 1: Survey

Record free space first:

```bash
df -h /
```

Measure the known cache locations. Run `du -sh` on each path and sort by size:

```bash
du -sh ~/.npm ~/.cache ~/Library/Caches/* 2>/dev/null | sort -rh | head -20
du -sh ~/Library/Containers/* 2>/dev/null | sort -rh | head -5
du -sh ~/Library/Application\ Support/* 2>/dev/null | sort -rh | head -10
```

Break down the two directories that hold more than one cache:

```bash
du -sh ~/.cache/* ~/.npm/* 2>/dev/null | sort -rh | head -15
```

Check project-local regenerable directories:

```bash
find ~/Code -maxdepth 3 -type d \( -name .tox -o -name .mypy_cache -o -name .pytest_cache \) -prune -exec du -sh {} + 2>/dev/null | sort -rh
```

Check Time Machine local snapshots:

```bash
tmutil listlocalsnapshots /
```

## Step 2: Known safe targets

These caches are regenerable. The owning tool rebuilds them on the next run.

Before running a delete command, resolve its target to a literal absolute path and show that
path to the user. Never pass `~`, an environment variable, a glob, or command substitution to
`rm -rf`. Prefer the owning tool's cleanup command when one is available.

| Target | Path | Delete action |
|---|---|---|
| npm cache | `~/.npm` | Run `npm cache clean --force`, then remove the resolved `_npx` directory if approved |
| uv cache | `~/.cache/uv` | `uv cache clean` |
| pip cache | `~/Library/Caches/pip` | Run `pip cache purge`, or remove the resolved directory if `pip` is not on PATH |
| pip-tools cache | `~/Library/Caches/pip-tools` | Remove the resolved directory |
| pre-commit cache | `~/.cache/pre-commit` | `pre-commit clean` |
| Homebrew cache | `~/Library/Caches/Homebrew` | `brew cleanup --prune=all` |
| node-gyp headers | `~/Library/Caches/node-gyp` | Remove the resolved directory |
| puccinialin (Rust toolchain) | `~/Library/Caches/puccinialin` | Remove the resolved directory |
| Cypress binaries | `~/Library/Caches/Cypress` | Remove the resolved directory |
| Playwright browsers | `~/Library/Caches/ms-playwright`, `~/Library/Caches/ms-playwright-go` | Remove each approved resolved directory separately |
| tox environments | `<project>/.tox` | Remove each approved absolute project path separately |
| mypy cache | `<project>/.mypy_cache` | Remove each approved absolute project path separately |
| pytest cache | `<project>/.pytest_cache` | Remove each approved absolute project path separately |
| JetBrains old versions | see below | Remove old version directories only, using resolved absolute paths |

Cypress, Playwright, node-gyp, and puccinialin hold downloaded binaries and toolchains.
They are safe to delete, but the next test or build run has to download them again.
Say so in the report instead of listing them next to the cheap caches.

### npm

`npm cache clean --force` clears npm's `_cacache` package store but does not empty `~/.npm`.
It can leave these regenerable directories behind:

- `_npx`: packages run through `npx`. The clean command does not cover it at all.
- `_prebuilds`: downloaded prebuilt native binaries. Offer this with the expensive-to-download
  group when it is present.

Measure `~/.npm/*` in the survey and report each directory separately. Do not try to remove
`content-v2` or `index-v5` as top-level directories. Current npm stores them inside `_cacache`.

### JetBrains old versions

JetBrains IDEs leave cache and support directories behind after upgrades. Delete only directories for versions older than the installed one.

1. Get the installed version first:
   ```bash
   defaults read /Applications/PyCharm.app/Contents/Info.plist CFBundleShortVersionString
   ```
2. List the version directories:
   ```bash
   ls ~/Library/Caches/JetBrains ~/Library/Application\ Support/JetBrains
   ```
3. Delete only directories whose version is lower than the installed version, in both locations. Never delete the directory that matches the installed version.

If the only directory present matches the installed version, there is nothing to delete.
Report that and move on. Do not offer JetBrains as an option in that case.

## Step 3: Confirm

Show the report, then ask one confirmation question. The user may select any combination of
groups, including none. Do not delete anything the user did not approve.

Group the targets instead of listing every path as its own option:

1. **Safe set**: caches the owning tool rebuilds automatically and cheaply
   (npm `_cacache`, pre-commit, pip, pip-tools, uv, Homebrew, mypy, pytest, tox).
2. **Expensive to re-download**: npm `_prebuilds`, Cypress, Playwright, node-gyp, puccinialin.
   Say in the option text that these need a re-download before the next test or build run.
3. **JetBrains old versions**: Offer this only when older versions exist.
4. **Delete nothing.**

## Step 4: Delete and verify

Run the delete commands for the approved items only. Then measure the result two ways:

- `df -h /` for the overall figure.
- `du -sh` on each deleted path for the per-item figure.

The `df` output is in Gi units, so a delete under about 1GB does not move the number.
The per-item measurement is the one to report in that case. `du -sh` on a deleted path
exits non-zero; that is the expected result, not a failure.

Report the result as a table: item, size before, size after.

## Forbidden actions

Never do any of these, even if a generic cleanup guide suggests them:

- **Never run any Docker command.** This skill does not touch Docker at all. Do not survey Docker usage (`docker system df`) and do not clean up images, containers, build cache, or volumes. Docker cleanup is out of scope, even if the user has free space problems.
- **Never uninstall Claude Desktop or delete its data** (`~/Library/Application Support/Claude`). The Claude in Chrome extension depends on the app's `chrome-native-host` helper.
- **Never delete browser caches** such as `~/Library/Caches/Google` (Chrome) or Safari data. They are large, but they hold session state, not build output. Report the size and mark them out of scope.
- **Never delete active project environments** such as `.venv` or `node_modules` of projects in use, agent configuration such as `~/.claude`, `~/.codex`, or `~/.gemini`, or the current JetBrains version directories.
- **Never delete user files** (Documents, Desktop, Downloads, Photos). This skill covers regenerable caches only.
- Do not chain a delete command with a survey command. Keep `rm -rf` calls separate and pass explicit absolute paths.
