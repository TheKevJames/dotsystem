augroup ftdetect_javascript
  autocmd!
  autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
  autocmd FileType javascript setlocal shiftwidth=2
augroup END
