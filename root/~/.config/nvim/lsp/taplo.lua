-- https://taplo.tamasfe.dev/cli/usage/language-server.html
return {
  cmd = { 'taplo', 'lsp', 'stdio' },
  filetypes = { 'toml' },
  root_markers = { '.git' },
  single_file_support = true,
}
