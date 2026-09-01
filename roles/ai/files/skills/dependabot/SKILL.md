---
name: dependabot
description: Review and squash-merge open Dependabot pull requests interactively.
---

Review and squash-merge open Dependabot pull requests in the current repository.

Reviewing PRs does not approve them for merge. Merge only the PRs that the user explicitly approves in this run.

## Instructions

1. Run `git status --porcelain`. If the working directory is not clean, warn the user and stop.
   The working directory must be clean. `git pull` and the post-merge steps change files.
2. Run `gh pr list --author "app/dependabot" --limit 100`. If there are no Dependabot PRs,
   report that and stop.
3. Check the merge status of each open Dependabot PR:
   - Run `gh pr view <number> --json number,title,mergeable,mergeStateStatus` for all PRs.
4. Show the user a summary table with these columns: PR number, title, mergeable, status.
   - Point out major version bumps. Dependabot puts the ecosystem in the branch name, but not the bump type. Read the title (`from X to Y`) to find them.
5. Ask which PRs to squash-merge and wait for explicit approval:
   - Suggest merging all PRs that are MERGEABLE.
   - Some PRs may have UNSTABLE status. Explain that non-critical CI checks can cause this status. One example is pre-commit.ci on private repositories. Ask the user whether to include them.
   - Some PRs may have CONFLICTING status. List them and suggest running `@dependabot rebase` in a PR comment.
6. After the user confirms, squash-merge the approved PRs one by one with `gh pr merge <number> --squash`.
   - `gh pr merge` prints nothing on success. Do not assume it worked. After the merges, check every PR with `gh pr view <number> --json number,state`. Use that output as the source of truth.
   - A merge can fail because of a conflict. This happens when an earlier merge changes the base branch and the PR becomes CONFLICTING. In that case, run `gh pr comment <number> --body "@dependabot rebase"` to comment on the PR, and tell the user.
7. Show a results table with these columns: PR number, title, result (merged / conflict-rebasing / failed).
8. If at least one PR was merged, ask the user whether to run `git pull` to get the latest changes. If the user agrees, run it. Do not wait for every PR to succeed. Pull changes for the merged PRs.
9. After `git pull` succeeds, check which ecosystems were merged. Read them from the Dependabot branch names: `dependabot/<ecosystem>/...`. Then read the matching reference file and follow its steps.

   | Ecosystem        | Reference file            |
   | ---------------- | ------------------------- |
   | `pip`            | `references/python.md`    |
   | `npm_and_yarn`   | `references/npm.md`       |
   | `terraform`      | `references/terraform.md` |
   | `github_actions` | none; no local refresh    |

   Read only the files you need. Handle one ecosystem at a time. Ask the user before you run each command. Some commands are slow.

10. Each reference file lists the files it may change. If any of them changed, show `git status --porcelain` and `git diff --stat`. Then ask the user whether to commit. Do not commit without explicit approval.
11. Report the final status: merged PRs, commands run, check results, and any open issues.

## Rules

- Process only PRs authored by `app/dependabot`.
- Always use `--squash` for merging.
- Never force-merge or bypass branch protection.
- Never run a command that changes remote infrastructure or deploys. Refresh and check steps are local only.
- Do not push unless the user asks.
- If the `gh` CLI is not authenticated, tell the user to run `gh auth login` and stop.
- The job is not done when PRs are merged. A lockfile can still hold known vulnerabilities after every PR is merged. Follow the reference file to the end.
