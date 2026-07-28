---
name: reviewcode
description: Review one or more files or directories with the current agent itself, then implement approved fixes. Loads a language reference for the file types it finds.
disable-model-invocation: true
allowed-tools: Read, Edit, Write, Glob, Grep, NotebookEdit, AskUserQuestion, Bash(ng lint:*), Bash(ng build:*), mcp__pycharm__lint_files, mcp__pycharm__get_file_problems, mcp__context7__resolve-library-id, mcp__context7__query-docs
---

Review the files and directories given in `$ARGUMENTS`, then implement approved fixes. This agent does the review itself; do not delegate.

## Workflow

1. Parse `$ARGUMENTS` into paths. If empty, ask with `AskUserQuestion` — do not guess. If a path does not exist, report it and stop.
2. Expand each directory recursively with `Glob` (`**/*`, plus `**/.*` for dotfiles such as `.gitignore`). Keep source and config text files only. Exclude generated and vendored directories (`.git/`, `node_modules/`, `.venv/`, `venv/`, `__pycache__/`, `dist/`, `build/`, `coverage/`, `vendor/`, `.idea/`, caches), lock files, and binaries. Match the directory name only — never drop a dotfile that starts with the same characters.
3. Deduplicate the list. If empty, report and stop. If more than 30 files, show the count and confirm with `AskUserQuestion` before reviewing.
4. `Read` the reference for each file type present — once per type, not per file:

   | File type | Reference |
   | --- | --- |
   | `.py`, `.pyi`, `.ipynb` | `references/python.md` |
   | `.ts`, `.tsx`, `.js`, `.jsx` | `references/typescript.md` |
   | `.html`, `.htm` | `references/html.md` |
   | `Dockerfile`, `*.dockerfile`, `docker-compose.yml`, `cloudbuild.yaml`, `.dockerignore`, `.gcloudignore` | `references/docker.md` |
   | anything else (including `.yml`, `.yaml`, `.json`, `.toml`, `.ini`, `.cfg`, `.conf`, `.j2`) | none — common checks only |
5. Review each file: `Read` the full content, apply the common checks (bugs, security, performance, readability, maintainability, deviations from surrounding conventions) and the reference checks, and run the IDE inspections below. Review notebook code cells as code and Markdown cells as prose; ignore outputs. Do not fix anything during this pass.
6. Present findings grouped by file and severity (blocker / major / minor / nit). Each finding needs a concrete suggestion and a location: a line number, or a cell index and line for notebooks. Say explicitly when a file has no findings.
7. For each actionable finding, ask approval with `AskUserQuestion`. Batch questions into one call where possible.
8. Implement approved fixes with `Edit` or `Write`. For notebooks, use `NotebookEdit` and change one cell at a time.
9. Recheck the modified files with the same IDE inspections. The warning count must not go up; fix any warning a fix introduced in the same pass (no new approval needed). Report each modified file, the findings addressed, and the warning count before and after.

## IDE inspections

Use `mcp__pycharm__lint_files` for file lists and `mcp__pycharm__get_file_problems` for a single file. Pass `projectPath` and project-relative paths, and set `min_severity` to `warning`. PyCharm inspects Python, TypeScript, JavaScript, HTML, YAML, and JSON. Merge the problems into the findings: `ERROR` → blocker, `WARNING` → major, `WEAK WARNING` → minor; adjust with a stated reason when the code says otherwise.

If the tools are unavailable, or a file is outside the project root, say so once and review by reading. Do not stop the run.

## Rules

- Review first, fix later. Never apply a fix the user has not approved via `AskUserQuestion`.
- Fix the cause of a warning. No `# noqa`, `# type: ignore`, `// @ts-ignore`, `eslint-disable`, or `noinspection` unless the user asks; then say why in the report.
- If the IDE is wrong, keep the code and report the warning as a false positive.
- Preserve the file's style unless a finding targets style.
- In notebooks, change cell source only — not cell types, execution counts, outputs, or metadata.
- If a reference asks for a tool that is unavailable, say so once and keep reviewing.
- Report skipped files (binary, excluded, unreadable) explicitly.
- Do not commit. Leave changes for the user to review.
