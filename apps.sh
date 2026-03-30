#!/bin/bash
set -e

# =============================================================================
# App installer — add your apps here
# =============================================================================

echo "=== Installing Apps ==="
echo ""

# --- JetBrains Rider ----------------------------------------------------------
echo "Installing JetBrains Rider..."
if ! command -v rider &>/dev/null; then
    curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsToolbox/main/install-toolbox.sh | bash
    echo "  Toolbox installed. Open it to install Rider."
else
    echo "  Already installed."
fi

# --- Unity Hub ----------------------------------------------------------------
echo "Installing Unity Hub..."
if ! dpkg -l unityhub &>/dev/null; then
    wget -qO - https://hub.unity3d.com/linux/keys/public | sudo gpg --dearmor -o /usr/share/keyrings/unity-hub.gpg
    echo "deb [signed-by=/usr/share/keyrings/unity-hub.gpg] https://hub.unity3d.com/linux/repos/deb stable main" \
        | sudo tee /etc/apt/sources.list.d/unityhub.list > /dev/null
    sudo apt update
    sudo apt install -y unityhub
else
    echo "  Already installed."
fi

# --- Add more apps below ------------------------------------------------------
# Example:
# echo "Installing <app>..."
# <install commands>

echo ""
echo "=== Apps installed! ==="
