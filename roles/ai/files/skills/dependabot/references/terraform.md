# Post-merge refresh: terraform

Run these in order. Ask the user before each step.

## 1. Upgrade providers

```
terraform init -upgrade
```

This reads the provider versions from the merged `.tf` files and rewrites the lock file.

## 2. Verify

```
terraform fmt -check
terraform validate
terraform plan
```

`terraform plan` reads the real cloud state, so it needs credentials. It does not change anything.

Read the plan output. An empty plan is the expected result of a provider bump. The plan may show resource changes that nobody asked for. That means a provider changed its schema or its default values. Report the exact resources and stop. Do not try to make the diff go away.

A provider major version bump needs more care than a patch bump. Check the provider changelog when the plan is not empty.

## 3. Never apply

Do not run `terraform apply`, `terraform destroy`, or any command that changes real infrastructure. This skill only updates and checks. Applying is the user's decision, and it happens in a separate session.

Do not print the contents of `terraform.tfvars`, `terraform.tfstate`, or service account key files. They hold secrets.

## 4. Files that may change

- `.terraform.lock.hcl` — changed by `terraform init -upgrade`

Do not commit `.terraform/`, state files, or `terraform.tfvars`.
