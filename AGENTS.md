# Project Guidelines

macOS environment setup (Ansible) for an automated trading system.

## Language

- Communicate with the user in Japanese.
- Write all code comments in English.

## Development Workflow

- Always dry-run before applying changes:
  ```bash
  ansible-playbook localhost.yml --tags <role_name> --check --diff --vault-password-file .vault_pass
  ```

## Role Conventions

- **Tags:** One tag per role, matching the role directory name (e.g., `git`, `homebrew`).
- **Block structure:** All tasks wrapped in a single `block` with the role tag.
- **Home directory:** Use `{{ ansible_facts.env.HOME }}` (not `~` or `$HOME`).
- **Modules:** Use FQCNs (e.g., `ansible.builtin.template`, `community.general.homebrew`).

## Secrets Management

- Secrets are Ansible Vault encrypted in `vars/secrets.yml`.
- Never commit `.vault_pass` or `.ansible_become_pass`.

## Git Commit Messages

- Follow [Conventional Commits](https://www.conventionalcommits.org/) (e.g., `feat:`, `fix:`).
- Subject line: 60 characters or fewer. Omit body unless necessary.
