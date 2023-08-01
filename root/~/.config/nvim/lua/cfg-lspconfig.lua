local lspconfig = require 'lspconfig'

lspconfig.bashls.setup {};

-- https://github.com/polarmutex/beancount-language-server
lspconfig.beancount.setup {
  capabilities = capabilities,
  on_attach = on_attach,
  init_options = {
    -- TODO: why does using ~ break? Should have been fixed in v1.3.1
    journal_file = "/Users/kevin/sync/finance/index.beancount",
  },
};

lspconfig.dockerls.setup {
  capabilities = capabilities,
  on_attach = on_attach,
};

lspconfig.dotls.setup {
  capabilities = capabilities,
  on_attach = on_attach,
};

lspconfig.esbonio.setup {
  capabilities = capabilities,
  on_attach = on_attach,
};

lspconfig.jsonls.setup {
  capabilities = capabilities,
  on_attach = on_attach,
};

lspconfig.pylsp.setup {
  capabilities = capabilities,
  on_attach = on_attach,
};

lspconfig.sqlls.setup {
  capabilities = capabilities,
  on_attach = on_attach,
};

lspconfig.taplo.setup {
  capabilities = capabilities,
  on_attach = on_attach,
};

lspconfig.terraformls.setup {
  capabilities = capabilities,
  on_attach = on_attach,
};

-- https://github.com/redhat-developer/yaml-language-server
lspconfig.yamlls.setup {
  settings = {
    yaml = {
      schemaStore = {
        enable = true,
        url = "https://www.schemastore.org/api/json/catalog.json",
      },
      validate = true,
    },
  },
};
