local mason_lspconfig = require 'mason-lspconfig'

-- TODO: nimls
mason_lspconfig.setup {
  ensure_installed = {
    "bashls",
    "beancount",
    "dockerls",
    "dotls",
    "esbonio",
    "jsonls",
    "jsonnet_ls",
    "pylsp",
    "sqlls",
    "taplo",
    "terraformls",
    "yamlls",
  },
};
