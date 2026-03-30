#!/bin/bash
set -e

# =============================================================================
# Bootstrap script — run this on a fresh Ubuntu install:
#   curl -fsSL https://raw.githubusercontent.com/datsfain/dotfiles/main/bootstrap.sh | bash
#   NOTE: must pipe to bash, not sh — this script uses bash syntax
# =============================================================================

echo "=== Dotfiles Bootstrap ==="
echo ""

if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR: Do not run as root. Run as your normal user."
    exit 1
fi

# --- Step 1: Install tools ----------------------------------------------------
echo "[1/5] Installing tools..."
sudo apt update
sudo apt install -y git gh curl stow

# Brave browser
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
    | sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null
sudo apt update
sudo apt install -y brave-browser
xdg-settings set default-web-browser brave-browser.desktop 2>/dev/null || true

# Claude Code
curl -fsSL https://claude.ai/install.sh | bash

# SourceGit
curl -fsSL https://codeberg.org/api/packages/yataro/debian/repository.key \
    | sudo tee /etc/apt/keyrings/sourcegit.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/sourcegit.asc] https://codeberg.org/api/packages/yataro/debian generic main" \
    | sudo tee /etc/apt/sources.list.d/sourcegit.list > /dev/null
sudo apt update
sudo apt install -y sourcegit

# --- Step 2: Authenticate with GitHub ----------------------------------------
echo "[2/5] Authenticating with GitHub..."
if gh auth status &>/dev/null; then
    echo "  Already authenticated."
else
    gh auth login
fi
gh auth setup-git
git config --global user.name "datsfain"
git config --global user.email "datsfain@gmail.com"

# --- Step 3: Clone dotfiles repo ---------------------------------------------
echo "[3/5] Cloning dotfiles repo..."
if [ -d "$HOME/dotfiles" ]; then
    echo "  ~/dotfiles already exists, pulling latest..."
    cd "$HOME/dotfiles"
    git pull
else
    gh repo clone dotfiles "$HOME/dotfiles"
fi

# --- Step 4: Migrate to KDE Plasma (optional) --------------------------------
echo "[4/6] KDE Plasma migration..."
cd "$HOME/dotfiles"
chmod +x migrate.sh
./migrate.sh

# --- Step 5: Install apps -----------------------------------------------------
echo "[5/6] Installing apps..."
cd "$HOME/dotfiles"
chmod +x apps.sh
./apps.sh

# --- Step 6: Apply dotfiles with Stow ----------------------------------------
echo "[6/6] Applying dotfiles..."
cd "$HOME/dotfiles"
chmod +x stow-all.sh
./stow-all.sh

# --- Done ---------------------------------------------------------------------
echo ""
echo "=== Bootstrap complete! ==="
echo "Reboot to start using your setup."
