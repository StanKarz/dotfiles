#!/bin/bash
# install.sh — symlink dotfiles from ~/dotfiles into the right places in $HOME.
# Safe to re-run: existing real files are backed up before being replaced.

# Exit on: any command failure (-e), undefined variables (-u), or pipe failures (-o pipefail)
set -euo pipefail

# Where the dotfiles repo lives — derived from this script's location so it
# works regardless of where the repo was cloned.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Bail out early if the repo isn't where we expect it
[[ -d "$DOTFILES_DIR" ]] || { echo "Error: $DOTFILES_DIR not found"; exit 1; }

# Ensure ~/.config exists (where starship.toml is symlinked to)
mkdir -p "$HOME/.config"

# Helper: if a real file (not already a symlink) exists at $1, move it aside
# with a timestamped .backup suffix. This preserves any local changes you
# made before installing dotfiles. Existing symlinks are left for `ln -sf`
# to overwrite.
backup_if_exists() {
    [[ -e "$1" && ! -L "$1" ]] && mv "$1" "$1.backup.$(date +%s)"
}

# Back up any pre-existing real files
backup_if_exists "$HOME/.gitconfig"
backup_if_exists "$HOME/.zshrc"
backup_if_exists "$HOME/.tmux.conf"
backup_if_exists "$HOME/.config/starship.toml"

# Create symlinks (-s = symbolic, -f = force overwrite existing symlink)
ln -sf "$DOTFILES_DIR/.gitconfig"    "$HOME/.gitconfig"
ln -sf "$DOTFILES_DIR/.zshrc"        "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/.tmux.conf"    "$HOME/.tmux.conf"
ln -sf "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"

echo "Dotfiles installed successfully!"
