return {
  -- TODO: remove this once treesitter highlighting supports beancount
  { 'nathangrigg/vim-beancount' },
  -- TODO: remove this once the LSP supports completion
  -- https://github.com/polarmutex/beancount-language-server/issues/32
  {
    'hrsh7th/nvim-cmp',
    dependencies = { 'crispgm/cmp-beancount' },
    opts = function(_, opts)
      local cmp = require('cmp')

      return {
        completion = { completeopt = 'menu,popup,fuzzy,noinsert' },
        mapping = {
          ['<C-e>'] = cmp.mapping.abort(),
          ['<C-y>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select   = true,
          }),
          ['<C-n>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<C-p>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
          end,
        },
        sources = cmp.config.sources({
          -- TODO: why would we do this? nvim lsp already does the same
          -- completion...
          -- { name = 'nvim_lsp' },
          {
            name = 'beancount',
            option = {
              account = '~/sync/finance/index.beancount',
            },
          },
        }),
        window = {
          -- completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      }
    end,
  },
  { 'crispgm/cmp-beancount' },
}
