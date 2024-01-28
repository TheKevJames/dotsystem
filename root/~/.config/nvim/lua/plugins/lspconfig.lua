-- for debugging LSP issues, set:
-- vim.lsp.set_log_level('trace')

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'          -- autocomplete with <c-x><c-o>

    local opts = { buffer = ev.buf }
    -- vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    -- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    -- vim.keymap.set('n', '<space>wl', function()
    --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    -- end, opts)
    -- vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    -- vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    -- vim.keymap.set('n', '<space>f', function()
    --   vim.lsp.buf.format { async = true }
    -- end, opts)
  end,
})

return {
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
                        -- TODO: why does using ~ break? Should have been fixed in v1.3.1
                        journal_file = "/Users/kevin/sync/finance/index.beancount",
                    },
                },

                -- https://github.com/rcjsuen/dockerfile-language-server
                dockerls = {},

                dotls = {},

                esbonio = {},

                jsonls = {},

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
