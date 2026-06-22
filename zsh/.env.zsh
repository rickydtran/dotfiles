# uv
export PATH="/Users/ricky/.local/bin:$PATH"

# rust
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# golang
[[ -d "/usr/local/go/bin" ]] && export PATH="/usr/local/go/bin:$PATH"
[[ -d "$HOME/go/bin" ]] && export PATH="$HOME/go/bin:$PATH"

# nix-darwin: rebuild the Mac from this flake after editing nix/*
alias rebuild='sudo darwin-rebuild switch --flake "$HOME/.dotfiles#$(whoami)"'

# Local-only env: secrets + machine-specific vars (TERM, tokens). NOT tracked in git.
[[ -f ~/.env.local.zsh ]] && source ~/.env.local.zsh
