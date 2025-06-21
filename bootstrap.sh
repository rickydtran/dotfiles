#!/bin/env bash

# Configuration
DOTFILES_REPO="https://github.com/rickydtran/dotfiles"
#BREW_PACKAGES=(age asciinema atuin bat cmake curl delta fd ghostty gifski git go htop jq lua make mkcert neovim nmap node pipx python rcm ripgrep tmux tree wget wrk yarn youtube-dl zsh cloudflare/cloudflare/cloudflared rbenv ruby-build uv ruff)
#CASKS=()

# Colors
reset="$(tput sgr0)"
highlight="$(tput smso)"
dim="$(tput dim)"
red="$(tput setaf 1)"
blue="$(tput setaf 4)"
green="$(tput setaf 2)"
yellow="$(tput setaf 3)"
bold=$(tput bold)
normal=$(tput sgr0)
underline="$(tput smul)"
indent="   "

# Error handling
trap 'ret=$?; test $ret -ne 0 && printf "${red}Setup failed${reset}\n" >&2; exit $ret' EXIT
set -e

# --- Helpers
print_success() {
    printf "${green}✔ success:${reset} %b\n" "$1"
}

print_error() {
    printf "${red}✖ error:${reset} %b\n" "$1"
}

print_info() {
    printf "${blue}ⓘ info:${reset} %b\n" "$1"
}

# ------
# Setup
# ------
printf "
${yellow}
Running...

██████╗ ██╗ ██████╗██╗  ██╗██╗   ██╗
██╔══██╗██║██╔════╝██║ ██╔╝╚██╗ ██╔╝
██████╔╝██║██║     █████╔╝  ╚████╔╝
██╔══██╗██║██║     ██╔═██╗   ╚██╔╝
██║  ██║██║╚██████╗██║  ██╗   ██║
╚═╝  ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝
████████╗██████╗  █████╗ ███╗   ██╗
╚══██╔══╝██╔══██╗██╔══██╗████╗  ██║
   ██║   ██████╔╝███████║██╔██╗ ██║
   ██║   ██╔══██╗██╔══██║██║╚██╗██║
   ██║   ██║  ██║██║  ██║██║ ╚████║
   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝

-----
- Sets up a macOS or Linux based development machine.
- Can be run in WSL on Windows
- Safe to run repeatedly (checks for existing installs)
- Repository at https://github.com/rickydtran/dotfiles
-----
${reset}
"

# Check environments
OS=$(uname -s 2> /dev/null)
USER=${USER}
HOSTNAME=$(hostname)
DISTRO=""
IS_WSL=false
INTERACTIVE=true
if [ "${OS}" = "Linux" ]; then
    # Check Debian vs. RHEL
    if [ -f /etc/os-release ] && $(grep -iq "Debian" /etc/os-release); then
        DISTRO="Debian"
    fi

    if $(grep -q "Microsoft" /proc/version); then
        IS_WSL=true
    fi

    if [[ $- == *i* ]]; then
        INTERACTIVE=true
    else
        INTERACTIVE=false
    fi
fi

print_info "Detected environment: ${OS} (distro: ${DISTRO})"
print_info "Windows for Linux Subsystem (WSL): ${IS_WSL}"
print_info "Interactive shell session: ${INTERACTIVE}"
print_info "User: ${USER}@${HOSTNAME}"

# Sets up a Linux and/or WSL (Windows Subsystem for Linux) based dev-environment.
# Deployment of dotfiles are/will be the following:
# 1. Git/HTTPS, will set up SSH
# 2. Git/SSH, assumes SSH is configured
# 3. Airgap, tbd... needs to be portable
if [ "$INTERACTIVE" = true ] && ! [[ -f "${HOME}/.gitconfig" ]]; then
    print_error "Local .gitconfig file doesn't exist. Creating..."
    cp "${HOME}/.dotfiles/git/.gitconfig" ${HOME}
    #TBD PROMPT TO replace name and email
    if [ -f "${HOME}/.gitconfig" ]; then
        print_success ".gitconfig created!"
    fi
elif [ -f "${HOME}/.gitconfig" ]; then
    print_info "Local .gitconfig file already exist!"
else
    print_error "Local .gitconfig file doesn't exist. Creating..."
    cp "${HOME}/.dotfiles/git/.gitconfig" ${HOME}
    if [ -f "${HOME}/.gitconfig" ]; then
        print_success ".gitconfig created!"
    fi
fi

SSH_EMAIL=$(git config --global user.email)
print_info "SSH Email configured: ${SSH_EMAIL}"
# Generate an SSH key (if none) if we're in an interactive shell
SSH_KEY="${HOME}/.ssh/id_ed25519_${USER}_${HOSTNAME}"
if [ "$INTERACTIVE" = true ] && ! [[ -f "${SSH_KEY}" ]]; then
    printf "🔑 Generating new SSH key\n"
    ssh-keygen -t ed25519 -f ${SSH_KEY} -C "${SSH_EMAIL}"
    print_info "Key: ${SSH_KEY} generated!"
fi

SSH_STATUS=$(ssh -T git@github.com 2>&1|| true)
if echo "${SSH_STATUS}" | grep -q "successfully authenticated"; then
    print_success "SSH is configured correctly for GitHub!"
elif echo "${SSH_STATUS}" | grep -q "Permission denied"; then
    print_error "SSH is set up, but authentication failed. Check your SSH keys in GitHub." exit 1
elif echo "${SSH_STATUS}" | grep -q "Could not resolve hostname"; then
    print_error "Could not resolve GitHub host. Check your internet or SSH config."
else
    print_error "SSH connection to GitHub failed. See output above."
fi

# Check for connectivity
if [ ping -q -w1 -c1 google.com &>/dev/null ]; then
    print_error "Cannot connect to the Internet"
    exit 1
else
    print_success "Internet reachable"
fi

# Ask for sudo
sudo -v &> /dev/null

# Update the system & install core dependencies
if [ "$OS" = "Linux" ] && [ "$DISTRO" = "Debian" ]; then
    print_info "Updating system packages"
    sudo apt update
    sudo apt -y upgrade
    sudo apt -y install curl wget git
    sudo apt -y autoremove
    sudo apt autoclean
else
    print_info "Skipping system package updates"
fi

# Set up sandbox directory
if [ ! -d "${HOME}/sandbox" ]; then
    mkdir -p $HOME/sandbox
fi

# --- dotfiles
# Clone & install dotfiles
print_info "Configuring dotfiles"
if [ ! -d "${HOME}/.dotfiles" ]; then
    print_info "Cloning dotfiles"
    git clone ${DOTFILES_REPO} "${HOME}/.dotfiles"
else
    print_info "dotfiles already cloned"
fi

print_info "Linking dotfiles"
pushd "${HOME}/.dotfiles"
stow --adopt zsh
stow --adopt vim
if command -v vim >/dev/null 2>&1; then
    print_info "Bootstraping Vim"
    vim '+PlugUpdate' '+PlugClean!' '+PlugUpdate' '+qall'
fi
stow --adopt tmux
stow --adopt ssh
stow --adopt git
stow --adopt htop
popd
print_success "dotfiles installed"

# --- Configure zsh
exec zsh

print_success "Done!"
