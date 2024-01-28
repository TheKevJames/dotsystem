-- for debugging LSP issues, set:
-- vim.lsp.set_log_level('trace')

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
            ensure_installed = {
                "bashls",
                "beancount",
                "dockerls",
                "dotls",
                "esbonio",
                "jsonls",
                "jsonnet_ls",
                -- TODO: nimls
                "pylsp",
                "sqlls",
                "taplo",
                "terraformls",
                "yamlls",
            },
        },
    },
    {
        'neovim/nvim-lspconfig',
        dependencies = { 'williamboman/mason-lspconfig.nvim' },
        -- TODO: set up omnifunc?
        -- https://github.com/neovim/nvim-lspconfig#Suggested-configuration
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
