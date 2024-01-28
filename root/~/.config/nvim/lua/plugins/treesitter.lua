return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        opts = {
            ensure_installed = {
                "bash",
                "beancount",
                "dockerfile",
                "dot",
                "json",
                "json5",
                "jsonnet",
                "make",
                "python",
                "regex",
                "sql",
                "terraform",
                "toml",
                "yaml",
            },
            highlight = {
                enable = true,
            },
            indent = {
                enable = true,
            },
        },
    },
}
