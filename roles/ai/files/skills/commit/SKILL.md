---
name: commit
description: Stage and commit all changes including untracked files.
---

Run this workflow only when the user explicitly asks to create a commit.

## Instructions

1. Run `git status --short`, `git diff --stat`, and `git log --oneline -5`. From the
   `git diff --stat` output, select the files whose content you need to see to understand the
   change. Run `git diff -- <file>...` for those files only. Skip lockfiles and generated files.
2. Check the `git status` output from step 1 for secret files or unintended untracked files.
   If any exist, stop and ask the user before staging.
3. Run `git add -A`.
4. If `.pre-commit-config.yaml` exists in the repository root, run `pre-commit run`. It checks
   only the staged files.
   - If the hooks modified files, review the changes with `git diff --stat`.
   - If the hooks report errors, fix them.
   - In both cases, run `git add -A` and run `pre-commit run` again until it passes.
5. Draft a commit message that follows the commit message rules in the global instructions.
   Match the style of the recent commits from step 1.
6. Run `git commit -m "<message>"`.
   - If pre-commit hooks fail, review the files they modified and fix the errors they report.
     Then run `git add -A` and retry the same `git commit -m "<message>"` command.
   - Never use `--amend`. A failed hook normally means the new commit does not exist. Amending
     at that point could change a commit that existed before this skill ran.
7. Run `git status` to confirm the commit succeeded.
8. Report the committed changes.

Run `git add` and `git commit` as separate commands. Do not push to a remote.
