augroup ftdetect_terraform
  autocmd!
  autocmd BufNewFile,BufRead *.tfvars setlocal filetype=tf
augroup END
