"
" Ricky Tran
" Neovim config: drop-in reuse of the existing vim setup.
"
" Neovim's default config path is ~/.config/nvim/init.vim. Rather than maintain a
" second config, we put ~/.vim on the runtimepath and source ~/.vimrc verbatim.
" This makes nvim share the same settings AND the same vim-plug plugin install
" under ~/.vim/plugged - one source of truth for both vim and nvim.
"
" See :help nvim-from-vim for the canonical form of this shim.

set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
