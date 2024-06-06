-- for debugging LSP issues, set:
-- vim.lsp.set_log_level('trace')
vim.lsp.set_log_level('off')

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc' -- autocomplete with <c-x><c-o>

    -- TODO: enable more?
    -- https://github.com/neovim/nvim-lspconfig#Suggested-configuration
    local opts = { buffer = ev.buf }
    -- TODO: might need keymap for https://gpanders.com/blog/whats-new-in-neovim-0.10/#lsp-inlay-hints
    vim.keymap.set('n', '<leader>gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>cf', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

return {
  {
    -- TODO: nuke once completion works in lsp client:
    -- https://github.com/polarmutex/beancount-language-server/issues/32
    -- TODO: figure out why the lsp client isn't highlighting
    'nathangrigg/vim-beancount',
  },
  {
    'williamboman/mason.nvim',
    build = ':MasonUpdate',
    lazy = false,
    config = true,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    opts = {
      automatic_installation = true,
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'williamboman/mason-lspconfig.nvim' },
    config = function(_, opts)
      for server, server_opts in pairs(opts.servers) do
        require('lspconfig')[server].setup(vim.tbl_deep_extend(
          'keep',
          server_opts,
          {
            capabilities = capabilities,
            on_attach = on_attach,
          }
        ))
      end
    end,
    opts = {
      servers = {
        -- https://github.com/bash-lsp/bash-language-server
        bashls = {},

        -- https://github.com/polarmutex/beancount-language-server
        beancount = {
          init_options = {
            journal_file = "~/sync/finance/index.beancount",
          },
        },

        -- https://github.com/rcjsuen/dockerfile-language-server
        dockerls = {},

        dotls = {},

        esbonio = {},

        -- TODO: find a json5 LSP
        -- https://github.com/hrsh7th/vscode-langservers-extracted
        jsonls = {},

        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                -- TODO: make this conditional, eg. only in neovim config files
                globals = { 'vim' },
              },
            },
          },
        },

        marksman = {},

        -- TODO: one of the following, once I switch to choosenim
        -- nim_langserver = {},
        -- nimls = {},

        pylsp = {},

        sqlls = {},

        taplo = {},

        terraformls = {},

        -- https://github.com/redhat-developer/yaml-language-server
        yamlls = {
          settings = {
            yaml = {
              schemaStore = {
                enable = true,
                url = "https://www.schemastore.org/api/json/catalog.json",
              },
              validate = true,
            },
          },
        },
      },
    },
  },
}
