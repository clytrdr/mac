---
name: commit
description: Stage and commit all changes including untracked files.
disable-model-invocation: true
allowed-tools: Bash
---

Stage all changes (including untracked files) and create a commit.

## Current state

!`git status`

!`git diff --stat`

!`git log --oneline -5`

## Instructions

1. Review the git status and diff output above to understand all changes.
2. If `.pre-commit-config.yaml` exists in the repository root, run `pre-commit run --all-files`.
   - If it modified any files, review the changes with `git diff --stat`.
3. Run `git add -A` to stage everything (including untracked files).
4. Draft a commit message following Conventional Commits (e.g., `feat:`, `fix:`, `refactor:`).
   - Subject line: 60 characters or fewer.
   - Match the style of recent commits shown above.
5. Run `git commit -m "<message>"` with the drafted message.
   - If the commit fails due to pre-commit hooks:
     1. If hooks only modified files, run `git add -A` and run `git commit --amend --no-edit`.
     2. If hooks report errors that persist after re-staging, fix the issues yourself, run `git add -A`, and run `git commit --amend --no-edit`.
   - Use `--amend` only when the change is clearly part of the previous commit (e.g., pre-commit fixes, typos, minor oversights). Otherwise, create a new commit.
6. Run `git status` to confirm the commit succeeded.
7. Report the committed changes.

Do not push to a remote. Do not amend existing commits.
