"
" Ricky Tran
" Vim Settings

set nocompatible

" Settings in this file depend on plugins
" Utilzing vim-plug (Plugin Manager)
" Vim-plug Automatic Installation
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

" Specify a directory for plugins
call plug#begin('~/.vim/plugged')
" Initialize plugin system
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'bling/vim-bufferline'
Plug 'kien/ctrlp.vim'
Plug 'scrooloose/nerdtree'
Plug 'christoomey/vim-tmux-navigator'
Plug 'joshdick/onedark.vim'
Plug 'Cognoscan/vim-vhdl'
" Plug 'scrooloose/syntastic'
call plug#end()

" Key Mappings
let mapleader="<space>"
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
inoremap jk <esc>
" inoremap <esc> <nop>
map <c-n> :NERDTreeToggle<cr>
map <c-a> <esc>ggVG$<cr>

" Settings
syntax enable
silent! colorscheme onedark
" set noeb vb t_vb= " Disables chime
set noerrorbells novisualbell " Turn off visual and audbile bells
set nobackup nowritebackup noswapfile " Turn off backup files
set nowrap " Don't wrap long lines
set listchars=extends:→ " Show arrow if line continues rightwards
set listchars+=precedes:← " Show arrow if line continues leftwards
set laststatus=2 " Show status line on startup
set autoread " Auto reload changed files
set wildmenu " Tab autocmplete in command mode
set backspace=indent,eol,start " Make backspace actually work as backspace
set splitright " Open new splits to the right
set splitbelow " Open new splits to the bottom
set showmatch " Match brackets
set lazyredraw " Reduce redraw frequency
set ttyfast " Send more chracters in fast terminals
set autoindent " auto indent
set expandtab " Use spaces
set shiftwidth=4 " 4 spaces for tab
set tabstop=4 " 4 spaces for tab
set hlsearch " Highlight search results
set ignorecase smartcase " Search queries intelligently set case
set incsearch " Show Results as you type
set number " Line numbers
" set cursorline " Highlight current line
set showcmd " Show size of visual selection

" Syntastic Settings
" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*
" let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
" let g:syntastic_check_on_open = 1
" let g:syntastic_check_on_wq = 0
" let g:syntastic_vhdl_checkers= ['vhdltool']

let g:airline_theme='onedark'
" let g:airline_solarized_bg='light'
