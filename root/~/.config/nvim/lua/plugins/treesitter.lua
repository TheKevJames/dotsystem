return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {
        auto_install = true,
        ensure_installed = {
            "bash",
            "beancount",
            "dockerfile",
            "dot",
            "json",
            "json5",
            "jsonnet",
            "lua",
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
}
