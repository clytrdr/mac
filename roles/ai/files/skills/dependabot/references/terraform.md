# Post-merge refresh: terraform

Run these steps in order. Do not ask the user before each step. These steps do not change real infrastructure.

Check `.github/dependabot.yml` or the merged PR files for the Terraform directory.
If the directory is not `/`, pass `-chdir=<dir>` to every `terraform` command (for example, `terraform -chdir=terraform plan`).

## 1. Upgrade providers

```
terraform init -upgrade
```

This command reads the provider versions from the merged `.tf` files. It then rewrites the lock file.

## 2. Check

```
terraform fmt -check
terraform validate
terraform plan
```

If `terraform plan` fails because credentials are missing or expired, do not try to log in. Record the failure and tell the user in the final report.

If the plan is not empty, read `AGENTS.md` first. Some repositories keep runtime resources paused. A paused state creates an expected diff.
If the diff comes from the provider update, check the provider changelog. Report the exact resources and the likely cause, then stop. Do not try to remove the diff.

## 3. Do not apply

Do not run `terraform apply`, `terraform destroy`, or any command that changes real infrastructure. This skill only updates and checks. The user decides whether to apply changes. The user applies them in a separate session.

Do not print the contents of `terraform.tfvars`, `terraform.tfstate`, or service account key files. These files contain secrets.

## 4. Files that may change

- `.terraform.lock.hcl` (or `<dir>/.terraform.lock.hcl`) — `terraform init -upgrade` changes this file

Do not commit `.terraform/`, state files, or `terraform.tfvars`.
