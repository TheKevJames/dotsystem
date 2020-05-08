augroup filetype_yaml
    autocmd!
    autocmd BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml foldmethod=indent
    autocmd FileType yaml |
        setlocal shiftwidth=2 |
        setlocal softtabstop=2 |
        setlocal tabstop=2 |
        setlocal indentkeys-=0# |
        setlocal indentkeys-=<:>
augroup END
