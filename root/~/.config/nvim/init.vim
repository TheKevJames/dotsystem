set expandtab       " spaces > tabs
set hlsearch        " show highlights on search
set laststatus=0    " hide statusline
set number          " show line numbers
set relativenumber  " line numbers should be relative
set shiftwidth=4    " tabs are 4 spaces
set showmatch       " show matching bracket on insertion

filetype plugin indent on  " enable filetype detection
syntax on                  " show syntax highlighting

call plug#begin('~/.local/share/nvim/plugged')

Plug 'airblade/vim-gitgutter'  " git

" Plug 'neomake/neomake'  " async :make
" Plug 'pgdouyon/vim-accio'  " async :make -- light-weight, linting-focus?

Plug 'vimwiki/vimwiki'  " wiki

" Plug 'mhinz/vim-grepper'  " async grep w/ tool support

Plug 'rust-lang/rust.vim', { 'for': 'rust' }  " Rust syntax

call plug#end()

" plugin configuration
let g:vimwiki_list = [{'path': '~/Dropbox/vimwiki'}]
