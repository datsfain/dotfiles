#!/bin/bash
set -e

# =============================================================================
# Bootstrap script — run this on a fresh Ubuntu install:
#   curl -fsSL https://raw.githubusercontent.com/<you>/dotfiles/main/bootstrap.sh | bash
#   NOTE: must pipe to bash, not sh — this script uses bash syntax
# =============================================================================

echo "=== Dotfiles Bootstrap ==="
echo ""

if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR: Do not run as root. Run as your normal user."
    exit 1
fi

# --- Install git, GitHub CLI, and Brave browser -------------------------------
echo "[1/5] Installing git, GitHub CLI, and Brave browser..."
sudo apt update
sudo apt install -y git gh curl

# Add Brave repository and install
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
    | sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null
sudo apt update
sudo apt install -y brave-browser

# Set Brave as default browser
xdg-settings set default-web-browser brave-browser.desktop 2>/dev/null || true

# Install Claude Code
curl -fsSL https://claude.ai/install.sh | bash

# Install SourceGit
curl -fsSL https://codeberg.org/api/packages/yataro/debian/repository.key \
    | sudo tee /etc/apt/keyrings/sourcegit.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/sourcegit.asc] https://codeberg.org/api/packages/yataro/debian generic main" \
    | sudo tee /etc/apt/sources.list.d/sourcegit.list > /dev/null
sudo apt update
sudo apt install -y sourcegit

# --- Authenticate with GitHub -------------------------------------------------
echo "[2/5] Authenticating with GitHub..."
if gh auth status &>/dev/null; then
    echo "  Already authenticated."
else
    gh auth login
fi
gh auth setup-git

# Set git identity
git config --global user.name "datsfain"
git config --global user.email "datsfain@gmail.com"

# --- Clone dotfiles repo -----------------------------------------------------
echo "[3/5] Cloning dotfiles repo..."
if [ -d "$HOME/dotfiles" ]; then
    echo "  ~/dotfiles already exists, pulling latest..."
    cd "$HOME/dotfiles"
    git pull
else
    gh repo clone dotfiles "$HOME/dotfiles"
fi

# --- Run migration script ----------------------------------------------------
echo "[4/5] Running migration script..."
cd "$HOME/dotfiles"
chmod +x migrate.sh
./migrate.sh
