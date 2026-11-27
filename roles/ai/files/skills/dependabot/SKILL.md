---
name: dependabot
description: Review and squash-merge open Dependabot pull requests, then refresh and check the local environment.
---

Review and squash-merge open Dependabot pull requests (PRs) in the current repository.
Then refresh the local environment and run the checks.

Ask the user for approval at two points only:

1. Before the merge: which PRs to squash-merge.
2. Before a commit: only if the local refresh changed tracked files.

Run all other steps without asking. Those steps are local and safe to repeat.
Report the results at the end.

## Instructions

1. Run `git status --porcelain`. If the working directory is not clean, warn the user and stop.
   `git pull` and the refresh steps change files. The working directory must be clean.
2. Get all open Dependabot PRs with one command:

   ```
   gh pr list --author "app/dependabot" --limit 100 --json number,title,headRefName,mergeable,mergeStateStatus
   ```

   If the list is empty, report this and stop.
   GitHub calculates `mergeable` in the background. If a PR shows `UNKNOWN`,
   run `gh pr view <number> --json number,mergeable,mergeStateStatus` for that PR only.
3. Show a summary table with these columns: PR number, title, ecosystem, mergeable, status.
   - Get the ecosystem from the branch name: `dependabot/<ecosystem>/...`.
   - Note major version updates. Check the title (`from X to Y`) to find them.
     For `0.x` versions, a minor version update can also have breaking changes. Note those updates too.
4. **Approval 1.** Ask which PRs to squash-merge. Wait for explicit approval.
   Ask for all decisions in this one question:
   - Suggest merging all MERGEABLE and CLEAN PRs.
   - UNSTABLE PRs: non-critical or flaky CI checks can cause this status. Ask in the same question
     whether to include these PRs.
   - CONFLICTING PRs: tell the user that you will comment `@dependabot rebase` on these PRs.
     This comment does not need separate approval.
5. Squash-merge the approved PRs one by one with `gh pr merge <number> --squash`.
   - Merge PRs for `github_actions` and `pre_commit` first. They rarely conflict.
     Then merge the other PRs.
   - `gh pr merge` prints no output on success. Do not assume that the merge succeeded.
     After the merges, check every PR with `gh pr view <number> --json number,state`.
     Use only that output to confirm whether each merge succeeded.
   - A merge can fail with a conflict. An earlier merge can change the base branch and make
     the PR CONFLICTING. If a merge fails with a conflict, run `gh pr comment <number> --body "@dependabot rebase"` on that PR.
     Also run this command on the PRs that were CONFLICTING in step 2.
6. If you merged at least one PR, run `git pull` without asking.
   Do not wait for the rebased PRs. Pull the changes from the merged PRs.
7. Find the ecosystems of the merged PRs. Read each matching reference file and run its steps
   without asking for each command.

   | Ecosystem        | Reference file                          |
   | ---------------- | --------------------------------------- |
   | `pip`            | `references/python.md`                  |
   | `npm_and_yarn`   | `references/npm.md`                     |
   | `terraform`      | `references/terraform.md`               |
   | `github_actions` | none; no local refresh                  |
   | `pre_commit`     | none; run `pre-commit run --all-files`  |

   Read only the files you need. Run the pre-commit check after the other ecosystems.
   If a command fails, do not stop the other ecosystems. Record the failure and report it.
8. **Approval 2.** Run `git status --porcelain`. If tracked files changed, show
   `git diff --stat` and ask whether to commit. Do not commit without explicit approval.
   If the working directory is clean, report this and do not ask.
9. Report the final status in one message:
   - A results table: PR number, title, result (merged / conflict-rebasing / failed).
   - A table of the commands you ran and their results.
   - Open issues, such as PRs waiting for a rebase and remaining vulnerabilities.
   - Steps you skipped on purpose, such as `docker compose build`.

## Rules

- Process only PRs with author `app/dependabot`.
- Always use `--squash` to merge PRs.
- Do not force-merge or bypass branch protection.
- Do not run a command that changes remote infrastructure or deploys. Refresh and check steps are local only.
- Do not run `docker compose build`. It is slow. If the project has a compose file that installs
  the changed dependencies, tell the user in the final report that the image is out of date.
  Run `docker compose build` only when the user asks.
- Do not push unless the user asks.
- If the `gh` CLI is not authenticated, tell the user to run `gh auth login` and stop.
- The task does not end when you merge the PRs. A lockfile can still have known vulnerabilities after you merge every PR. Follow the reference file to the end.
