#!/bin/bash

# =============================================================================
# Backup KDE config files into the dotfiles repo for Stow
# Run this after changing settings in KDE to capture them in your repo
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KDE_DIR="$SCRIPT_DIR/kde/.config"

mkdir -p "$KDE_DIR"

# KDE config files to track
KDE_CONFIGS=(
    kdeglobals
    kwinrc
    kwinrulesrc
    kcminputrc
    kglobalshortcutsrc
    khotkeysrc
    krunnerrc
    kxkbrc
    kactivitymanagerdrc
    plasma-org.kde.plasma.desktop-appletsrc
    plasmashellrc
    plasma-localerc
    ksmserverrc
    dolphinrc
    konsolerc
    gwenviewrc
    spectaclerc
    kmixrc
    kwalletrc
    mimeapps.list
    systemsettingsrc
    okularpartrc
    kateschemarc
)

BACKED_UP=0

for conf in "${KDE_CONFIGS[@]}"; do
    SRC="$HOME/.config/$conf"
    DEST="$KDE_DIR/$conf"

    if [ -f "$SRC" ]; then
        # If it's a symlink (already stowed), copy the content
        if [ -L "$SRC" ]; then
            echo "  [skip] $conf (already managed by stow)"
        else
            cp "$SRC" "$DEST"
            echo "  [saved] $conf"
            ((BACKED_UP++))
        fi
    fi
done

# Save package lists
apt-mark showmanual > "$SCRIPT_DIR/packages-apt.txt"
echo "  [saved] packages-apt.txt ($(wc -l < "$SCRIPT_DIR/packages-apt.txt") packages)"

if command -v flatpak &>/dev/null; then
    flatpak list --app --columns=application > "$SCRIPT_DIR/packages-flatpak.txt"
    echo "  [saved] packages-flatpak.txt"
fi

echo ""
echo "Backed up $BACKED_UP config files."
echo ""
echo "Next steps:"
echo "  cd $SCRIPT_DIR"
echo "  git add -A && git commit -m 'Update config'"
