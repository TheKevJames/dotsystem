vim.o.termguicolors = true
vim.o.background = 'dark'
vim.g.gruvbox_material_background = 'medium'            -- soft, medium, hard
vim.g.gruvbox_material_foreground = 'material'          -- material, mix, original
vim.g.gruvbox_material_better_performance = 1
vim.g.gruvbox_material_diagnostic_line_highlight = 1
vim.g.gruvbox_material_disable_italic_comment = 1

return {
    -- {
    --     'gruvbox-community/gruvbox',
    --     config = function()
    --         vim.cmd([[colorscheme gruvbox]])
    --     end,
    -- },
    {
        'sainnhe/gruvbox-material',
        lazy = false,
        config = function()
            vim.cmd([[colorscheme gruvbox-material]])
        end,
    },
}
