-- for debugging LSP issues, set:
-- vim.lsp.set_log_level('trace')
vim.lsp.set_log_level('off')

-- this gets run when an LSP connects to a particular buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),

  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufnr = args.buf

    -- autocomplete with <c-x><c-o>
    if client.server_capabilities.completionProvider then
      vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
    end

    -- https://neovim.io/doc/user/tagsrch.html#tag-commands
    if client.server_capabilities.definitionProvider then
      vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
    end

    -- if client.server_capabilities.inlayHintProvider then
    --   vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    -- end

    local opts = { buffer = bufnr }
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

vim.api.nvim_create_autocmd("LspDetach", {
  callback = function(_)
    vim.cmd("setlocal tagfunc< omnifunc<")
  end,
})

vim.g.beancount_account_completion = "default"
vim.g.beancount_detailed_first = 1

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
      ensure_installed = {
        -- :MasonInstall beancount-language-server@1.3.3
        -- https://github.com/polarmutex/beancount-language-server/issues/32
        "beancount@1.3.3",
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'williamboman/mason-lspconfig.nvim' },
    config = function(_, opts)
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      for server, server_opts in pairs(opts.servers) do
        require('lspconfig')[server].setup(vim.tbl_deep_extend(
          'keep',
          server_opts,
          {
            capabilities = capabilities,
          }
        ))
      end
    end,
    opts = {
      inlay_hints = {
        enabled = false,
      },
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
              hint = {
                enable = false
              },
              telemetry = {
                enable = false,
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
