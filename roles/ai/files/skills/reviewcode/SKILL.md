---
name: reviewcode
description: Review one or more files or directories. Implement approved fixes.
---

Review the files and directories from the user request. Then apply approved fixes.

## Workflow

1. Collect paths from the user request.
   If the user did not provide paths, ask for them and wait for the response.
   If a path does not exist, report it and stop.
2. Expand each directory recursively.
   In a git repository, list the files with `git ls-files --cached --others --exclude-standard -- <directory>`.
   This command leaves out git-ignored files.
   Outside a git repository, list all files. Include dotfiles such as `.gitignore`.
   In both cases, exclude generated and vendored directories (`.git/`, `node_modules/`, `.venv/`, `venv/`, `__pycache__/`, `dist/`, `build/`, `coverage/`, `vendor/`, `.idea/`, caches), lock files, and binaries.
   Match excluded directory names exactly. For example, exclude `.git/`, but keep `.gitignore`,
   `.gitattributes`, and `.github/`.
   Keep text files only: source code, configuration, scripts, templates, and documentation such as Markdown.
   These filters apply to expanded directories. Keep a file that the user named directly, unless it is a binary.
   Do not open a file whose name shows that it holds credentials, such as `.env`, `*.pem`, `*.key`, `.vault_pass`, or a service account key.
   This applies to a file that the user named directly too. Report the file as skipped.
3. Remove duplicates from the list.
   If the list is empty, report it and stop.
   If the list contains more than 30 files, show the count and ask for confirmation before reviewing.
4. Read the reference for each file type present in the list. Read each reference once per type, not once per file:

   | File type | Reference |
   | --- | --- |
   | `.py`, `.pyi`, `.ipynb` | `references/python.md` |
   | `.ts`, `.tsx`, `.mts`, `.cts`, `.js`, `.jsx`, `.mjs`, `.cjs` | `references/typescript.md` |
   | `.html`, `.htm` | `references/html.md` |
   | `Dockerfile`, `Dockerfile.*`, `*.dockerfile`, `compose*.yaml`, `compose*.yml`, `docker-compose*.yaml`, `docker-compose*.yml`, `cloudbuild.yaml`, `.dockerignore`, `.gcloudignore` | `references/docker.md` |
   | anything else (including `.md`, `.sh`, `.tf`, `.yml`, `.yaml`, `.json`, `.toml`, `.ini`, `.cfg`, `.conf`, `.j2`) | none — common checks only |
5. Read and review each file completely.
   Apply common checks. Check for bugs and for security, performance, readability, and maintainability problems.
   Check that the code follows the conventions of the neighboring code.
   Apply the checks from the references.
   Check English comments, docstrings, and prose. If a sentence is hard to read, report it as a nit and suggest a plain rewrite.
   Run the IDE inspections described below. Record the problem count for each file.
   Review notebook code cells as code and Markdown cells as prose.
   Ignore outputs.
   Do not fix anything during this pass.
6. Group findings by file and severity (blocker / major / minor / nit).
   Provide a concrete suggestion and a location for each finding: a line number, or a cell index and line for notebooks.
   Explicitly report when a file has no findings.
7. Present all actionable findings together and ask which fixes to apply. Wait for explicit approval.
8. Apply only approved fixes.
   For notebooks, use a notebook-aware editor when available and change one cell at a time.
   If no notebook-aware editor is available, keep the notebook JSON structure intact and edit cell source only.
9. Run the IDE inspections again on the modified files.
   The problem count must not increase.
   If a fix introduced a new problem, fix that problem in this step. This fix does not need new approval.
   If the new problem is a false positive, keep the code and report the problem. A false positive does not count as an increase.
   Report each modified file, the findings addressed, and the problem count before and after.
   If the inspections are off for a file, write "skipped" in place of the problem count.

## IDE inspections

A problem is an item that the IDE reports. A finding is an item in the review report.

Use the PyCharm MCP tool `lint_files`. Use it for a single file too.
The host may add its own namespace to the tool name.
Pass `projectPath` and project-relative paths, and set `min_severity` to `warning`.
PyCharm inspects Python, TypeScript, JavaScript, HTML, YAML, and JSON.

Check the response for files that PyCharm did not analyze. Do not count these files as free of problems:
- A file has `timedOut: true`, or the response has `more: true`: run the tool again for the remaining files in smaller batches.
  If a file times out again, report it as not analyzed.
- A file has a `notAnalyzedReason`: report the reason.

Merge the problems into the findings:
- `ERROR` → blocker
- `WARNING` → minor
- `WEAK WARNING` → nit

Adjust the severity if the code context requires it, and state the reason.
If the tool is not available, or if a file is outside the project root, report this once. Review the files by reading them directly. Do not stop the run.

Project instructions (AGENTS.md) may turn off IDE inspections for some files.
Skip the inspections for those files. Say so once in the report.
Do not report their IDE problems as findings.

## Rules

- Review first, fix later. Never apply a fix without explicit user approval.
  The only exception is a problem that an approved fix introduced. See step 9.
- Fix the root cause of each problem. Do not add suppression comments (`# noqa`, `# type: ignore`, `// @ts-ignore`, `eslint-disable`, `noinspection`) unless the user asks for them. If the user asks for suppression, state the reason for the suppression in the report.
- If the IDE reports a problem incorrectly, keep the code unchanged. Report the problem as a false positive.
- Preserve the file style unless a finding targets style.
- In notebooks, edit cell source only. Do not change cell types, execution counts, outputs, or metadata.
- If a reference asks for a tool that is not available, report this once and continue the review.
- Report skipped files (binary, credential, excluded, unreadable) explicitly.
- Do not commit changes. Leave changes for the user to review.
