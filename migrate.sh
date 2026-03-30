#!/bin/bash
set -e

# =============================================================================
# Ubuntu → KDE Plasma Migration Script
# Run via bootstrap.sh, or directly if git/gh/stow are already installed
# =============================================================================

echo "=== Ubuntu → KDE Plasma Migration ==="
echo ""
echo "This script will:"
echo "  - Install stow, KDE Plasma, SDDM, System Settings, Discover"
echo "  - Remove all Snap packages and snapd"
echo "  - Remove GNOME and switch from GDM to SDDM"
echo "  - Apply dotfiles with Stow"
echo ""
read -p "Continue? [y/N] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

if [ "$EUID" -eq 0 ]; then
    echo "ERROR: Do not run this script as root. Run as your normal user."
    exit 1
fi

# --- Step 1: Update system ---------------------------------------------------
echo "[1/7] Updating system..."
sudo apt update && sudo apt upgrade -y

# --- Step 2: Install stow ----------------------------------------------------
echo "[2/7] Installing stow..."
sudo apt install -y stow

# --- Step 3: Remove all Snap packages and snapd ------------------------------
echo "[3/7] Removing Snap packages and snapd..."

if command -v snap &>/dev/null; then
    snap list 2>/dev/null | awk 'NR>1 && $1!="snapd" {print $1}' | while read -r pkg; do
        echo "  Removing snap: $pkg"
        sudo snap remove --purge "$pkg" 2>/dev/null || true
    done

    sudo snap remove --purge snapd 2>/dev/null || true
    sudo apt remove --purge -y snapd
else
    echo "  snapd not found, skipping..."
fi

# Prevent snapd from being reinstalled
sudo tee /etc/apt/preferences.d/no-snapd > /dev/null <<EOF
Package: snapd
Pin: release *
Pin-Priority: -1
EOF

rm -rf ~/snap
sudo rm -rf /var/snap /var/lib/snapd /var/cache/snapd

echo "  Snap removed and blocked from reinstallation."

# --- Step 4: Install KDE Plasma -----------------------------------------------
echo "[4/7] Installing KDE Plasma desktop..."
sudo apt install -y kde-plasma-desktop plasma-workspace-wayland systemsettings plasma-discover

# --- Step 5: Switch display manager from GDM to SDDM -------------------------
echo "[5/7] Switching display manager to SDDM..."
sudo apt install -y sddm
sudo systemctl disable gdm 2>/dev/null || true
sudo systemctl enable sddm

# --- Step 6: Remove GNOME ----------------------------------------------------
echo "[6/7] Removing GNOME shell..."
sudo apt remove --purge -y gnome-shell
sudo apt autoremove --purge -y

# --- Step 7: Apply dotfiles with Stow ----------------------------------------
echo "[7/7] Applying dotfiles with Stow..."
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

if [ -d "kde/.config" ] && [ "$(ls -A kde/.config 2>/dev/null)" ]; then
    stow -v kde
    echo "  KDE config files linked."
else
    echo "  No KDE config files found yet, skipping stow."
fi

# --- Done ---------------------------------------------------------------------
echo ""
echo "=== Migration complete! ==="
echo ""
echo "SDDM is now your display manager and GNOME has been removed."
echo "Reboot to start using KDE Plasma."
echo ""
echo "To save your KDE config later, run: ./backup.sh"
