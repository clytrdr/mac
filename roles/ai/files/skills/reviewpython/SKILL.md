---
name: reviewpython
description: Review one or more files or directories with the current agent itself, then implement approved fixes.
disable-model-invocation: true
allowed-tools: Read, Edit, Write, Glob, Grep, NotebookEdit, AskUserQuestion, mcp__pycharm__lint_files, mcp__pycharm__get_file_problems
---

Perform a thorough review of one or more files or directories with the current agent itself (no external reviewer). Then implement any approved fixes.

This skill does not delegate to an external reviewer. The same agent reads the code, reviews it, and writes the fixes. Directory arguments are expanded recursively.

## Arguments

One or more file paths or directory paths provided after the skill name:

```
/reviewpython path/to/file1.py path/to/dir path/to/file2.ts
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
   - For Python files, also run the IDE inspections. See [IDE inspections for Python](#ide-inspections-for-python).
   - Record findings as a bulleted list grouped by severity (blocker / major / minor / nit). Each finding must include a concrete suggestion and a location reference: a line number for regular files, or a cell index (and the line within the cell) for notebooks.
   - Do not fix anything during this pass — review only.
6. Present all findings to the user, grouped by file. If a file has no findings, say so explicitly.
7. For each actionable finding, use `AskUserQuestion` to ask whether to apply the fix. Batch multiple questions into a single `AskUserQuestion` call where possible.
8. Implement approved fixes locally.
   - Use `Edit` or `Write` for regular files.
   - For a Jupyter notebook, edit it one cell at a time and change the cell source only. In Claude Code, use `NotebookEdit`. If the agent has no notebook-aware edit tool, keep the `.ipynb` JSON structure intact and change only the text inside the cell `source` fields.
9. If any Python file was modified, run `mcp__pycharm__lint_files` again on the modified Python files.
   - Compare the result with the review pass. The warning count must not go up.
   - If a fix added a new warning, fix it in the same pass. This is a follow-up to an approved fix, so no new approval is needed.
   - If a warning cannot be removed without changing behavior, leave it and report it.
10. Report what was modified, listing each file and the findings that were addressed.
    - For Python files, also report the warning count before and after.

## IDE inspections for Python

Use the PyCharm MCP tools to get the warnings the IDE shows. They catch type errors, unused imports, shadowed names, and unreachable code that a plain read can miss. The goal is to end the run with fewer warnings than it started with.

- `mcp__pycharm__lint_files` takes a list of files. Use it for the review pass and for the recheck in step 9.
- `mcp__pycharm__get_file_problems` takes one file. Use it when you check a single file.
- Pass `projectPath` (the project root) and project-relative paths in `files` or `filePath`.
- Set `min_severity` to `warning` so weak warnings are included.
- Lines and columns are 1-based.
- Only files inside the project root are analyzed. A file outside it comes back with `notAnalyzedReason`.

Merge each reported problem into the findings of step 5. Map severity like this: `ERROR` to blocker, `WARNING` to major, `WEAK WARNING` to minor. Raise or lower the level when the code says otherwise, and write down why.

If the PyCharm MCP tools are not available, or the file is outside the project root, say so once and review the file by reading it. Do not stop the run.

## Rules

- **Review first, fix later.** Never modify a file during the review pass (steps 5-6).
- Never apply a fix the user has not explicitly approved via `AskUserQuestion`.
- Fix the cause of a warning. Do not silence it with `# noqa`, `# type: ignore`, or a `noinspection` comment. Use a suppression only when the user asks for it, and say why in the report.
- A warning is not always a defect. If the IDE is wrong, keep the code and report the warning as a false positive.
- Preserve the original file's style and formatting unless a specific finding explicitly addresses style.
- When fixing a Jupyter notebook, change the cell source only. Do not change cell types, execution counts, cell outputs, or notebook metadata.
- Report skipped files (binary, excluded, unreadable) explicitly — do not silently drop them.
