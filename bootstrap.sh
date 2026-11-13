#!/bin/bash
set -euo pipefail # Stop on error, undefined variable, or pipe failure

# Color definitions
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting macOS Setup...${NC}"

# 1. Check and Install Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Complete the Xcode installation dialog. Setup continues when the installation finishes."
    echo "Press Ctrl-C to stop."
    until xcode-select -p &>/dev/null; do
        sleep 5
    done
else
    echo "Xcode Command Line Tools already installed."
fi

# 2. Install Homebrew
# Load Homebrew into this shell and set HOMEBREW_BIN to the path of brew.
# Return 1 if Homebrew is not installed.
# Check both install locations: Apple Silicon first, then Intel.
# Do not rely on PATH. A new install is not on the PATH of the calling terminal.
load_homebrew() {
    local prefix
    for prefix in /opt/homebrew /usr/local; do
        if [ -x "$prefix/bin/brew" ]; then
            HOMEBREW_BIN="$prefix/bin/brew"
            eval "$("$HOMEBREW_BIN" shellenv)"
            return 0
        fi
    done
    return 1
}

if command -v brew &>/dev/null || load_homebrew; then
    echo "Homebrew already installed."
else
    echo "Installing Homebrew..."
    # Download the installer first. A failed download then stops the script here.
    HOMEBREW_INSTALLER="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    /bin/bash -c "$HOMEBREW_INSTALLER"

    if ! load_homebrew; then
        echo "Homebrew was not found after the installation." >&2
        exit 1
    fi
    # Append to .zprofile if not already present
    if ! grep -qF "$HOMEBREW_BIN shellenv" ~/.zprofile 2>/dev/null; then
        printf 'eval "$(%s shellenv)"\n' "$HOMEBREW_BIN" >> ~/.zprofile
    fi
fi

# 3. Install Ansible
if brew list ansible &>/dev/null; then
    echo "Ansible already installed."
else
    echo "Installing Ansible..."
    brew install ansible
fi

# 4. Clone Repository
# Use the directory of this script if it is a clone of the repository.
# BASH_SOURCE is empty when the script runs through `bash -c` or a pipe.
SCRIPT_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/localhost.yml" ]; then
    TARGET_DIR="$SCRIPT_DIR"
    echo "Using the repository at $TARGET_DIR"
else
    TARGET_DIR="$HOME/Code/mac"
    if [ ! -d "$TARGET_DIR/.git" ]; then
        echo "Cloning repository..."
        mkdir -p "$HOME/Code"
        git clone https://github.com/clytrdr/mac.git "$TARGET_DIR"
    else
        echo "Repository already exists at $TARGET_DIR"
    fi
fi

cd "$TARGET_DIR"

# 5. Setup Passwords (Interactive)
# Usage: prompt_password <message>
# Read a non-empty password from the terminal into the variable PASSWORD.
prompt_password() {
    while true; do
        echo -e "${GREEN}$1${NC}"
        # IFS= keeps leading and trailing spaces in the password.
        IFS= read -rs PASSWORD < /dev/tty
        echo
        [ -n "$PASSWORD" ] && return 0
        echo "Password must not be empty. Try again."
    done
}

if [ ! -f .vault_pass ]; then
    while true; do
        prompt_password "Enter your Ansible Vault Password:"
        (umask 077; printf '%s\n' "$PASSWORD" > .vault_pass)
        # Check the password against the encrypted file before keeping it.
        # Discard stdout, because it holds the decrypted secrets.
        if [ ! -f vars/secrets.yml ] ||
            ansible-vault view vars/secrets.yml --vault-password-file .vault_pass >/dev/null; then
            break
        fi
        rm -f .vault_pass
        echo "Vault password check failed. Try again."
    done
    echo "Vault password saved."
fi

if [ ! -f .ansible_become_pass ]; then
    while true; do
        prompt_password "Enter your Mac Login Password (for sudo):"
        # Drop the cached sudo credentials, so that sudo checks this password.
        sudo -k
        if printf '%s\n' "$PASSWORD" | sudo -S -p '' -v; then
            break
        fi
        echo "Sudo password check failed. Try again."
    done
    (umask 077; printf '%s\n' "$PASSWORD" > .ansible_become_pass)
    echo "Sudo password saved."
fi
unset PASSWORD

# 6. Run Playbook
echo "Running Ansible Playbook..."
ansible-playbook localhost.yml --become-password-file .ansible_become_pass --vault-password-file .vault_pass

echo -e "${GREEN}Setup Complete! Please restart your terminal.${NC}"
