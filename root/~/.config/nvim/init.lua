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

vim.opt.rtp:prepend(lazypath)           -- load lazy.nvim

-- TODO: unbreak highlighitng for languages without lsps
vim.o.clipboard = 'unnamedplus'         -- use system clipboard
vim.o.hlsearch = true                   -- show highlights on search
vim.o.laststatus = 0                    -- hide statusline
vim.o.lazyredraw = true                 -- disable redrawing during macros
vim.o.mouse = false                     -- disable mouse usage
vim.o.showmatch = true                  -- show matching bracket on insertion
vim.o.synmaxcol = 512                   -- set maximum line length for syntax highlighing

-- TODO: detect from file, when possible
-- TODO: verify overridden in relevant languages
vim.o.expandtab = true          -- spaces > tabs
vim.o.shiftwidth = 4            -- tabs are 4 spaces by default

-- TODO: change method for languages without treesitter?
-- https://www.vimfromscratch.com/articles/vim-folding
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'   -- use nvim-treesitter for folding expressions
vim.o.foldmethod = 'expr'
vim.o.foldenable = false                        -- no default folds at startup
vim.o.foldlevelstart = 99                       -- when enabling folding, don't autofold others

vim.o.number = true             -- show line numbers
vim.o.relativenumber = true     -- line numbers should be relative

vim.g.netrw_banner = 0          -- hide useless banner info
vim.g.netrw_liststyle = 3       -- use tree view by default

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.node_host_prog = '/opt/local/bin/neovim-node-host'
vim.g.python3_host_prog = '~/.local/pipx/venvs/neovim-remote/bin/python3'

vim.keymap.set('n', ';', ':')           -- avoid hitting <shift>
vim.keymap.set('n', '<space>', 'za')    -- toggle current fold with <space>
vim.keymap.set('n', ',', ':noh<cr>')    -- hide highlights
-- E/W                  --> e/w but space separated
-- ctrl+t / ctrl+d      --> indent / de-indent (insert mode)
-- g;                   --> jump to last edit
-- #                    --> opposite of *

require('lazy').setup('plugins')
