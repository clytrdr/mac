# My Ansible Setup for macOS

[![Ansible CI](https://github.com/clytrdr/mac/actions/workflows/ansible-ci.yml/badge.svg)](https://github.com/clytrdr/mac/actions/workflows/ansible-ci.yml)

This repository contains my personal Ansible playbooks for setting up a new macOS machine.

## Usage

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

ansible-playbook -i inventory/localhost localhost.yml --ask-become-pass --ask-vault-pass

conda init --all
```

## Note

Delete Pycharm data

```commandline
find ~/Library -iname "*pycharm*" -exec rm -r "{}" \;
```

Decrypt secret file

```commandline
ansible-vault decrypt roles/git/vars/main.yml
```

Encrypt secret file

```commandline
ansible-vault encrypt roles/git/vars/main.yml
```
