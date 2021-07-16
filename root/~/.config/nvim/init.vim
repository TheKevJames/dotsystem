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

" netrw configuration
let g:netrw_banner=0       " hide useless banner info
let g:netrw_liststyle=3    " use tree view by default

" avoid unnecessary <shift> for goto
nnoremap ; :

nmap <F3> i<C-R>=strftime("%Y-%m-%d")<CR><Esc>
imap <F3> <C-R>=strftime("%Y-%m-%d")<CR>

filetype plugin indent on  " enable filetype detection
syntax on                  " show syntax highlighting

call plug#begin('~/.local/share/nvim/plugged')

Plug 'morhetz/gruvbox'  " gruvbox

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }  " fzf
Plug 'airblade/vim-gitgutter'                        " git

Plug 'vimwiki/vimwiki'      " wiki
Plug 'tools-life/taskwiki'  " wiki+taskw
Plug 'majutsushi/tagbar'    " task tag nav

Plug 'sheerun/vim-polyglot'  " syntax highlighting

call plug#end()

" plugin configuration
let g:gruvbox_termcolors=16
colorscheme gruvbox

let g:vimwiki_list = [{'path': '~/Dropbox/vimwiki'}, {'path': '~/Dropbox/work/vimwiki'}]
let g:taskwiki_taskrc_location = '~/.config/taskwarrior/taskrc'
command Tm TaskWikiMod
