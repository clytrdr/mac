# Project Context

> For general project information, setup instructions, and usage details, see [README.md](README.md).

## Primary Goal

The user's primary goal is to develop a Python-based system for machine-learning-driven multi-asset trading (including cryptocurrencies, forex, stocks, and other financial instruments).

## Infrastructure

- **Cloud Provider:** Google Cloud Platform (GCP)
- **Infrastructure as Code (IaC):** Terraform is used for managing the cloud infrastructure.

## Repository Structure

~~~
├── localhost.yml          # Main playbook
├── ansible.cfg            # Ansible configuration
├── bootstrap.sh           # One-line setup script for fresh machines
├── inventory/localhost     # Inventory file
├── vars/secrets.yml       # Ansible Vault encrypted secrets
├── roles/
│   ├── git/               # Git configuration & global gitignore
│   ├── homebrew/          # Homebrew packages & casks
│   ├── zsh/               # Zsh shell & zinit plugins
│   ├── gemini/            # Google Gemini CLI & MCP servers
│   ├── claude/            # Claude Code CLI & MCP servers
│   └── node/              # Node.js (n version manager) & npm packages
└── .github/workflows/ci.yml  # Lint + syntax check + dry-run
~~~

## Development Workflow

### Running the Playbook

See [README.md](README.md) for full usage. **Always dry-run before applying changes:**

```bash
ansible-playbook localhost.yml --tags <role_name> --check --diff --vault-password-file .vault_pass
```

### CI Pipeline

- **Pre-commit hooks** run on every commit via `pre-commit`.
- **GitHub Actions** (`ci.yml`) runs on push/PR to `main`:
  1. `lint` job: pre-commit hooks on ubuntu-latest
  2. `test-playbook` job: syntax check + dry-run on macos-latest

## Role Development Patterns

Each role follows a consistent structure:

~~~
roles/<role_name>/
├── tasks/main.yml          # Required: all tasks in a block with tag matching role name
├── templates/*.j2           # Optional: Jinja2 templates
├── files/*                  # Optional: static files
└── vars/main.yml            # Optional: role-specific variables
~~~

### Conventions

- **Tags:** One tag per role, matching the role directory name (e.g., `git`, `homebrew`).
- **Block structure:** All tasks wrapped in a single `block` with the role tag.
- **Home directory:** Use `{{ ansible_facts.env.HOME }}` (not `~` or `$HOME`).
- **Modules:** Use FQCNs (e.g., `ansible.builtin.template`, `community.general.homebrew`).

## Secrets Management

Encrypted variables in `vars/secrets.yml` (loaded via `pre_tasks`). See [README.md](README.md) for vault CLI commands.

| Variable | Purpose |
|----------|---------|
| `git_user` | Git username |
| `git_mail` | Git email address |

**Never commit:** `.vault_pass`, `.ansible_become_pass`

## Guidelines for AI Agents

1. **Context Awareness:**
   - The local environment setup is designed to support Python development, specifically for data science and machine learning tasks.
   - Integration with Google Cloud Platform (GCP) and Terraform is essential.

2. **Tooling & Configuration:**
   - Ensure that the Ansible roles properly configure essential tools such as the Google Cloud CLI (`gcloud`), Terraform, and Python environment management tools.
   - Adhere to the existing structure and patterns found in the `roles/` and `vars/` directories.

3. **Development Focus:**
   - Prioritize configurations that enhance the workflow for machine learning and algorithmic trading development.

4. **Testing:**
   - Always validate changes with `--check --diff` before applying.
   - Ensure changes pass `ansible-lint` and the existing pre-commit hooks.
