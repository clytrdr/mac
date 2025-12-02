# My Ansible Setup for macOS

[![Ansible CI](https://github.com/clytrdr/mac/actions/workflows/ci.yml/badge.svg)](https://github.com/clytrdr/mac/actions/workflows/ci.yml)

## Disclaimer

**I'm not responsible for any damage caused by using this system.**

## Table of Contents

1. [Disclaimer](#disclaimer)
2. [Overview](#overview)
3. [🚀 Getting Started](#-getting-started)
    - 3.1 [Prerequisites](#prerequisites)
    - 3.2 [Installation](#installation)
4. [🔐 Managing Secrets (vars/secrets.yml)](#-managing-secrets-varssecrets.yml)
    - 4.1 [Setting up secrets for the first time](#setting-up-secrets-for-the-first-time)
    - 4.2 [Managing existing secrets](#managing-existing-secrets)
5. [What does this playbook do?](#what-does-this-playbook-do)

## Overview

This repository contains personal Ansible playbooks to automate the setup and configuration of a new macOS machine. It
handles the installation of development tools, applications, shell configurations, and AI tools like gemini-cli.

## 🚀 Getting Started

Follow these steps to set up a new machine using this playbook.

### Prerequisites

- A fresh installation of macOS.
- You are logged in with your Apple ID (required for App Store installations).
- [Xcode Command Line Tools](https://developer.apple.com/xcode/resources/) are installed. You can install them by
  running:

### Installation

This entire script can be run to bootstrap the machine. It will install Homebrew, clone this repository, and then run
the main Ansible playbook.

```commandline
xcode-select --install

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile

eval "$(/opt/homebrew/bin/brew shellenv)"

brew install ansible

mkdir Code

cd Code

git clone https://github.com/clytrdr/mac.git

cd mac

echo "your_vault_password" > .vault_pass
echo "your_mac_password" > .ansible_become_pass
chmod 600 .ansible_become_pass .vault_pass
```

```commandline
ansible-playbook localhost.yml --become-password-file .ansible_become_pass --vault-password-file .vault_pass
```

```commandline
conda init --all
```

## 🔐 Managing Secrets (vars/secrets.yml)

This project uses `ansible-vault` to securely manage sensitive configuration like Git user information. The encrypted
file `vars/secrets.yml` contains:

- `git_user`: Your Git username
- `git_mail`: Your Git email address
- `gh_mcp_token`: Your GitHub Personal Access Token for the mcp organization

### Setting up secrets for the first time

1. Create the vault password file:

```bash
echo "your_chosen_vault_password" > .vault_pass
chmod 600 .vault_pass
```

2. Create the encrypted secrets file:

```bash
ansible-vault create vars/secrets.yml --vault-password-file .vault_pass
```

3. Add your configuration in the editor that opens:

```yaml
---
git_user: "Your Name"
git_mail: "your.email@example.com"
```

### Managing existing secrets

**View current secrets:**

```bash
ansible-vault view vars/secrets.yml --vault-password-file .vault_pass
```

**Edit secrets:**

```bash
ansible-vault edit vars/secrets.yml --vault-password-file .vault_pass
```

**Change vault password:**

```bash
ansible-vault rekey vars/secrets.yml --vault-password-file .vault_pass
```

**Important Notes:**

- Keep your `.vault_pass` file secure and never commit it to git
- The `vars/secrets.yml` file is encrypted and safe to commit

## License

This project is licensed under the GNU General Public License v3.0 (GPLv3)—see the [LICENSE](LICENSE) file for
details.

Copyright (C) 2025 Ishikura Mikiya
