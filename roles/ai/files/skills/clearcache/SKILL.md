---
name: clearcache
description: Survey disk usage on macOS, report reclaimable developer caches, and delete only the items the user approves.
allowed-tools: Bash, Read, AskUserQuestion
---

Free up disk space on macOS by removing regenerable developer caches. Always survey first, report the findings, and get user approval before deleting anything.

## Workflow

1. **Survey**: Measure the current state. Do not delete anything in this step.
2. **Report**: Show a table of reclaimable items with sizes, sorted largest first.
3. **Confirm**: Use AskUserQuestion to ask which items to delete.
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

Check Docker usage (cleanup is limited to the commands in the Docker section):

```bash
docker system df
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

| Target | Path | Delete command |
|---|---|---|
| npm cache | `~/.npm/_cacache` | `npm cache clean --force` |
| uv cache | `~/.cache/uv` | `uv cache clean` |
| pip cache | `~/Library/Caches/pip` | `pip cache purge`, or `rm -rf ~/Library/Caches/pip` if `pip` is not on PATH |
| pre-commit cache | `~/.cache/pre-commit` | `pre-commit clean` |
| Homebrew cache | `~/Library/Caches/Homebrew` | `brew cleanup --prune=all` |
| tox environments | `<project>/.tox` | `rm -rf <project>/.tox` |
| mypy cache | `<project>/.mypy_cache` | `rm -rf <project>/.mypy_cache` |
| JetBrains old versions | see below | `rm -rf` on old version dirs only |
| Docker | images, build cache, stopped containers, anonymous volumes | `docker system prune --all`, then `docker volume prune` (see below) |

### Docker

The user's standard cleanup is these two commands, run as separate commands:

```bash
docker system prune --all
docker volume prune
```

This is safe for database data. `docker volume prune` (Docker 23+) removes only unused **anonymous** volumes. Named volumes and volumes attached to a container are kept. Both commands prompt for confirmation on their own; run them in the foreground so the user sees the prompt, or confirm with AskUserQuestion first and pass `--force`.

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

## Step 3: Confirm

Show the report and ask with AskUserQuestion which items to delete. Ask one question per call. Do not delete anything the user did not approve.

## Step 4: Delete and verify

Run the delete commands for the approved items only. Then run `df -h /` again and report the reclaimed space as a table: item, size before, size after.

## Forbidden actions

Never do any of these, even if a generic cleanup guide suggests them:

- **Never remove named Docker volumes.** Do not run `docker system prune --volumes`, `docker volume prune --all`, or `docker volume rm`. Named volumes can hold database data. Docker cleanup is limited to the two commands in the Docker section above.
- **Never uninstall Claude Desktop or delete its data** (`~/Library/Application Support/Claude`). The Claude in Chrome extension depends on the app's `chrome-native-host` helper.
- **Never delete active project environments** such as `.venv` or `node_modules` of projects in use, `~/.claude`, or the current JetBrains version directories.
- **Never delete user files** (Documents, Desktop, Downloads, Photos). This skill covers regenerable caches only.
- Do not chain a delete command with a survey command. Keep `rm -rf` calls separate and pass explicit absolute paths.
