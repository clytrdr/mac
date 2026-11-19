---
name: reviewdocument
description: Check documents against the code that they describe and fix each mismatch. Then rewrite the English text into plain English. Edits the documents without approval.
---

Check that each document matches the code, the files, and the other documents that it describes.
Fix the mismatches in the document. Then rewrite the English text into plain English with the rules of the `plain` skill.
Edit the documents directly. Do not ask for approval before you edit a document.

## Workflow

1. Collect paths from the user request.
   If the user did not provide paths, ask for them and wait for the response.
   If a path does not exist, report it and stop.
2. Expand each directory recursively.
   In a git repository, list the files with `git ls-files --cached --others --exclude-standard -- <directory>`.
   Outside a git repository, list all files.
   Keep document files only: Markdown (`.md`, `.markdown`), HTML (`.html`, `.htm`), reStructuredText (`.rst`), AsciiDoc (`.adoc`), and plain text (`.txt`).
   Skip all other files, such as stylesheets, images, and `.gitkeep`.
   If the user specified a file of another type directly, ask whether to include it.
   Do not open a file whose name shows that it holds credentials, such as `.env`, `*.pem`, `*.key`, or `.vault_pass`.
3. Remove duplicates from the list.
   If the list is empty, report it and stop.
   If the list contains more than 30 files, show the count and ask for confirmation before you start.
4. Do these steps for each document, one document at a time:
   1. Read the full document.
   2. Find and read the code that the document describes.
      If the code is in a repository that is not available, report it and skip the checks for that code.
   3. Do the consistency checks below. Fix the mismatches in the document.
   4. Rewrite the English text into plain English. See "Plain English" below.
5. Check the diff of each document (`git diff -- <file>` in a git repository).
   Make sure that the Markdown and HTML structure is intact and that no fix changed a correct statement.
6. Report the results for each file:
   - The consistency fixes. For each fix, give the location in the document and the code location that it is based on (`path:line`).
   - A short summary of the plain English rewrites.
   - The mismatches that you did not fix, and the reason.
   - The possible bugs in the code, with their locations (`path:line`).
   - The files that you skipped, and the files that had no changes.

## Consistency checks

Usually, the code is correct and the document is out of date. In that case, update the document to match the code.
But the code can be wrong too. If you find a possible bug in the code, report it with its location. Do not fix the code.

Check each statement in the document that the code can confirm or contradict. This includes tables, code examples, and diagrams.
Also check that the document agrees with itself.
Use your own judgment to decide what to check and how to fix it.
Make each fix as small as the mismatch needs.

Do not fix these cases. Report them instead:
- The code looks wrong, and the document seems to describe the intended behavior.
- You cannot decide whether the document or the code is correct.
- The fix needs a decision from the user, such as a change to the scope of the document.

## Plain English

Read `../plain/SKILL.md` from the `reviewdocument` directory.
Apply its style rules, its "Editable Text" table, and its "Constraints" to the English text in the document.
Do not follow its "Workflow" section. The workflow above replaces it.

Exception: do not translate Japanese text. Leave all Japanese text unchanged.

Do the consistency fixes first. Then rewrite the text. This order makes sure that you do not rewrite text that you must replace.

## Rules

- Edit documents only. Never edit source code, tests, or configuration files.
  If the code has a problem, report it.
- Preserve the structure, the formatting, and the style of each document. Change only the text that a fix or a plain English rewrite needs.
- Do not add information that the code or the document does not support.
- Check behavior by reading the code. Do not run commands that change files, databases, or external services.
- Do not commit changes. Leave changes for the user to review.
