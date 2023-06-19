set clipboard=unnamedplus  " use system clipboard
set expandtab              " spaces > tabs
set hlsearch               " show highlights on search
set laststatus=0           " hide statusline
set foldmethod=expr        " use nvim-treesitter for folding expressions
set foldexpr=nvim_treesitter#foldexpr()
set nofoldenable           " no default folds on startup
set number                 " show line numbers
set relativenumber         " line numbers should be relative
set shiftwidth=4           " tabs are 4 spaces
set showmatch              " show matching bracket on insertion
set synmaxcol=512          " set maximum line length for syntax highlighting

" netrw configuration
let g:netrw_banner=0       " hide useless banner info
let g:netrw_liststyle=3    " use tree view by default

" avoid unnecessary <shift> for goto
nnoremap ; :

nmap <F3> i<C-R>=strftime("%Y-%m-%d")<CR><Esc>
imap <F3> <C-R>=strftime("%Y-%m-%d")<CR>

filetype plugin indent on  " enable filetype detection
syntax on                  " show syntax highlighting

let g:python3_host_prog = '~/.local/pipx/venvs/neovim-remote/bin/python3'
let g:node_host_prog = '/opt/local/bin/neovim-node-host'
let g:loaded_ruby_provider = 0
let g:loaded_perl_provider = 0

call plug#begin('~/.local/share/nvim/plugged')

let g:gruvbox_termcolors=16
Plug 'morhetz/gruvbox'  " gruvbox

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }  " fzf
Plug 'airblade/vim-gitgutter'                        " git
Plug 'ggandor/leap.nvim'                             " leap [sS]..

let g:vimwiki_list = [
  \{'path': '~/Dropbox/work/vimwiki', 'syntax': 'markdown', 'ext': '.md'},
  \{'path': '~/Dropbox/vimwiki', 'syntax': 'markdown', 'ext': '.md'}
\]
Plug 'vimwiki/vimwiki'      " wiki

" syntax highlighting
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
let b:beancount_root = '~/Dropbox/finance/index.beancount'
Plug 'nathangrigg/vim-beancount'

Plug 'williamboman/mason.nvim', { 'do': ':MasonUpdate' }  " LSP Package Manager
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'                              " LSP configuration

call plug#end()

" plugin configuration
colorscheme gruvbox

lua <<EOF
  require'nvim-treesitter.configs'.setup {
    ensure_installed = { "bash", "beancount", "dockerfile", "dot", "json", "json5", "make", "python", "regex", "sql", "terraform", "toml", "yaml" },
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
  }

  require'mason'.setup {}
  require'mason-lspconfig'.setup {
    ensure_installed = { "bashls", "beancount", "dockerls", "docker_compose_language_service", "dotls", "esbonio", "jsonls", "pylsp", "sqlls", "taplo", "terraformls", "yamlls" },
  }
  require'lspconfig'.bashls.setup {}
  require'lspconfig'.beancount.setup {}
  require'lspconfig'.dockerls.setup {}
  require'lspconfig'.docker_compose_language_service.setup {}
  require'lspconfig'.dotls.setup {}
  require'lspconfig'.esbonio.setup {}
  require'lspconfig'.jsonls.setup {}
  require'lspconfig'.pylsp.setup {}
  require'lspconfig'.sqlls.setup {}
  require'lspconfig'.taplo.setup {}
  require'lspconfig'.terraformls.setup {}
  require'lspconfig'.yamlls.setup {}

  require'leap'.add_default_mappings()
EOF

function! VimwikiLinkHandler(link)
  " Use Vim to open external files with the 'vfile:' scheme.  E.g.:
  "   1) [[vfile:~/src/foo/bar.py]]
  "   2) [[vfile:./|Wiki Home]]
  let link = a:link
  if link =~# '^vfile:'
    let link = link[1:]
  else
    return 0
  endif
  let link_infos = vimwiki#base#resolve_link(link)
  if link_infos.filename == ''
    echomsg 'Vimwiki Error: Unable to resolve link!'
    return 0
  else
    exe 'tabnew ' . fnameescape(link_infos.filename)
    return 1
  endif
endfunction
