augroup ftdetect_ruby
  autocmd!
  autocmd BufNewFile,BufRead *.pp setlocal filetype=ruby
  autocmd FileType ruby setlocal shiftwidth=2
augroup END
