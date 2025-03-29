-- https://github.com/luals/lua-language-server
-- TODO: consider setting on_init to load neovim directory
return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
  single_file_support = true,
  log_level = vim.lsp.protocol.MessageType.Warning,
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
}
