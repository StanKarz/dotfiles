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

# Ensure ~/.config exists (where starship.toml is symlinked to),
# ~/.config/git (git's default location for the global ignore file), and
# ~/.claude/skills (Claude Code's global config lives in ~/.claude)
mkdir -p "$HOME/.config" "$HOME/.config/git" "$HOME/.claude/skills"

# Helper: if a real file (not already a symlink) exists at $1, move it aside
# with a timestamped .backup suffix. This preserves any local changes you
# made before installing dotfiles. Existing symlinks are left for `ln -sf`
# to overwrite.
#
# The body is an `if` rather than `[[ ... ]] && mv` because the latter returns 1
# when the test is false, which under `set -e` aborts the whole script. Both
# ordinary cases are false (the file does not exist yet, or it is already a
# symlink), so the script used to exit silently before creating a single link.
backup_if_exists() {
    if [[ -e "$1" && ! -L "$1" ]]; then
        mv "$1" "$1.backup.$(date +%s)"
    fi
}

# Back up any pre-existing real files
backup_if_exists "$HOME/.gitconfig"
backup_if_exists "$HOME/.zshrc"
backup_if_exists "$HOME/.tmux.conf"
backup_if_exists "$HOME/.vimrc"
backup_if_exists "$HOME/.config/starship.toml"
backup_if_exists "$HOME/.config/git/ignore"
backup_if_exists "$HOME/.claude/settings.json"
backup_if_exists "$HOME/.claude/keybindings.json"

# Create symlinks (-s = symbolic, -f = force overwrite existing symlink)
ln -sf "$DOTFILES_DIR/.gitconfig"    "$HOME/.gitconfig"
ln -sf "$DOTFILES_DIR/.zshrc"        "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/.tmux.conf"    "$HOME/.tmux.conf"
ln -sf "$DOTFILES_DIR/.vimrc"        "$HOME/.vimrc"
ln -sf "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
ln -sf "$DOTFILES_DIR/.gitignore_global" "$HOME/.config/git/ignore"
ln -sf "$DOTFILES_DIR/claude/settings.json"    "$HOME/.claude/settings.json"
ln -sf "$DOTFILES_DIR/claude/keybindings.json" "$HOME/.claude/keybindings.json"

# The skill directory itself stays real and only SKILL.md is linked. Linking the
# directory also works, but then anything Claude Code adds beside SKILL.md lands
# in the repo, and a backup copy of the directory registers as a second skill
# with a `.backup.<timestamp>` name.
mkdir -p "$HOME/.claude/skills/init-project"
backup_if_exists "$HOME/.claude/skills/init-project/SKILL.md"
ln -sf "$DOTFILES_DIR/claude/skills/init-project/SKILL.md" \
       "$HOME/.claude/skills/init-project/SKILL.md"

# CLAUDE.md is gitignored, so a fresh clone will not have it: link it when a
# copy is present and say so when it is not, rather than failing the install.
if [[ -f "$DOTFILES_DIR/claude/CLAUDE.md" ]]; then
    backup_if_exists "$HOME/.claude/CLAUDE.md"
    ln -sf "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
else
    echo "note: claude/CLAUDE.md not in this clone, so ~/.claude/CLAUDE.md was left alone"
fi

echo "Dotfiles installed successfully!"
