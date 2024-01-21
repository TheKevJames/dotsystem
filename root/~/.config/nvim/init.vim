set clipboard=unnamedplus  " use system clipboard
set expandtab              " spaces > tabs
set hlsearch               " show highlights on search
set laststatus=0           " hide statusline
set foldmethod=expr        " use nvim-treesitter for folding expressions
set foldexpr=nvim_treesitter#foldexpr()
set nofoldenable           " no default folds on startup
set mouse=                 " disable mouse usage
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

let g:python3_host_prog = '~/.local/pipx/venvs/neovim-remote/bin/python3'
let g:node_host_prog = '/opt/local/bin/neovim-node-host'
let g:loaded_ruby_provider = 0
let g:loaded_perl_provider = 0

call plug#begin('~/.local/share/nvim/plugged')

" theme
let g:gruvbox_termcolors=16
Plug 'morhetz/gruvbox'

" git
Plug 'airblade/vim-gitgutter'

" wiki
let g:vimwiki_list = [
  \{'path': '~/sync/work/vimwiki', 'syntax': 'markdown', 'ext': '.md'},
  \{'path': '~/sync/vimwiki', 'syntax': 'markdown', 'ext': '.md'}
\]
Plug 'vimwiki/vimwiki'

" language-specific
"" treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

"" lsp
Plug 'williamboman/mason.nvim', { 'do': ':MasonUpdate' }  " Package Manager
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'

" commenting
Plug 'tpope/vim-commentary'     " gc..

" fuzzy find / navigation
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
Plug 'ggandor/leap.nvim'       " [sS]..

" diagnostics
Plug 'folke/trouble.nvim'
nnoremap <leader>xx <cmd>TroubleToggle<cr>

call plug#end()

" for debugging LSP issues
" lua vim.lsp.set_log_level("trace")

" plugin configuration
colorscheme gruvbox

lua require('cfg-nvim-treesitter')
lua require('mason').setup({})
lua require('cfg-mason-lspconfig')
lua require('cfg-lspconfig')
lua require('leap').add_default_mappings({})
lua require('trouble').setup({ icons = false })

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
