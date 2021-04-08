"
" _VIMRC - Common VIM Configuration File for Windows x86 platform
" 20140625, Ing. Ondrej DURAS (dury)
" $VIM\_vimrc
" VERSION=2021.040701

set noswapfile
set ruler
set nowrap
syntax clear
language us_US
set noautoindent
set backspace=indent,eol,start
set nocompatible
"redraw
set clipboard=unnamed
high Underlined ctermfg=brown ctermbg=black
let @d="#=vim source \$VIM/itn-dc.vim"
let @e="# --- end ---"

function! TypoEncryptedHide()
if strlen(&key) > 0
 highlight Normal ctermfg=darkblue ctermbg=black
 set viminfo=
 set nobackup
 set noswapfile
 set cryptmethod=blowfish
else 
 highlight Normal ctermfg=grey ctermbg=black
endif
endfunction
autocmd BufReadPost * :call TypoEncryptedHide()


"highlight Normal ctermfg=brown ctermbg=black
nmap <f1> :source $VIM/dury.vim<cr>
"nmap <f1> :source dury.vim<cr>
nmap <f2> :set foldmethod=manual<cr>zE:syntax clear<cr>

" TAB handling
nmap <f8>   :tabnext<cr>
nmap <f7>   :tabprev<cr>
nmap <s-f8> :tabnew<cr>:Explore<cr>
high TabLine     cterm=none ctermfg=grey  ctermbg=darkblue
high TabLineSel  cterm=none ctermfg=white ctermbg=darkcyan
high TabLineFill cterm=none ctermfg=grey  ctermbg=darkblue

" Slovencina, Rustina v GVIM
" :call Utf8()
" ftp://ftp.vim.org/pub/vim/pc/gvim73_46.zip
function! Utf8()
  set enc=utf-8
  set fileencoding=utf-8
  ""pre Rustinu
  "set guifont=Courier_New:h14:cRUSSIAN
  ""pre slovenske texty
  set guifont=Courier_New:h10:cRUSSIAN
  color desert
" !start osk.exe ... zavolanie vizualnej klavesnice
endfunction

if has("gui_running")
  "UTF-8/RU and colorscheme
  call Utf8()
  "no menu, no toolbar & 140x40
  set guioptions-=T
  set guioptions-=m
  set columns=140 lines=40
endif
" --- end ---


