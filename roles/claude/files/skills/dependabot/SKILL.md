---
name: dependabot
description: Review and squash-merge open Dependabot pull requests interactively.
allowed-tools: Bash, AskUserQuestion
---

Review and squash-merge open Dependabot pull requests on the current repository.

## Current state

!`gh pr list --author "app/dependabot"`

## Instructions

1. If no Dependabot PRs are found, report that and stop.
2. For each open Dependabot PR, check merge status:
   - Run `gh pr view <number> --json number,title,mergeable,mergeStateStatus` for all PRs.
3. Present a summary table to the user with columns: PR number, title, mergeable, status.
4. Use AskUserQuestion to ask the user which PRs to squash-merge:
   - Suggest merging all PRs that are MERGEABLE.
   - If some PRs have UNSTABLE status, explain it may be due to non-critical CI checks (e.g., pre-commit.ci on private repos) and ask if they should be included.
   - If any PRs are CONFLICTING, note them and suggest running `@dependabot rebase` via a PR comment.
5. Upon confirmation, squash-merge the approved PRs one by one using `gh pr merge <number> --squash`.
   - If a merge fails due to conflict (the PR became CONFLICTING after earlier merges changed the base branch), comment `@dependabot rebase` on the PR using `gh pr comment <number> --body "@dependabot rebase"` and inform the user.
6. After all merges are attempted, show a results summary table: PR number, title, result (merged / conflict-rebasing / failed).
7. If all PRs were merged successfully, ask the user if they want to pull the latest changes to the local repository.
   - If yes, run `git pull`.
8. Report the final status.

## Rules

- Only process PRs authored by `app/dependabot`.
- Always use `--squash` for merging.
- Never force-merge or bypass branch protection.
- If `gh` CLI is not authenticated, instruct the user to run `gh auth login` and stop.
