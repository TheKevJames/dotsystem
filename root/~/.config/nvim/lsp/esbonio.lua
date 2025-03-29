-- https://github.com/swyddfa/esbonio
-- TODO: only start esbonio in sphinx projects
return {
  cmd = { 'esbonio' },
  filetypes = { 'rst' },
  root_markers = { 'conf.py', '.git' },
}
