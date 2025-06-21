#!/bin/env bash

#sudo apt-get update
#sudo apt-get install git -y
#sudo apt-get install stow -y
#sudo apt-get install vim -y
#sudo apt-get install tmux -y
#sudo apt-get install curl -y
#sudo apt-get install wget -y
#sudo apt-get install htop -y
#sudo apt-get autoremove -y
#sudo apt-get autoclean

git clone https://github.com/TheLocehiliosan/yadm.git $HOME/.local/share/yadm
mkdir -p $HOME/.local/bin; ln -s $HOME/.local/share/yadm/yadm $HOME/.local/bin/yadm

if command -v curl >/dev/null 2>&1; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
else
  sh -c "$(wget -O- https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
fi

# Stow to create symlinks and bootstrap environment
#stow --adopt zsh
#exec zsh
#stow vim
#stow tmux
#stow ssh
#stow git
#stow htop

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
