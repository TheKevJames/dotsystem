vim.keymap.set('n', '<leader>e', '<cmd>Oil<cr>')

return {
    {
        'stevearc/oil.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = {
            default_file_explorer = true,
            view_options = {
                show_hidden = false,
                is_hidden_file = function(name, bufnr)
                    local HIDE = {
                        ['__pycache__'] = true
                    }
                    if (HIDE[name] == true) then return true end
                    if not (vim.startswith(name, '.')) then return false end

                    local SHOW = {
                        ['..'] = false,
                        ['.circleci'] = true,
                        ['.dockerignore'] = true,
                        ['.git'] = false,
                        ['.gitignore'] = true,
                        ['.github'] = true,
                        ['.mypy_cache'] = false,
                        ['.pre-commit-config.yaml'] = true,
                    }
                    if (SHOW[name] == true) then return false end
                    if (SHOW[name] == nil) then print('Set SHOW for:', name) end
                    return true
                end,
            },
        },
    },
}
