#!/bin/bash
set -e

# =============================================================================
# Stows all dotfile packages in this repo
# Automatically finds directories that contain config to stow
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Skip directories that aren't stow packages
SKIP=(".git")

for dir in */; do
    dir="${dir%/}"

    # Skip non-stow directories
    skip=false
    for s in "${SKIP[@]}"; do
        if [ "$dir" = "$s" ]; then
            skip=true
            break
        fi
    done
    $skip && continue

    # Remove conflicting files then stow
    echo "Stowing $dir..."
    find "$dir" -type f | while read -r file; do
        # Convert repo path to home path (strip the package name prefix)
        target="$HOME/${file#"$dir"/}"
        if [ -f "$target" ] && [ ! -L "$target" ]; then
            rm -f "$target"
        fi
    done
    stow -v "$dir"
done

echo ""
echo "All packages stowed."
