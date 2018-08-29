# ================================================================
# Useful Functions
# ================================================================
source_if_exists() {
    if [[ -f $1 ]]; then
        source $1;
    fi
}

path_if_exists() {
    if [[ -d $1 ]]; then
        export PATH="$1:$PATH"
    fi
}

# ================================================================
# Symbolic Links
# Update ZSH Environment Variables and add newer version to PATH
# ================================================================
# Set UMASK to 002
umask 002
export LANG=en_US.UTF-8
export TERM=xterm-256color
export SHELL='zsh'
export PATH=$HOME/.apps/zsh/bin:$PATH
# TMUX
export PATH=$HOME/.apps/tmux/bin:$PATH
# Sublime
export PATH=$HOME/.apps/sublime_text_3/bin:$PATH
# HDL File Sorter
export EDAUTILS_ROOT=$HOME/.apps/sorthdlfiles
export PATH=$HOME/.apps/sorthdlfiles/bin:$PATH
# Newer Version of Curl
export PATH=$HOME/.apps/curl/bin:$PATH
export LD_LIBRARY_PATH=$HOME/.apps/curl/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$HOME/.apps/curl/lib64:$LD_LIBRARY_PATH
export C_INCLUDE_PATH=$HOME/.apps/curl/include:$C_INCLUDE_PATH

# Launch TMUX on startup
# if [ -z $TMUX ]; then; exec tmux; fi

# Add Custom Completion Scripts to FPATH
fpath=(~/.zsh/completion $fpath)
