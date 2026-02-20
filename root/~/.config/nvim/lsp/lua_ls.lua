-- https://github.com/luals/lua-language-server
return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
  single_file_support = true,
  log_level = vim.lsp.protocol.MessageType.Warning,
  settings = {
    Lua = {
      diagnostics = {
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
}
