return {
    'AndrewRadev/splitjoin.vim',    -- toggle multiline blocks (keymap: gS gJ)
    {
        'kylechui/nvim-surround',     -- modify surrounding data (keymap: cs.. ds. ysiw., yss. / ys$.)
        version = '*',
        opts = {},
    },
    {
        -- TODO: nuke once completion works in lsp client:
        -- https://github.com/polarmutex/beancount-language-server/issues/32
        -- TODO: figure out why the lsp client isn't highlighting
        'nathangrigg/vim-beancount',
    },
}
