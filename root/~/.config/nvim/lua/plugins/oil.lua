vim.keymap.set('n', '<leader>e', '<cmd>Oil<cr>')

return {
  'stevearc/oil.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    default_file_explorer = true,
    view_options = {
      show_hidden = false,
      is_hidden_file = function(name, bufnr)
        local HIDE = {
          ['__pycache__'] = true,
          ['.mypy_cache'] = true,
          ['..'] = true,
        }
        if (HIDE[name] == true) then return true end
        return false
      end,
    },
  },
}
