-- https://github.com/polarmutex/beancount-language-server
return {
  cmd = { 'beancount-language-server', '--stdio' },
  filetypes = { 'beancount', 'bean' },
  root_markers = { 'index.beancount', '.git' },
  single_file_support = true,
  init_options = {
    journal_file = "~/sync/finance/index.beancount",
  },
}
