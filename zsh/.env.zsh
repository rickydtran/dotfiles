# uv
export PATH="/Users/ricky/.local/bin:$PATH"

# rust
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# golang
[[ -d "/usr/local/go/bin" ]] && export PATH="/usr/local/go/bin:$PATH"
[[ -d "$HOME/go/bin" ]] && export PATH="$HOME/go/bin:$PATH"
