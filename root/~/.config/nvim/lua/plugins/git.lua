vim.keymap.set('n', '<leader>gb', '<cmd>Gitsigns toggle_current_line_blame<cr>')
vim.keymap.set('n', '<leader>go', ':!open $(git url)/%\\#L<C-R>=line(".")<CR><CR>')

return {
  {
    'lewis6991/gitsigns.nvim',
    config = true,
  },
  -- {
  --   'pwntester/octo.nvim',
  --   dependencies = {
  --     'nvim-lua/plenary.nvim',
  --     'nvim-telescope/telescope.nvim',
  --     'nvim-tree/nvim-web-devicons',
  --   },
  --   opts = {
  --     -- TODO: why does my token keep losing this scope?
  --     suppress_missing_scope = {
  --       projects_v2 = true,
  --     },
  --   },
  -- },
}
