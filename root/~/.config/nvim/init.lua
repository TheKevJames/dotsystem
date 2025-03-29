local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath) -- load lazy.nvim

vim.opt.clipboard:append { 'unnamed', 'unnamedplus' }  -- use system clipboard and linux selection clipboard

-- TODO: unbreak highlighting for languages without lsps
vim.o.hlsearch = true   -- show highlights on search
vim.o.laststatus = 0    -- hide statusline
vim.o.lazyredraw = true -- disable redrawing during macros
vim.o.mouse = ""        -- disable mouse usage
vim.o.showmatch = true  -- show matching bracket on insertion
vim.o.synmaxcol = 512   -- set maximum line length for syntax highlighing

-- TODO: detect from file, when possible
vim.o.expandtab = true -- spaces > tabs
vim.o.shiftwidth = 4   -- tabs are 4 spaces by default
vim.o.softtabstop = 4  -- tabs are 4 spaces by default

-- TODO: change method for languages without treesitter?
-- https://www.vimfromscratch.com/articles/vim-folding
vim.o.foldexpr = 'nvim_treesitter#foldexpr()' -- use nvim-treesitter for folding expressions
vim.o.foldmethod = 'expr'
vim.o.foldenable = false                      -- no default folds at startup
vim.o.foldlevelstart = 99                     -- when enabling folding, don't autofold others

vim.o.number = true                           -- show line numbers
vim.o.relativenumber = true                   -- line numbers should be relative
vim.o.winborder = 'rounded'                   -- enable rounded borders in floating windows

vim.diagnostic.config({
  -- TODO: do I like this?
  virtual_lines = true                        -- show diagnostic text as virtual lines
  -- virtual_text = { current_line = true }      -- show diagnostic text inline, only when on current line
})

vim.g.netrw_banner = 0                        -- hide useless banner info
vim.g.netrw_liststyle = 3                     -- use tree view by default

vim.filetype.add({
  extension = {
    pp = "ruby",
    tfvars = "terraform",
  }
})

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
-- npm install -g neovim
-- vim.g.node_host_prog = "$(npm root -g)/neovim/bin/cli.js"
vim.g.node_host_prog = '~/.local/share/npm/lib/node_modules/neovim/bin/cli.js'
-- pipx install nvr
vim.g.python3_host_prog = '~/.local/pipx/venvs/neovim-remote/bin/python3'

vim.keymap.set('n', ';', ':')        -- avoid hitting <shift>
vim.keymap.set('n', '<space>', 'za') -- toggle current fold with <space>
vim.keymap.set('n', ',', ':noh<cr>') -- hide highlights

-- ctrl-n: next, ctrl-p: previous, ctrl-y: yes, ctrl-e: exit
vim.cmd('set completeopt+=fuzzy,noinsert')  -- require keypress (ctrl-y) to autocomplete, support fuzzy matches

require('lazy').setup('plugins')
