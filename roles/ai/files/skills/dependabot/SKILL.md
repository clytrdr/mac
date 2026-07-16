---
name: dependabot
description: Review and squash-merge open Dependabot pull requests interactively.
allowed-tools: Bash, AskUserQuestion
---

Review and squash-merge open Dependabot pull requests on the current repository.

## Current state

!`git status --porcelain`

!`gh pr list --author "app/dependabot" --limit 100`

## Instructions

1. If the working directory is not clean (uncommitted changes exist), warn the user and stop. A clean working directory is required because `git pull` at the end may cause conflicts.
2. If no Dependabot PRs are found, report that and stop.
3. For each open Dependabot PR, check merge status:
   - Run `gh pr view <number> --json number,title,mergeable,mergeStateStatus` for all PRs.
4. Present a summary table to the user with columns: PR number, title, mergeable, status.
5. Use AskUserQuestion to ask the user which PRs to squash-merge:
   - Suggest merging all PRs that are MERGEABLE.
   - If some PRs have UNSTABLE status, explain it may be due to non-critical CI checks (e.g., pre-commit.ci on private repos) and ask if they should be included.
   - If any PRs are CONFLICTING, note them and suggest running `@dependabot rebase` via a PR comment.
6. Upon confirmation, squash-merge the approved PRs one by one using `gh pr merge <number> --squash`.
   - If a merge fails due to conflict (the PR became CONFLICTING after earlier merges changed the base branch), comment `@dependabot rebase` on the PR using `gh pr comment <number> --body "@dependabot rebase"` and inform the user.
7. After all merges are attempted, show a results summary table: PR number, title, result (merged / conflict-rebasing / failed).
8. If all PRs were merged successfully, ask the user whether to `git pull` the latest changes. If yes, run it.
9. After a successful `git pull`, determine which refresh commands are needed based on the ecosystems of the merged PRs (parsed from Dependabot branch names: `dependabot/<ecosystem>/...`):

   - `pip`            → Python (uv)
   - `npm_and_yarn`   → Node (npm)
   - `terraform`      → Terraform
   - `github_actions` → no local refresh needed

   For each ecosystem with at least one merged PR, ask the user (one prompt per ecosystem) whether to run the refresh commands:

   - **Python (uv)**:
     - `uv pip install -r requirements.txt -r requirements-dev.txt`
       (omit `-r requirements-dev.txt` if that file does not exist)
     - If `docker-compose.yml` or `compose.yml` exists, also ask separately whether to run `docker compose build` (slow; user may skip).
   - **Node (npm)**: `npm ci`
   - **Terraform**: `terraform init -upgrade`
     (note: this may modify `.terraform.lock.hcl`)

10. Report the final status, including which refresh commands were executed.

## Rules

- Only process PRs authored by `app/dependabot`.
- Always use `--squash` for merging.
- Never force-merge or bypass branch protection.
- If `gh` CLI is not authenticated, instruct the user to run `gh auth login` and stop.
