augroup ftdetect_json
  autocmd!
  autocmd BufNewFile,BufRead *.json set filetype=json
  autocmd FileType json setlocal shiftwidth=2
augroup END
