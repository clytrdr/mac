---
name: dependabot
description: Review and squash-merge open Dependabot pull requests interactively.
allowed-tools: Bash, AskUserQuestion, Read
---

Review and squash-merge open Dependabot pull requests on the current repository.

## Current state

!`git status --porcelain`

!`gh pr list --author "app/dependabot" --limit 100`

## Instructions

1. Check the working directory. If it is not clean (there are uncommitted changes), warn the user and stop. The working directory must be clean because `git pull` and the post-merge steps both change tracked files.
2. If there are no Dependabot PRs, report that and stop.
3. Check the merge status of each open Dependabot PR:
   - Run `gh pr view <number> --json number,title,mergeable,mergeStateStatus` for all PRs.
4. Show the user a summary table with these columns: PR number, title, mergeable, status.
   - Point out major version bumps. Dependabot puts the ecosystem in the branch name, but not the bump type. Read the title (`from X to Y`) to find them.
5. Use AskUserQuestion to ask which PRs to squash-merge:
   - Suggest merging all PRs that are MERGEABLE.
   - Some PRs may have UNSTABLE status. Explain that this can come from CI checks that are not critical. One example is pre-commit.ci on private repos. Ask the user whether to include them.
   - Some PRs may be CONFLICTING. List them and suggest running `@dependabot rebase` in a PR comment.
6. After the user confirms, squash-merge the approved PRs one by one with `gh pr merge <number> --squash`.
   - `gh pr merge` prints nothing on success. Do not assume it worked. After the merges, check every PR with `gh pr view <number> --json number,state`. Use that output as the source of truth.
   - A merge can fail because of a conflict. This happens when an earlier merge changes the base branch and the PR becomes CONFLICTING. In that case, run `gh pr comment <number> --body "@dependabot rebase"` to comment on the PR, and tell the user.
7. Show a results table: PR number, title, result (merged / conflict-rebasing / failed).
8. If at least one PR was merged, ask the user whether to run `git pull` to get the latest changes. If yes, run it. Do not wait for every PR to succeed. The merged ones still need pulling.
9. After `git pull` succeeds, find out which ecosystems were merged. Read them from the Dependabot branch names: `dependabot/<ecosystem>/...`. Then read the matching reference file and follow it.

   | Ecosystem        | Reference file            |
   | ---------------- | ------------------------- |
   | `pip`            | `references/python.md`    |
   | `npm_and_yarn`   | `references/npm.md`       |
   | `terraform`      | `references/terraform.md` |
   | `github_actions` | none; no local refresh    |

   Read only the files you need. Handle one ecosystem at a time. Ask the user before you run each command. Some commands are slow.

10. Each reference file lists the files it may change. If any of them changed, show `git status --porcelain` and `git diff --stat`. Then ask the user whether to commit. Do not commit without an explicit yes.
11. Report the final status: PRs merged, commands run, check results, and any problem that is still open.

## Rules

- Only process PRs authored by `app/dependabot`.
- Always use `--squash` for merging.
- Never force-merge or bypass branch protection.
- Never run a command that changes remote infrastructure or deploys. The refresh and check steps are local only.
- Do not push unless the user asks.
- If the `gh` CLI is not authenticated, tell the user to run `gh auth login` and stop.
- The job is not done when the PRs are merged. A lockfile can still hold known vulnerabilities after every PR is merged. Follow the reference file to the end.
