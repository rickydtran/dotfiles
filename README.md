# ricky's dotfiles

## Installation

Run this command in bash:

```shell
if command -v curl >/dev/null 2>&1; then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/rickydtran/dotfiles/refs/heads/main/bootstrap.sh)"
else
    bash -c "$(wget -O- https://raw.githubusercontent.com/rickydtran/dotfiles/refs/heads/main/bootstrap.sh)"
fi
```
