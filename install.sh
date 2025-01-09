#!/bin/bash

# Ensure the .config directory exists
mkdir -p ~/.config

# Symlink Git
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig

# Symlink starship.toml
ln -sf ~/dotfiles/starship.toml ~/.config/starship.toml

# Symlink zsh
ln -sf ~/dotfiles/.zshrc ~/.zshrc

# Symlink tmux
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf

echo "Dotfiles installed successfully!"
