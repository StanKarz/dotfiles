#!/bin/bash

# Symlink .zshrc
ln -sf ~/dotfiles/.zshrc ~/.zshrc

# Symlink .tmux.conf
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf

echo "Dotfiles installed!"