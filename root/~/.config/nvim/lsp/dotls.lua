-- https://github.com/nikeee/dot-language-server
return {
  cmd = { 'dot-language-server', '--stdio' },
  filetypes = { 'dot' },
  root_markers = { '.git' },
  single_file_support = true,
}
