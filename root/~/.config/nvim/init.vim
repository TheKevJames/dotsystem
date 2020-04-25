set clipboard=unnamedplus  " use system clipboard
set expandtab              " spaces > tabs
set hlsearch               " show highlights on search
set laststatus=0           " hide statusline
set nofoldenable           " no default folds on startup
set number                 " show line numbers
set relativenumber         " line numbers should be relative
set shiftwidth=4           " tabs are 4 spaces
set showmatch              " show matching bracket on insertion
set synmaxcol=512          " set maximum line length for syntax highlighting
set tags=.git/tags         " hide ctags in `.git` folder
set termguicolors          " enable true color support

" netrw configuration
let g:netrw_banner=0       " hide useless banner info
let g:netrw_liststyle=3    " use tree view by default

" avoid unnecessary <shift> for goto
nnoremap ; :

filetype plugin indent on  " enable filetype detection
syntax on                  " show syntax highlighting

call plug#begin('~/.local/share/nvim/plugged')

Plug 'morhetz/gruvbox'  " gruvbox

Plug 'junegunn/fzf', { 'do': './install --bin' }  " fzf
Plug 'airblade/vim-gitgutter'                     " git

Plug 'vimwiki/vimwiki'  " wiki
Plug 'tbabej/taskwiki'  " wiki + taskwarrior

Plug 'elixir-editors/vim-elixir', { 'for': 'elixir' }  " Elixir syntax
Plug 'rust-lang/rust.vim', { 'for': 'rust' }           " Rust syntax

call plug#end()

" plugin configuration
colorscheme gruvbox
let g:taskwiki_data_location="~/.local/share/taskwarrior"
let g:vimwiki_list = [{'path': '~/Dropbox/vimwiki'}, {'path': '~/Dropbox/work/vimwiki'}]
