---
name: reviewbycodex
description: Delegate a file review to Codex as a subagent, then implement approved fixes locally with Claude.
disable-model-invocation: true
allowed-tools: Read, Edit, Write, Glob, Bash(codex:*), AskUserQuestion
---

Delegate a thorough review of one or more specific files to Codex (running as a non-interactive subagent), then implement any approved fixes locally with Claude.

Unlike `/codex:review`, which reviews git state (staged/unstaged/branch diffs), this skill takes explicit file paths and reviews full file contents regardless of git status.

## Arguments

One or more file paths provided after the skill name:

```
/reviewbycodex path/to/file1.py path/to/file2.ts
```

`$ARGUMENTS` contains the raw argument string.

## Instructions

1. Parse `$ARGUMENTS` into a list of file paths.
   - If empty, use `AskUserQuestion` to ask the user which file(s) to review. Do not guess.
2. Resolve each path to an absolute path relative to the current working directory.
   - For any path that does not exist, report the missing path and stop. Do not silently skip.
   - This skill does not review Jupyter notebooks. Drop any `.ipynb` path, report it as skipped, and suggest `/reviewbyself` for notebooks. If no reviewable file remains, stop.
3. For **each** resolved file, invoke Codex non-interactively as a subagent:
   ```bash
   codex exec \
     --sandbox read-only \
     --skip-git-repo-check \
     "Review the file at <absolute-path> thoroughly. Look for: bugs, security issues, performance problems, readability, maintainability, and deviations from the file's surrounding conventions. Output findings as a bulleted list grouped by severity (blocker / major / minor / nit). Each finding must include a line number reference and a concrete suggestion. Do not attempt to fix anything — review only."
   ```
   - `codex exec` is used (not `codex review`) because `codex review` is git-state-oriented and does not accept file paths.
   - `--sandbox read-only` keeps Codex restricted to reading; it cannot modify files.
   - `--skip-git-repo-check` allows review of files outside a git repository.
   - Capture stdout for each invocation.
   - If `codex exec` exits non-zero, surface stderr verbatim and stop.
4. Present Codex's findings to the user, grouped by file. Relay Codex output faithfully — do not paraphrase or filter.
5. For each actionable finding, use `AskUserQuestion` to ask whether to apply the fix. Batch multiple questions into a single `AskUserQuestion` call where possible.
6. Implement approved fixes locally using `Edit` or `Write`. **Claude writes the code — Codex is never asked to emit a patch.**
7. Report what was modified, listing each file and the findings that were addressed.

## Rules

- **Codex reviews only; Claude implements.** Never ask Codex to write a patch or modify files.
- **No Jupyter notebooks.** Codex reads the raw file, so a `.ipynb` would be reviewed as raw JSON, not as notebook cells. Skip `.ipynb` inputs and point the user to `/reviewbyself`, which reviews notebooks cell by cell.
- Never apply a fix the user has not explicitly approved via `AskUserQuestion`.
- Preserve the original file's style and formatting unless a specific finding explicitly addresses style.
- If `codex exec` fails for any file, surface the stderr verbatim and stop — do not silently skip or fall back.
- Do not run `codex` with any sandbox mode other than `read-only` in this skill.
