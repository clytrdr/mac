# Project Guidelines

This repository uses Ansible to set up macOS.

## Development Workflow

- After modifying any Ansible file, always run a dry-run automatically:
  ```bash
  ansible-playbook localhost.yml --tags <role_name> --check --diff
  ```
  `ansible.cfg` sets both password files, so the command needs no password flags.
- Pick the tags from the files that you changed:
  - A file in `roles/<role_name>/`: `--tags <role_name>`.
  - `vars/secrets.yml`: `--tags git,ai`. Only these roles use the secrets.
  - `localhost.yml` or `ansible.cfg`: run `--syntax-check` first. Then do a dry-run for each role that the change affects.
  - `requirements.yml`: no playbook run. Only ansible-lint reads this file.
- After a successful dry-run, ask the user whether to apply the changes before running without `--check`.

## Role Conventions

- **Tags:** `localhost.yml` gives each role one tag that matches the role directory name (e.g., `git`, `homebrew`). Do not add tags in the role files.
- **Blocks:** Use a `block` only when a group of tasks needs shared keys, such as `environment`.
- **Home directory:** Use `{{ ansible_facts.env.HOME }}` (not `~` or `$HOME`). A pre-commit hook checks this.
- **Modules:** Use FQCNs (e.g., `ansible.builtin.template`, `community.general.homebrew`). ansible-lint checks this.

## Secrets Management

- Secrets are Ansible Vault encrypted in `vars/secrets.yml`. A pre-commit hook checks that the file is encrypted.
- `vars/secrets.example.yml` lists the keys. When a role uses a new vault variable, add the key there.
- Never commit `.vault_pass` or `.ansible_become_pass`. `.gitignore` excludes them, and a pre-commit hook blocks them.
