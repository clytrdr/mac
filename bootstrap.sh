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
    echo "Please complete the Xcode installation dialog, then press Enter to continue."
    read -r < /dev/tty
else
    echo "Xcode Command Line Tools already installed."
fi

# 2. Install Homebrew
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Apple Silicon (M1/M2/M3) path configuration
    if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        # Append to .zprofile if not already present
        if ! grep -q "/opt/homebrew/bin/brew shellenv" ~/.zprofile 2>/dev/null; then
             echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        fi
    # Intel path configuration
    elif [ -f "/usr/local/bin/brew" ]; then
        eval "$(/usr/local/bin/brew shellenv)"
        # Append to .zprofile if not already present
        if ! grep -q "/usr/local/bin/brew shellenv" ~/.zprofile 2>/dev/null; then
             echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
        fi
    fi
else
    echo "Homebrew already installed."
fi

# 3. Install Ansible
if brew list ansible &>/dev/null; then
    echo "Ansible already installed."
else
    echo "Installing Ansible..."
    brew install ansible
fi

# 4. Clone Repository
TARGET_DIR="$HOME/Code/mac"
if [ ! -d "$TARGET_DIR" ]; then
    echo "Cloning repository..."
    mkdir -p "$HOME/Code"
    git clone https://github.com/clytrdr/mac.git "$TARGET_DIR"
else
    echo "Repository already exists at $TARGET_DIR"
fi

cd "$TARGET_DIR"

# 5. Setup Passwords (Interactive)
if [ ! -f .vault_pass ]; then
    while true; do
        echo -e "${GREEN}Enter your Ansible Vault Password:${NC}"
        read -rs VAULT_PASS < /dev/tty
        echo
        [ -n "$VAULT_PASS" ] && break
        echo "Password must not be empty. Try again."
    done
    (umask 077; echo "$VAULT_PASS" > .vault_pass)
    echo "Vault password saved."
fi

if [ ! -f .ansible_become_pass ]; then
    while true; do
        echo -e "${GREEN}Enter your Mac Login Password (for sudo):${NC}"
        read -rs SUDO_PASS < /dev/tty
        echo
        [ -n "$SUDO_PASS" ] && break
        echo "Password must not be empty. Try again."
    done
    (umask 077; echo "$SUDO_PASS" > .ansible_become_pass)
    echo "Sudo password saved."
fi

# 6. Run Playbook
echo "Running Ansible Playbook..."
ansible-playbook localhost.yml --become-password-file .ansible_become_pass --vault-password-file .vault_pass

# 7. Initialize Conda (if installed)
if command -v conda &>/dev/null; then
    echo "Initializing Conda..."
    conda init --all
fi

echo -e "${GREEN}Setup Complete! Please restart your terminal.${NC}"
