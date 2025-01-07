#!/bin/bash

# Ensure the .config directory exists
mkdir -p ~/.config

# Symlink starship.toml
ln -sf ~/dotfiles/starship.toml ~/.config/starship.toml

# Symlink other files
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf

echo "Dotfiles installed successfully!"