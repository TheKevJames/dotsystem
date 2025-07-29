-- for debugging LSP issues, set:
-- vim.lsp.set_log_level('trace')
vim.lsp.set_log_level('off')

-- this gets run when an LSP connects to a particular buffer
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local bufnr = ev.buf

    -- enable auto-completion from supported LSPs
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end

    -- support :tags
    -- go to definiton: ctrl+] / <leader>gd
    -- jump back: ctrl+t
    -- https://neovim.io/doc/user/tagsrch.html#tag-commands
    if client.server_capabilities.definitionProvider then
      vim.bo[bufnr].tagfunc = 'v:lua.vim.lsp.tagfunc'
    end

    -- enable inlay hints
    if client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end

    -- set my prefered keymaps
    local opts = { buffer = bufnr }
    vim.keymap.set('n', '<leader>gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>cf', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

vim.api.nvim_create_autocmd('LspDetach', {
  callback = function(_)
    vim.cmd('setlocal tagfunc< omnifunc<')
  end,
})

vim.g.beancount_account_completion = 'default'
vim.g.beancount_detailed_first = 1

-- TODO: can we just load everything from lsp/* ?
-- TODO: switch to choosenim, then use nimls or nim_langserver
vim.lsp.enable({
  'bashls',
  'beancount',
  'docker_compose_language_service',
  'dockerls',
  'dotls',
  'esbonio',
  'jsonls',
  'lua_ls',
  'marksman',
  'pylsp',
  'sqlls',
  'taplo',
  'terraformls',
  'yamlls',
})

return {
  {
    'mason-org/mason.nvim',
    version = '^1.0.0',  -- TODO: unpin once v2 is fixed (TODO: what broke?)
    build = ':MasonUpdate',
    lazy = false,
    config = true,
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'mason-org/mason.nvim' },
    opts = {
      -- https://github.com/williamboman/mason-lspconfig.nvim/blob/main/lua/mason-lspconfig/mappings/server.lua
      ensure_installed = {
        -- LSP
        'bash-language-server',            -- bashls
        'beancount-language-server',       -- beancount
        'docker-compose-language-service', -- docker_compose_language_service
        'dockerfile-language-server',      -- dockerls
        'dot-language-server',             -- dotls
        'esbonio',
        'json-lsp',                        -- jsonls
        'lua-language-server',             -- lus_ls
        'marksman',
        'python-lsp-server',               -- pylsp
        'sqlls',
        'taplo',
        'terraform-ls',                    -- terraformls
        'yaml-language-server',            -- yamlls
      },
    },
  },
}
