-- https://github.com/python-lsp/python-lsp-server
return {
  cmd = { 'pylsp' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipefile', '.git' },
  single_file_support = true,
}
