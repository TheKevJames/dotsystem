vim.keymap.set('n', '<leader>xx', '<cmd>TroubleToggle<cr>')
vim.keymap.set('n', '<leader>xq', '<cmd>TroubleToggle quickfix<cr>')

return {
    { 'nvim-tree/nvim-web-devicons', },
    {
        'folke/trouble.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
    },
}
