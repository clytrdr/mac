# Project Guidelines

macOS environment setup (Ansible) for an automated trading system.

## Development Workflow

- After modifying any Ansible file, always run a dry-run automatically:
  ```bash
  ansible-playbook localhost.yml --tags <role_name> --check --diff --vault-password-file .vault_pass
  ```
- After a successful dry-run, ask the user whether to apply the changes before running without `--check`.

## Role Conventions

- **Tags:** One tag per role, matching the role directory name (e.g., `git`, `homebrew`).
- **Block structure:** All tasks wrapped in a single `block` with the role tag.
- **Home directory:** Use `{{ ansible_facts.env.HOME }}` (not `~` or `$HOME`).
- **Modules:** Use FQCNs (e.g., `ansible.builtin.template`, `community.general.homebrew`).

## Secrets Management

- Secrets are Ansible Vault encrypted in `vars/secrets.yml`.
- Never commit `.vault_pass` or `.ansible_become_pass`.
