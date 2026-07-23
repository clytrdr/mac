# My Ansible Setup for macOS

[![Ansible CI](https://github.com/clytrdr/mac/actions/workflows/ci.yml/badge.svg)](https://github.com/clytrdr/mac/actions/workflows/ci.yml)
[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/clytrdr/mac/main.svg)](https://results.pre-commit.ci/latest/github/clytrdr/mac/main)

**Disclaimer:** The author is not responsible for any damage caused by using this system.

This project uses the "Yes, Takasu Clinic!" and "RIZAP" catchphrases as humorous aliases for user confirmation and commit commands. These references are jokes and do not endorse any views held by Katsuya Takasu. In particular, we strongly condemn his Holocaust denial remarks.

## Overview

Personal Ansible playbooks that automate the setup of a new macOS machine. They install development tools, applications, shell configurations, and AI tools.

## Prerequisites

- A fresh installation of macOS.
- You are logged in with your Apple ID (required for App Store installations).

## Development Guidelines

See [AGENTS.md](AGENTS.md) for role conventions and the development workflow.

## Installation

The `bootstrap.sh` script installs Xcode Command Line Tools, Homebrew, and Ansible, then runs the playbook.

One-line installation (recommended for fresh machines):

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/clytrdr/mac/main/bootstrap.sh)"
```

If you have already cloned the repository:

```shell
chmod +x bootstrap.sh
./bootstrap.sh
```

## Applying Changes

Run the playbook whenever you modify the configuration:

```shell
ansible-playbook localhost.yml --become-password-file .ansible_become_pass --vault-password-file .vault_pass
```

## Managing Secrets

The encrypted file `vars/secrets.yml` is managed with `ansible-vault`. It contains:

- `git_user`: Git username
- `git_mail`: Git email address
- `firecrawl_api_key`: Firecrawl API key for the MCP server

First-time setup:

```shell
echo "your_chosen_vault_password" > .vault_pass
chmod 600 .vault_pass
ansible-vault create vars/secrets.yml --vault-password-file .vault_pass
```

Manage existing secrets:

```shell
ansible-vault view vars/secrets.yml --vault-password-file .vault_pass
ansible-vault edit vars/secrets.yml --vault-password-file .vault_pass
ansible-vault rekey vars/secrets.yml --vault-password-file .vault_pass
```

Never commit `.vault_pass`. The encrypted `vars/secrets.yml` is safe to commit.

## License

This project is licensed under the GNU General Public License v3.0 (GPLv3). See the [LICENSE](LICENSE) file for details.

Copyright (C) 2025 Ishikura Mikiya
