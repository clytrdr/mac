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
   These filters apply to expanded directories. Keep a file that the user specified directly, unless it is a binary.
   Do not open a file whose name shows that it holds credentials, such as `.env`, `*.pem`, `*.key`, `.vault_pass`, or a service account key.
   This applies to a file that the user specified directly too. Report the file as skipped.
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
   Apply the simplification checks described below.
   Check that the code follows the conventions of the neighboring code.
   Apply the checks from the references.
   Check English comments, docstrings, and prose. If a sentence is hard to read, report it as a nit and suggest a plain rewrite.
   Review notebook code cells as code and Markdown cells as prose.
   Ignore outputs.
   Do not fix anything during this pass.
6. Group findings by file and severity:
   - **major**: a bug, a security problem, data loss, or a behavior that does not match the intent.
   - **minor**: a readability, maintainability, or performance problem that does not change behavior.
   - **nit**: a small style or wording point. Fixing it is optional.

   In each severity, list the most serious findings first.
   Provide a concrete suggestion and a location for each finding: a line number, or a cell index and line for notebooks.
   Explicitly report when a file has no findings.
7. Present all actionable findings together and ask which fixes to apply. Wait for explicit approval.
8. Apply only approved fixes.
   For notebooks, use a notebook-aware editor when available and change one cell at a time.
   If no notebook-aware editor is available, keep the notebook JSON structure intact and edit cell source only.
   Report each modified file and the findings addressed.

## Simplification checks

In step 5, look for code that you can make simpler without changing its behavior.
Report each case as a minor finding. If the gain is small, report it as a nit.

Look for these problems:
- Deep nesting. Suggest early returns or guard clauses.
- Duplicate or redundant code. Suggest one shared implementation.
- An abstraction that gives no benefit, such as a wrapper that only passes its arguments through.
- Related logic that is split across distant places in the file.
- A name that does not tell what the variable or function does.
- A comment that only repeats what the code says.
- A nested conditional (ternary) expression. Suggest an `if`/`else` chain or a `match`/`switch` statement.
- Dead code: unused imports, unused private functions and variables, and unreachable branches.

Do not suggest a simplification that:
- changes behavior, including outputs, errors, side effects, and public interfaces.
- makes the code shorter but harder to read, such as a dense one-line expression.
- puts too many responsibilities into one function or component.
- removes an abstraction that makes the code easier to organize, test, or extend.
- makes the code harder to debug.

Prefer explicit code to compact code.

## Rules

- Review first, fix later. Never apply a fix without explicit user approval.
- Fix the root cause of each problem. Do not add suppression comments (`# noqa`, `# type: ignore`, `// @ts-ignore`, `eslint-disable`, `noinspection`) unless the user asks for them. If the user asks for suppression, state the reason for the suppression in the report.
- Preserve the file style unless a finding targets style.
- In notebooks, edit cell source only. Do not change cell types, execution counts, outputs, or metadata.
- If a reference file asks you to use a tool that is not available, report this once and continue the review.
- Report skipped files (binary, credential, excluded, unreadable) explicitly.
- Do not commit changes. Leave changes for the user to review.
