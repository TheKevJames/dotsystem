return {
    'AndrewRadev/splitjoin.vim',                -- toggle multiline blocks (keymap: gS gJ)
    'tpope/vim-commentary',                     -- comments (keymap: gc..)
    'tpope/vim-surround',                       -- modify surrounding data (keymap: cs.. ds. yss.)
    {
        -- TODO: nuke once completion works in lsp client:
        -- https://github.com/polarmutex/beancount-language-server/issues/32
        -- TODO: figure out why the lsp client isn't highlighting
        'nathangrigg/vim-beancount',
    },
}
