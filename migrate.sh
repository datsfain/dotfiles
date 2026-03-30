#!/bin/bash
set -e

# =============================================================================
# Ubuntu → KDE Plasma Migration Script
# Migrates from GNOME to KDE Plasma, removes Snap
# =============================================================================

echo "=== Ubuntu → KDE Plasma Migration ==="
echo ""
echo "This script will:"
echo "  - Remove all Snap packages and snapd"
echo "  - Install KDE Plasma, SDDM, System Settings, Discover"
echo "  - Remove GNOME and switch from GDM to SDDM"
echo ""
read -p "Continue? [y/N] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Skipped."
    exit 0
fi

if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR: Do not run this script as root. Run as your normal user."
    exit 1
fi

# --- Step 1: Remove all Snap packages and snapd ------------------------------
echo "[1/5] Removing Snap packages and snapd..."

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

sudo tee /etc/apt/preferences.d/no-snapd > /dev/null <<EOF
Package: snapd
Pin: release *
Pin-Priority: -1
EOF

rm -rf ~/snap
sudo rm -rf /var/snap /var/lib/snapd /var/cache/snapd

echo "  Snap removed and blocked from reinstallation."

# --- Step 2: Install KDE Plasma -----------------------------------------------
echo "[2/5] Installing KDE Plasma desktop..."
sudo apt install -y kde-plasma-desktop plasma-workspace-wayland systemsettings plasma-discover

# --- Step 3: Switch display manager from GDM to SDDM -------------------------
echo "[3/5] Switching display manager to SDDM..."
sudo apt install -y sddm
sudo systemctl disable gdm 2>/dev/null || true
sudo systemctl enable sddm

# --- Step 4: Remove GNOME ----------------------------------------------------
echo "[4/5] Removing GNOME shell..."
sudo apt remove --purge -y gnome-shell
sudo apt autoremove --purge -y

# --- Step 5: Update system ----------------------------------------------------
echo "[5/5] Updating system..."
sudo apt update && sudo apt upgrade -y

# --- Done ---------------------------------------------------------------------
echo ""
echo "=== Migration complete! ==="
echo ""
echo "SDDM is now your display manager and GNOME has been removed."
echo "Reboot to start using KDE Plasma."
