---
name: reviewbyself
description: Review one or more files or directories with the current agent itself, then implement approved fixes.
disable-model-invocation: true
allowed-tools: Read, Edit, Write, Glob, Grep, NotebookEdit, AskUserQuestion
---

Perform a thorough review of one or more files or directories with the current agent itself (no external reviewer). Then implement any approved fixes.

Unlike `/reviewbycodex`, this skill does not delegate to Codex. The same agent reads the code, reviews it, and writes the fixes. Directory arguments are expanded recursively.

## Arguments

One or more file paths or directory paths provided after the skill name:

```
/reviewbyself path/to/file1.py path/to/dir path/to/file2.ts
```

`$ARGUMENTS` contains the raw argument string.

## Instructions

1. Parse `$ARGUMENTS` into a list of paths.
   - If empty, use `AskUserQuestion` to ask the user which file(s) or directory(ies) to review. Do not guess.
2. Resolve each path to an absolute path relative to the current working directory.
   - For any path that does not exist, report the missing path and stop. Do not silently skip.
3. Expand each directory path into a recursive file list with `Glob` (pattern `**/*`).
   - Keep only source and config text files (code, scripts, YAML, JSON, Markdown, templates, dotfiles).
   - Treat Jupyter notebooks (`.ipynb`) as notebooks, not as raw JSON.
   - Exclude generated and vendored content: `.git`, `node_modules`, `.venv`, `venv`, `__pycache__`, `dist`, `build`, `vendor`, `.idea`, caches, lock files, and binary files.
   - File arguments are used as-is.
4. Deduplicate the final file list.
   - If the list is empty, report that and stop.
   - If the list has more than 30 files, show the count and use `AskUserQuestion` to confirm before reviewing. Offer to narrow the scope.
5. Review **each** file:
   - `Read` the full file content. For a notebook, `Read` returns the cells with their outputs.
   - Look for: bugs, security issues, performance problems, readability, maintainability, and deviations from the file's surrounding conventions. Use `Read` and `Grep` on neighboring files when needed to check conventions.
   - For a Jupyter notebook, review the code cells as code and the Markdown cells as prose. Ignore cell outputs.
   - Record findings as a bulleted list grouped by severity (blocker / major / minor / nit). Each finding must include a concrete suggestion and a location reference: a line number for regular files, or a cell index (and the line within the cell) for notebooks.
   - Do not fix anything during this pass — review only.
6. Present all findings to the user, grouped by file. If a file has no findings, say so explicitly.
7. For each actionable finding, use `AskUserQuestion` to ask whether to apply the fix. Batch multiple questions into a single `AskUserQuestion` call where possible.
8. Implement approved fixes locally.
   - Use `Edit` or `Write` for regular files.
   - For a Jupyter notebook, edit it one cell at a time and change the cell source only. In Claude Code, use `NotebookEdit`. If the agent has no notebook-aware edit tool, keep the `.ipynb` JSON structure intact and change only the text inside the cell `source` fields.
9. Report what was modified, listing each file and the findings that were addressed.

## Rules

- **Review first, fix later.** Never modify a file during the review pass (steps 5-6).
- Never apply a fix the user has not explicitly approved via `AskUserQuestion`.
- Preserve the original file's style and formatting unless a specific finding explicitly addresses style.
- When fixing a Jupyter notebook, change the cell source only. Do not change cell types, execution counts, cell outputs, or notebook metadata.
- Report skipped files (binary, excluded, unreadable) explicitly — do not silently drop them.
