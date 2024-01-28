return {
    {
        'ggandor/leap.nvim',
        config = function()
            require('leap').add_default_mappings({})            -- jump (keymap: [sS]..)
        end,
    },
}
