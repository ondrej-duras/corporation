"
" backup.vim - good-oldies based backup utility
" 20190920, Ing. Ondrej DURAS (dury)
" VERSION=2020.110901

"=vim source backup.vim
"=vim call Backup(".")
"#=vim source $VIM/backup.vim
"# Business Notes
"#=vim call Backup("C:\\usr\\good-oldies")
"# Personal Notes
"#=vim call Backup("C:\\usr\\dury\\good-oldies")

function! Backup(FOLD)
  let EXTENSION=expand("%:e")
  let FILENAME=expand("%:t:r")
  let TIMESTAMP=strftime("%Y%m%d-%H%M%S")
  let FULLNAME=a:FOLD . "/" . FILENAME . "-" . TIMESTAMP . "." . EXTENSION
  silent execute 'write' FULLNAME
  echomsg 'Backup '. FULLNAME . ' written.'
endfunction

if !exists("g:DATA_GOOD")
  let g:DATA_GOOD=".good-oldies/"
endif


" --- end ---

