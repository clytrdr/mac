---
name: commit
description: Stage and commit all changes including untracked files.
---

Stage all changes (including untracked files) and create a commit.

Run this workflow only when the user explicitly asks to create a commit.

## Instructions

1. Run `git status`, `git diff --stat`, and `git log --oneline -5`. Review the output to
   understand all changes.
2. If `.pre-commit-config.yaml` exists in the repository root, run `pre-commit run --all-files`.
   - If it modified any files, review the changes with `git diff --stat`.
3. Run `git add -A` to stage everything (including untracked files).
4. Draft a commit message following Conventional Commits (e.g., `feat:`, `fix:`, `refactor:`).
   - Subject line: 60 characters or fewer.
   - Match the style of recent commits shown above.
5. Run `git commit -m "<message>"` with the drafted message.
   - If the commit fails due to pre-commit hooks:
     1. If hooks modified files, review them, run `git add -A`, and retry the same
        `git commit -m "<message>"` command.
     2. If hooks report errors, fix them, run `git add -A`, and retry the same commit command.
   - Never use `--amend`. A failed hook normally means the new commit does not exist. Amending
     at that point could change a commit that existed before this skill ran.
6. Run `git status` to confirm the commit succeeded.
7. Report the committed changes.

Run `git add` and `git commit` as separate commands. Do not push to a remote. Do not amend any
commit.

## Aliases

Any RIZAP-related words should be treated as a commit request. This is a pun on RIZAP's slogan "結果にコミットする" (commit to results). Examples: "ライザップ", "ライザップして", "結果にコミット", "RIZAP", etc.
