vim.keymap.set('n', '<leader>gb', '<cmd>Gitsigns toggle_current_line_blame<cr>')
vim.keymap.set('n', '<leader>go', ':!open $(git url)/%\\#L<C-R>=line(".")<CR><CR>')

return {
  {
    'lewis6991/gitsigns.nvim',
    config = true,
  },
}
