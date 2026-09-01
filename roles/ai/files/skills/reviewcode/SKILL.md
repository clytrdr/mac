---
name: reviewcode
description: Review one or more files or directories with the current agent itself. Implement approved fixes. Load a language reference for each found file type.
---

Review the files and directories from the user request. Then apply approved fixes.

## Workflow

1. Collect paths from the user request.
   If the user did not provide paths, ask for them and wait for the response.
   If a path does not exist, report it and stop.
2. Expand each directory recursively. Include dotfiles such as `.gitignore`.
   Keep source and config text files only.
   Exclude generated and vendored directories (`.git/`, `node_modules/`, `.venv/`, `venv/`, `__pycache__/`, `dist/`, `build/`, `coverage/`, `vendor/`, `.idea/`, caches), lock files, and binaries.
   Match excluded directory names exactly. For example, exclude `.git/`, but keep `.gitignore`,
   `.gitattributes`, and `.github/`.
3. Remove duplicates from the list.
   If the list is empty, report it and stop.
   If the list contains more than 30 files, show the count and ask for confirmation before reviewing.
4. Read the reference for each file type present in the list. Read each reference once per type, not once per file:

   | File type | Reference |
   | --- | --- |
   | `.py`, `.pyi`, `.ipynb` | `references/python.md` |
   | `.ts`, `.tsx`, `.js`, `.jsx` | `references/typescript.md` |
   | `.html`, `.htm` | `references/html.md` |
   | `Dockerfile`, `*.dockerfile`, `docker-compose.yml`, `cloudbuild.yaml`, `.dockerignore`, `.gcloudignore` | `references/docker.md` |
   | anything else (including `.yml`, `.yaml`, `.json`, `.toml`, `.ini`, `.cfg`, `.conf`, `.j2`) | none — common checks only |
5. Read and review each file completely.
   Apply common checks: check for bugs, security, performance, readability, maintainability, and deviations from surrounding conventions.
   Apply the reference checks.
   Run the IDE inspections described below.
   Review notebook code cells as code and Markdown cells as prose.
   Ignore outputs.
   Do not fix anything during this pass.
6. Group findings by file and severity (blocker / major / minor / nit).
   Provide a concrete suggestion and a location for each finding: a line number, or a cell index and line for notebooks.
   Explicitly report when a file has no findings.
7. Present all actionable findings together and ask which fixes to apply. Wait for explicit approval.
8. Apply only approved fixes.
   For notebooks, use a notebook-aware editor when available and change one cell at a time.
   Otherwise, keep the notebook JSON structure intact and edit cell source only.
9. Check the modified files again with the same IDE inspections.
   The warning count must not increase.
   Fix any warning that a fix introduced in the same pass (no new approval needed).
   Report each modified file, the findings addressed, and the warning count before and after.

## IDE inspections

Use the PyCharm MCP tool `lint_files` for file lists and `get_file_problems` for a single file.
The host may add its own namespace to these tool names.
Pass `projectPath` and project-relative paths, and set `min_severity` to `warning`.
PyCharm inspects Python, TypeScript, JavaScript, HTML, YAML, and JSON.
Merge the problems into the findings:
- `ERROR` → blocker
- `WARNING` → major
- `WEAK WARNING` → minor

Adjust the severity if the code context requires it, and state the reason.
If the tools are not available, or if a file is outside the project root, report this once. Review the files by reading them directly. Do not stop the run.

## Rules

- Review first, fix later. Never apply a fix without explicit user approval.
- Fix the root cause of each warning. Do not add suppression comments (`# noqa`, `# type: ignore`, `// @ts-ignore`, `eslint-disable`, `noinspection`) unless the user asks for them. If the user asks for suppression, explain why in the report.
- If the IDE warning is incorrect, keep the code unchanged. Report the warning as a false positive.
- Preserve the file style unless a finding targets style.
- In notebooks, edit cell source only. Do not change cell types, execution counts, outputs, or metadata.
- If a reference asks for a tool that is not available, report this once and continue the review.
- Report skipped files (binary, excluded, unreadable) explicitly.
- Do not commit changes. Leave changes for the user to review.
