# My Ansible Setup for macOS

[![Ansible CI](https://github.com/clytrdr/mac/actions/workflows/ci.yml/badge.svg)](https://github.com/clytrdr/mac/actions/workflows/ci.yml)
[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/clytrdr/mac/main.svg)](https://results.pre-commit.ci/latest/github/clytrdr/mac/main)

**Disclaimer:** The author is not responsible for any damage caused by using this system.

This project uses the "Yes, Takasu Clinic!" catchphrase as a humorous alias for user confirmation. These references are jokes and do not endorse any views held by Katsuya Takasu. In particular, we strongly condemn his Holocaust denial remarks.

## Overview

Personal Ansible playbooks that automate the setup of a new macOS machine. They install development tools, applications, shell configurations, and AI tools.

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
./bootstrap.sh
```

## Applying Changes

Run the playbook whenever you modify the configuration:

```shell
ansible-playbook localhost.yml
```

To run only one role, add `--tags <role_name>` (e.g., `--tags git`).

`ansible.cfg` sets the paths of two password files, so the commands in this README need no password flags. `bootstrap.sh` asks for both passwords and creates the files:

- `.vault_pass`: the Ansible Vault password
- `.ansible_become_pass`: the Mac login password, for tasks that use `sudo`

## Managing Secrets

The encrypted file `vars/secrets.yml` is managed with `ansible-vault`. [`vars/secrets.example.yml`](vars/secrets.example.yml) lists its keys with placeholder values.

To start a new vault, copy the example file, set the values, and encrypt the file:

```shell
cp vars/secrets.example.yml vars/secrets.yml
ansible-vault encrypt vars/secrets.yml
```

Manage existing secrets:

```shell
ansible-vault view vars/secrets.yml
ansible-vault edit vars/secrets.yml
ansible-vault rekey vars/secrets.yml
```

`.gitignore` excludes `.vault_pass` and `.ansible_become_pass`, and a pre-commit hook blocks them. Never commit these files. The encrypted `vars/secrets.yml` is safe to commit.

## License

This project is licensed under the GNU General Public License v3.0 (GPLv3). See the [LICENSE](LICENSE) file for details.

Copyright (C) 2025 Ishikura Mikiya
