-- https://github.com/hrsh7th/vscode-langservers-extracted
-- TODO: find a json5 LSP
return {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  init_options = {
    provideFormatter = true,
  },
  root_markers = { '.git' },
  single_file_support = true,
}
