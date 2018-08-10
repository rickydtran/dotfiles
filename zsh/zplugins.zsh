# Let zplug manage zplug
zplug 'zplug/zplug', hook-build:'zplug --self-manage'
# Async for zsh, used by pure
zplug "mafredri/zsh-async", from:github, defer:0
# Load completion library for those sweet [tab] squares
zplug "lib/completion", from:oh-my-zsh
# Up -> History search! Who knew it wasn't a built in?
zplug "lib/key-bindings", from:oh-my-zsh
# History defaults
zplug "lib/history", from:oh-my-zsh
# Adds useful aliases for things dealing with directories
zplug "lib/directories", from:oh-my-zsh
# gst, gco, gc -> All the git shortcut goodness
zplug "plugins/git", from:oh-my-zsh, if:"hash git"
# gst, gco, gc -> All the git shortcut goodness
zplug "plugins/svn", from:oh-my-zsh, if:"hash svn"
# Syntax highlighting for commands
zplug "zsh-users/zsh-syntax-highlighting", from:github, defer:3
# Syntax highlighting for commands
zplug "zsh-users/zsh-autosuggestions", from:github, defer:3
# TMUX Integration
zplug "plugins/tmux", from:oh-my-zsh

# Don't load theme if SSH Session
if [[ -n $SSH_CONNECTION ]]; then
    PROMPT="%F{106}%${width_part}<...<%3~%f%# "
else
    # Theme!
    zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme
fi