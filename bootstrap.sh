#!/bin/bash

sudo apt-get update
sudo apt-get install stow -y
sudo apt-get autoremove -y
sudo apt-get autoclean

# Stow to create symlinks and bootstrap environment
stow zsh
stow vim
stow tmux
stow ssh
stow git
stow htop

# Install tmux tpm and load/install plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins
