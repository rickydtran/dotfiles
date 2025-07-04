# Personal Zsh configuration file. It is strongly recommended to keep all
# shell customization and configuration (including exported environmentj
# variables such as PATH) in this file or in files sourced from it.
#
# Documentation: https://github.com/romkatv/zsh4humans/blob/v5/README.md.

# Periodic auto-update on Zsh startup: 'ask' or 'no'.
# You can manually run `z4h update` to update everything.
zstyle ':z4h:' auto-update      'no'
# Ask whether to auto-update this often; has no effect if auto-update is 'no'.
zstyle ':z4h:' auto-update-days '28'

# Keyboard type: 'mac' or 'pc'.
if [[ "$OSTYPE" == "darwin"* ]]; then
    zstyle ':z4h:bindkey' keyboard  'mac'
else
    zstyle ':z4h:bindkey' keyboard  'pc'
fi

# Don't start tmux.
zstyle ':z4h:' start-tmux       no

# Mark up shell's output with semantic information.
zstyle ':z4h:' term-shell-integration 'yes'

# Propagate current directory to new windows
zstyle ':z4h:' propagate-cwd yes

# Autostart ssh-agent
# zstyle ':z4h:ssh-agent:' start      yes
# zstyle ':z4h:ssh-agent:' extra-args -t 20h

# Right-arrow key accepts one character ('partial-accept') from
# command autosuggestions or the whole thing ('accept')?
zstyle ':z4h:autosuggestions' forward-char 'accept'

# Recursively traverse directories when TAB-completing files.
zstyle ':z4h:fzf-complete' recurse-dirs 'no'

# Enable direnv to automatically source .envrc files.
zstyle ':z4h:direnv'         enable 'no'
# Show "loading" and "unloading" notifications from direnv.
zstyle ':z4h:direnv:success' notify 'yes'

# Enable ('yes') or disable ('no') automatic teleportation of z4h over
# SSH when connecting to these hosts.
zstyle ':z4h:ssh:example-hostname1'   enable 'yes'
zstyle ':z4h:ssh:*.example-hostname2' enable 'no'
# The default value if none of the overrides above match the hostname.
zstyle ':z4h:ssh:*'                   enable 'no'
zstyle ':z4h:ssh:swxtch-dev'          enable 'no'
zstyle ':z4h:ssh:*core*'              enable 'yes'
zstyle ':z4h:ssh:*swxtch*'            enable 'yes'
zstyle ':z4h:ssh:*agent*'             enable 'yes'
zstyle ':z4h:ssh:*bridge*'            enable 'yes'
zstyle ':z4h:ssh:*metal*'             enable 'yes'
zstyle ':z4h:ssh:testgpu-*'           enable 'yes'
zstyle ':z4h:ssh:*samc*'              enable 'yes'
zstyle ':z4h:ssh:*runner*'            enable 'yes'
zstyle ':z4h:ssh:*bastion*'           enable 'yes'

# Send these files over to the remote host when connecting over SSH to the
# enabled hosts.
zstyle ':z4h:ssh:*' send-extra-files '~/.nanorc' '~/.config/htop/htoprc' '~/.vimrc' '~/.tmux.conf'

# Clone additional Git repositories from GitHub.
#
# This doesn't do anything apart from cloning the repository and keeping it
# up-to-date. Cloned files can be used after `z4h init`. This is just an
# example. If you don't plan to use Oh My Zsh, delete this line.
z4h install ohmyzsh/ohmyzsh || return

# Install or update core components (fzf, zsh-autosuggestions, etc.) and
# initialize Zsh. After this point console I/O is unavailable until Zsh
# is fully initialized. Everything that requires user interaction or can
# perform network I/O must be done above. Everything else is best done below.
z4h init || return

env=~/.ssh/agent.env

agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }

agent_start () {
    (umask 077; ssh-agent -s -t 20h >| "$env")
    . "$env" >| /dev/null ; }

agent_load_env

# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
    find ~/.ssh/ -type f -exec grep -l "PRIVATE" {} \; | xargs ssh-add &> /dev/null
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    find ~/.ssh/ -type f -exec grep -l "PRIVATE" {} \; | xargs ssh-add &> /dev/null
fi

# This function is invoked by zsh4humans on every ssh command after
# the instructions from ssh-related zstyles have been applied. It allows
# us to configure ssh teleportation in ways that cannot be done with
# zstyles.
#
# Within this function we have readonly access to the following parameters:
#
# - z4h_ssh_client  local hostname
# - z4h_ssh_host    remote hostname as it was specified on the command line
#
# We also have read & write access to these:
#
# - z4h_ssh_enable          1 to use ssh teleportation, 0 for plain ssh
# - z4h_ssh_send_files      list of files to send to the remote; keys are local
#                           file names, values are remote file names
# - z4h_ssh_retrieve_files  the same as z4h_ssh_send_files but for pulling
#                           files from remote to local
# - z4h_retrieve_history    list of local files into which remote $HISTFILE
#                           should be merged at the end of the connection
# - z4h_ssh_command         command to use instead of `ssh`
function z4h-ssh-configure() {
  emulate -L zsh

  # Bail out if ssh teleportation is disabled. We could also
  # override this parameter here if we wanted to.
  (( z4h_ssh_enable )) || return 0

  # Figure out what kind of machine we are about to connect to.
  local machine_tag
  case $z4h_ssh_host in
    ec2-*)   machine_tag=ec2;;
    *core*)  machine_tag=core;;
    *agent*) machine_tag=agent;;
    *metal*) machine_tag=metal;;
    *)       machine_tag=$z4h_ssh_host;;
  esac

  # This is where we are locally keeping command history
  # retrieved from machines of this kind.
  local local_hist=$ZDOTDIR/.zsh/history/retrieved_from_$machine_tag

  # This is where our $local_hist ends up on the remote machine when
  # we connect to it. Command history from files with names like this
  # is explicitly loaded by our zshrc (see below). All new commands
  # on the remote machine will still be written to the regular $HISTFILE.
  local remote_hist='"$ZDOTDIR"/.zsh/history/received_from_'${(q)z4h_ssh_client}

  # At the start of the SSH connection, send $local_hist over and
  # store it as $remote_hist.
  z4h_ssh_send_files[$local_hist]=$remote_hist

  # At the end of the SSH connection, retrieve $HISTFILE from the
  # remote machine and merge it with $local_hist.
  z4h_retrieve_history+=($local_hist)
}

# Load command history that was sent to this machine over ssh.
() {
  emulate -L zsh -o extended_glob
  local hist
  for hist in $ZDOTDIR/.zsh/history/received_from_*(NOm); do
    fc -RI $hist
  done
}

# Extend PATH.
path=(~/bin $path)

# Export environment variables.
export GPG_TTY=$TTY

# Source additional local files if they exist.
z4h source ~/.env.zsh

# Use additional Git repositories pulled in with `z4h install`.
#
# This is just an example that you should delete. It does nothing useful.
# z4h source ohmyzsh/ohmyzsh/lib/diagnostics.zsh  # source an individual file
# z4h load   ohmyzsh/ohmyzsh/plugins/emoji-clock  # load a plugin

# Define key bindings.
z4h bindkey undo Ctrl+/   Shift+Tab  # undo the last command line change
z4h bindkey redo Option+/            # redo the last undone command line change

z4h bindkey z4h-cd-back    Shift+Left   # cd into the previous directory
z4h bindkey z4h-cd-forward Shift+Right  # cd into the next directory
z4h bindkey z4h-cd-up      Shift+Up     # cd into the parent directory
z4h bindkey z4h-cd-down    Shift+Down   # cd into a child directory

# Autoload functions.
autoload -Uz zmv

# Define functions and completions.
function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

# Define named directories: ~w <=> Windows home directory on WSL.
[[ -z $z4h_win_home ]] || hash -d w=$z4h_win_home

# Define aliases.
alias tree='tree -a -I .git'
alias setup_workspace='tmux new -s dev -d; tmux new -s test -d; tmux ls'
alias get_swx_pids='pgrep -l swx'
alias get_pid_of="pgrep -a $1"
alias list_iptables="sudo iptables -L -v | grep -v \"    0\" | less -N"
alias get_wan_ip="curl ifconfig.me"

# Add flags to existing aliases.
if [[ "$OSTYPE" == "linux"* ]]; then
    alias ls="${aliases[ls]:-ls} -x --color=auto --group-directories-first"
    alias la="${aliases[ls]:-ls} -ax --color=auto --group-directories-first"
    alias ll="${aliases[ls]:-ls} -l --color=auto --group-directories-first"
    alias lll="${aliases[ls]:-ls} -lA --color=auto --group-directories-first"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    alias ls="${aliases[gls]:-gls} -x --color=auto --group-directories-first"
    alias la="${aliases[gls]:-gls} -ax --color=auto --group-directories-first"
    alias ll="${aliases[gls]:-gls} -l --color=auto --group-directories-first"
    alias lll="${aliases[gls]:-gls} -lA --color=auto --group-directories-first"
fi

# Port scanning
function port_scan() {
    proto=$1
    ipaddr=$2
    plow=$3
    phigh=$4
    [ -z "$4" ]  && phigh=$3
    for port in {$plow..$phigh}; do
        bash -c "echo -n 2>/dev/null < /dev/$proto/$ipaddr/$port && echo \"$port/$1 open\""
    done
}

# udp ping
function udp_ping() {
    ipaddr=$1
    port=$2
    bash -c "echo -n \"ping\" > /dev/udp/$ipaddr/$port"
}

# "fancy" diffs
function dsf() { diff -u "$1" "$2" | delta; }

# submodule update
function git_submodules_update() {
    git submodule sync --recursive
    git submodule update --init --force --recursive
    git submodule foreach --recursive git clean -ffdx
}

# fetch all tags and branches
function git_fetch_all() {
    git branch -r | grep -v '\->' | sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" | while read remote; do git branch --track "${remote#origin/}" "$remote"; done
    git fetch --all
    git pull --all
}

# nuke all branches other than default branch
function git_clean_branches() {
    def_branch=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)
    git branch | grep -v "^\* $def_branch" | xargs -n 1 -r git branch -D
}

# nuke and clean git repo
function git_clean_repo() {
    git reset --hard
    git_clean_branches
    git submodule sync --recursive
    git submodule update --init --force --recursive
    git clean -ffdx
    git submodule foreach --recursive git clean -ffdx
}

# Clear to Bottom
alias clear=z4h-clear-screen-soft-bottom

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt no_auto_menu  # require an extra TAB press to open the completion menu

# Check if .vim directory exist. If it isn't then we will boostrap it to prevent vim being opened by a non-root user
if command -v vim >/dev/null 2>&1 && ! [ -d ~/.vim ]; then
    echo "Bootstraping Vim"
    vim '+PlugUpdate' '+PlugClean!' '+PlugUpdate' '+qall'
fi

# list tmux status
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    if [[ "$TERM_PROGRAM" == "vscode" ]]; then
        echo "vscode dectected. running standard shell."
    elif tmux has &> /dev/null; then
        echo "\ntmux sessions:"
        tmux ls
    else
        echo "\ntmux not running!"
    fi
fi
