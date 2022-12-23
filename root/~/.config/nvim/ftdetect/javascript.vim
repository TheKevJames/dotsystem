augroup ftdetect_javascript
  autocmd!
  autocmd BufNewFile,BufRead *.js set filetype=javascript
  autocmd FileType javascript setlocal shiftwidth=2
augroup END
