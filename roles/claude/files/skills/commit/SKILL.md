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
2. Run `git add -A` to stage everything (including untracked files).
3. Draft a commit message following Conventional Commits (e.g., `feat:`, `fix:`, `refactor:`).
   - Subject line: 60 characters or fewer.
   - Match the style of recent commits shown above.
4. Run `git commit -m "<message>"` with the drafted message.
   - Append a blank line and `Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>` to the message.
5. Run `git status` to confirm the commit succeeded.
6. Report the committed changes.

Do not push to a remote. Do not amend existing commits.
