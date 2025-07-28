# My Ansible Setup for macOS

[![Ansible CI](https://github.com/clytrdr/mac/actions/workflows/ansible-ci.yml/badge.svg)](https://github.com/clytrdr/mac/actions/workflows/ansible-ci.yml)

This repository contains personal Ansible playbooks to automate the setup and configuration of a new macOS machine. It
handles the installation of tools, applications, and shell configurations.

## 🚀 Getting Started

Follow these steps to set up a new machine using this playbook.

### 1. Prerequisites

- A fresh installation of macOS.
- You are logged in with your Apple ID (required for App Store installations).
- [Xcode Command Line Tools](https://developer.apple.com/xcode/resources/) are installed. You can install them by
  running:

### 2. Installation

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

ansible-playbook -i inventory/localhost localhost.yml --ask-become-pass

conda init --all
```

---

### What does this playbook do?

This playbook is configured in `localhost.yml` and automates the following:

- **Zsh:** Configures the Zsh shell environment.
- **Homebrew:** Installs packages and casks (GUI applications).
- **Git:** Sets up global Git configuration with the user and email you provide.
