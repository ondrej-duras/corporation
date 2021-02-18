"
" DURY.VIM - My Personal VIM Configuration - Windows Version
" 20140625, Ing. Ondrej DURAS (dury)
" $VIM/dury.vim
" VERSION=2017.100501
" VERSION=2021.021701
"
" Common Variables & Settings ######################################### {{{ 1

"let AUTHOR="Ing. Ondrej DURAS, +421-2-692-57912  ATT"
let AUTHOR="Ing. Ondrej DURAS, OSK 0905-012-888"
let COMMENTOR="#"
let FOLDMARKS=70
let EXTENSION=tolower(expand("%:e"))

if EXTENSION=="cpp" || EXTENSION=="c" || EXTENSION=="pov"
    let COMMENTOR="//"
elseif EXTENSION=="s" || EXTENSION=="asm" || EXTENSION=="ini"
    let COMMENTOR=";"
elseif EXTENSION=="ps" || EXTENSION=="eps"
    let COMMENTOR="%"
elseif EXTENSION=="vim"
    let COMMENTOR='"'
endif


highlight XVimSepar ctermfg=green ctermbg=black
highlight XVimGood  ctermfg=brown ctermbg=black
highlight XVimWarn  ctermfg=white ctermbg=red

" ##################################################################### }}} 1
" Line Markers ######################################################## {{{ 1

function! TypoMarkersOFF()
 syntax clear XMarkRed
 syntax clear XMarkGreen
 syntax clear XMarkBlue
 syntax clear XMarkMagenta
 syntax clear XMarkYellow
 syntax clear XMarkBrown
 syntax clear XMarkCyan
 syntax clear XMarkTodo
endfunction 

function! TypoMarkersPlain()
 syntax match XMarkRed     /^.* <<<.*$/
 syntax match XMarkRed     /^.* <<1.*$/
 syntax match XMarkGreen   /^.* <<+.*$/
 syntax match XMarkGreen   /^.* <<2.*$/
 syntax match XMarkBlue    /^.* <<-.*$/
 syntax match XMarkBlue    /^.* <<4.*$/
 syntax match XMarkMagenta /^.* <<!.*$/
 syntax match XMarkMagenta /^.* <<5.*$/
 syntax match XMarkYellow  /^.* <<&.*$/
 syntax match XMarkYellow  /^.* <<0.*$/
 syntax match XMarkBrown   /^.* <<#.*$/
 syntax match XMarkBrown   /^.* <<3.*$/
 syntax match XMarkCyan    /^.* <<%.*$/
 syntax match XMarkCyan    /^.* <<6.*$/
 syntax match XMarkSecret  /^.* #\..*$/
 syntax match XMarkTodo    /^#>.*$/
 syntax match XMarkTypo    /^#=vim.*$/
 syntax match XMarkSecret  /^#=secret.*$/
 syntax cluster XMark contains=XMarkRed,XMarkGreen,XMarkBlue,XMarkMagenta
 syntax cluster XMark add=XMarkYellow,XMarkBrown,XMarkCyan,XMarkTodo,XMarkTypo
endfunction

function! TypoMarkersCommentor()
 let l:XCOMMENTOR=substitute(g:COMMENTOR,'\/','\\\/','g')
 execute 'syntax match XMarkRed     /^.*'.l:XCOMMENTOR.'<<.*$/'
 execute 'syntax match XMarkRed     /^.*'.l:XCOMMENTOR.'<1.*$/'
 execute 'syntax match XMarkGreen   /^.*'.l:XCOMMENTOR.'<+.*$/'
 execute 'syntax match XMarkGreen   /^.*'.l:XCOMMENTOR.'<2.*$/'
 execute 'syntax match XMarkBlue    /^.*'.l:XCOMMENTOR.'<-.*$/'
 execute 'syntax match XMarkBlue    /^.*'.l:XCOMMENTOR.'<4.*$/'
 execute 'syntax match XMarkMagenta /^.*'.l:XCOMMENTOR.'<!.*$/'
 execute 'syntax match XMarkMagenta /^.*'.l:XCOMMENTOR.'<5.*$/'
 execute 'syntax match XMarkYellow  /^.*'.l:XCOMMENTOR.'<&.*$/'
 execute 'syntax match XMarkYellow  /^.*'.l:XCOMMENTOR.'<0.*$/'
 execute 'syntax match XMarkBrown   /^.*'.l:XCOMMENTOR.'<#.*$/'
 execute 'syntax match XMarkBrown   /^.*'.l:XCOMMENTOR.'<3.*$/'
 execute 'syntax match XMarkCyan    /^.*'.l:XCOMMENTOR.'<%.*$/'
 execute 'syntax match XMarkCyan    /^.*'.l:XCOMMENTOR.'<6.*$/'
 execute 'syntax match XMarkSecret  /^.*'.l:XCOMMENTOR.'\..*$/'
 execute 'syntax match XMarkTodo    /^.*'.l:XCOMMENTOR.'>.*$/'
 execute 'syntax match XMarkTypo    /^.*'.l:XCOMMENTOR.'=vim.*$/'
 execute 'syntax match XMarkSecret  /^.*'.l:XCOMMENTOR.'=secret.*$/'
 execute 'syntax cluster XMark contains=XMarkRed,XMarkGreen,XMarkBlue,XMarkMagenta'
 execute 'syntax cluster XMark add=XMarkYellow,XMarkBrown,XMarkCyan,XMarkTodo,XMarkTypo'
endfunction

function! TypoMarkersColors()
 high XMarkRed     ctermfg=white  ctermbg=red
 high XMarkGreen   ctermfg=white  ctermbg=darkgreen
 high XMarkBlue    ctermfg=white  ctermbg=darkblue
 high XMarkMagenta ctermfg=white  ctermbg=darkmagenta
 high XMarkYellow  ctermfg=yellow ctermbg=black
 high XMarkBrown   ctermfg=white  ctermbg=brown
 high XMarkCyan    ctermfg=white  ctermbg=darkcyan
 high XMarkTodo    ctermfg=black  ctermbg=yellow   
 high XMarkTypo    ctermfg=darkmagenta ctermbg=black
 high XMarkSecret  ctermfg=darkblue    ctermbg=black
endfunction


function! TypoMarkersON()
 if g:EXTENSION=="txt"  || g:EXTENSION=="text" || g:EXTENSION==""
    call TypoMarkersPlain()
 else
    call TypoMarkersCommentor()
 endif
 call TypoMarkersColors()
endfunction

" ##################################################################### }}} 1
" Typo ON/OFF by F1/F2 ################################################ {{{ 1
function! TypoConfigON()
 syntax clear
 syntax on
 set ruler
 set nowrap
 language us_US
 set noautoindent
 set backspace=indent,eol,start
 set nocompatible
 set hlsearch
 redraw
 set clipboard=unnamed
 set foldmethod=marker
 set foldmarker={{{,}}}

 highlight Normal  ctermfg=grey     ctermbg=black
 highlight Search  ctermfg=yellow   ctermbg=darkred
 highlight Folded  ctermfg=darkcyan ctermbg=black
 highlight Comment ctermfg=darkblue ctermbg=black

 nmap <f1> :source $VIM/dury.vim<cr>
 nmap <f2> :call TypoKeyF2()<cr>
 nmap <c-a>d :let @*=getcwd()<cr>
endfunction


function! TypoConfigOFF()
 syntax clear
 set ruler
 set nowrap
 set noautoindent
 set backspace=indent,eol,start
 set nocompatible
 set nohlsearch
 set clipboard=unnamed
 set foldmethod=manual
 normal zE
 language us_US
 redraw
 highlight Normal ctermfg=grey ctermbg=black
endfunction

function! TypoVimExec()
 let VIMWARN=0
 let VIMLINE='^'.g:COMMENTOR.'=vim\s\+'
 for LNUM in range(1,line("$"))
   let LINE=getline(LNUM)
   if LINE =~ VIMLINE
      let COMMAND=substitute(LINE,VIMLINE,'','')
      if COMMAND =~ '!\|exec\|shell'
        let VIMWARN=VIMWARN+1
        let CONFIRM="no"
        echohl XVimWarn
        let CONFIRM=input("Apply \"".COMMAND."\" (y/n)?","")
        echohl Normal
        if CONFIRM=='y'
           execute COMMAND
        endif
      else
        execute COMMAND
      endif
   endif
 endfor
 if VIMWARN > 0
  echohl XVimWarn
  echo "TypoVimExec done. (Warnings: ".VIMWARN.")"
 else
  echohl XVimSepar 
  echo "TypoVimExec done."
 endif
 echohl Normal
endfunction

function! TypoVimChck()
 let VIMLINE='^'.g:COMMENTOR.'=vim\s\+'
 let LNCT=0
 let WRCT=0
 let LNSTAT="Good"
 echohl XVimSepar
 echo "########################################"
 for LNUM in range(1,line("$"))
   let LINE=getline(LNUM)
   if LINE =~ VIMLINE
      let COMMAND=substitute(LINE,VIMLINE,'','')
      let LNCT=LNCT+1
      echohl XVimGood
      if COMMAND =~ '!\|exec\|shell'
          echohl XVimWarn
          let WRCT=WRCT+1
          let LNSTAT="!!! Please Check ( ".WRCT." warning ) !!!"
      endif
      echo LNUM.": ".COMMAND
   endif
 endfor
 echohl XVimSepar
 echo "## ".LNCT." found ".LNSTAT." #######################"
 echohl Normal
endfunction

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

function! TypoKeyF1()
 call TypoConfigON()
 call TypoMarkersON()
 call TypoEncryptedHide()
 call TypoVimExec()
endfunction

function! TypoKeyF2()
 call TypoConfigOFF()
endfunction

call TypoKeyF1()
"nmap <f1> :source $VIM/dury.vim<cr>
nmap <f1> :source $VIM/dury.vim<cr>
nmap <f2> :call TypoKeyF2()<cr>
nmap <s-f1> :call TypoVimChck()<cr>

" ##################################################################### }}} 1
" Folding by F3/F4 #################################################### {{{ 1

function! TypoFoldMarkers()
 set foldmethod=marker
 set foldmarker={{{,}}}
 let g:FOLDHEAD=g:COMMENTOR
 for I in range(1,g:FOLDMARKS) 
   let g:FOLDHEAD=g:FOLDHEAD."#"
 endfor
 let g:FOLDTAIL=g:FOLDHEAD
 let g:FOLDHEAD=g:FOLDHEAD." {"."{{ "
 let g:FOLDTAIL=g:FOLDTAIL." }"."}} "
 let l:XCOMMENTOR=substitute(g:COMMENTOR,'\/','\\\/','g')
 let XMARKERS='XMarkRed,XMarkGreen,XMasrkBlue,XMarkMagenta,XMarkYellow,XMarkBrown,XMarkCyan,XMarkTodo'
 execute 'syntax match Comment /^'.l:XCOMMENTOR.'.*$/ contains='.XMARKERS
 execute 'syntax match Xvim    /^'.l:XCOMMENTOR.'=.*$/'
 execute 'syntax match Xfold   /^'.l:XCOMMENTOR.'.* {'.'{{ [0-9]\+/'
 execute 'syntax match Xfold   /^'.l:XCOMMENTOR.'.* }'.'}} [0-9]\+/'
 execute 'high link Xfold Folded'
 execute 'high link Xvim  vimMark'
 let FOLDRULE=" 123456789 123456789 123456789 123456789"
 let g:FOLDRULE=g:COMMENTOR.FOLDRULE.FOLDRULE.FOLDRULE
endfunction

function! TypoFoldFixLine(LNUM,MODE)
 let LINE=getline(a:LNUM)
 let l:XCOMMENTOR=substitute(g:COMMENTOR,'\/','\\\/','g')
 if LINE !~ l:XCOMMENTOR.'.* \({{{\|}}}\) [0-9]'
    if a:MODE == "verbose"
     echohl XVimWarn 
     echo "The LINE is not a Fold Header or Fold Tailer !"
     echohl Normal
    endif
    return
 endif
 let LNEND=substitute(LINE,'^.*\( {{{ [0-9]\| }}} [0-9]\)','\1','')
 let LNTXT=substitute(LINE,'^'.l:XCOMMENTOR.'\(.*\)#*\( {{{ [0-9]\| }}} [0-9]\)','\1','')
 for I in range (1,g:FOLDMARKS)
    let LNTXT=LNTXT."#"
 endfor
 let LNTXT=g:COMMENTOR . substitute(LNTXT,'^\(.\{,'.g:FOLDMARKS.'}\).*$','\1','') . LNEND
 if LINE != LNTXT
  echohl XVimGood
  echo "Old[".a:LNUM."]:".LINE
  echo "New[".a:LNUM."]:".LNTXT
  let OPTION=input("Would you like to replace ? (y/n)")
  echohl Normal
  echo " "
  if OPTION == "y"
    call setline(a:LNUM,LNTXT)
  endif
 endif
endfunction

function! TypoFoldFixAll()
 for LNUM in range(1,line("$"))
   call TypoFoldFixLine(LNUM,"check_all")
 endfor 
endfunction

function! TypoFoldHead()
 call append(line(".")-1,g:FOLDHEAD."1")
 "call append(line("."),g:FOLDHEAD."1")
endfunction

function! TypoFoldTail()
 call append(line("."),g:FOLDTAIL."1")
endfunction

"call TypoMarkersON()
call TypoFoldMarkers()
nmap <f3> :call TypoFoldHead()<cr>zo
nmap <f4> :call TypoFoldTail()<cr>
nmap <s-f3> :call TypoFoldFixLine(line("."),"verbose")<cr>
nmap <s-f4> :call TypoFoldFixAll()<cr>

" ##################################################################### }}} 1
" Old Handling S-F5/S-F6 (TimeStamp & FileHead) ####################### {{{ 1

function! DuryHead()
 let FDESC=input("Description> ")
 let DATE=strftime("%Y%m%d")
 call append(0,g:COMMENTOR)
 call append(1,g:COMMENTOR." ".toupper(expand("%:f"))." - ".FDESC)
 call append(2,g:COMMENTOR." ".DATE.", ".g:AUTHOR)
 call append(3,g:COMMENTOR." ".expand("%:p"))
 call append(4,g:COMMENTOR)
 call append(5,g:COMMENTOR."=vim source $VIM/itn-dc.vim")
 call append(6,g:COMMENTOR)
 call append(line("$"),g:COMMENTOR." --- end ---")
endfunction

function! DuryTSTAMP()
 let TIMESTAMP=strftime("%Y-%m-%d %H:%M:%S")
 call setreg("*",TIMESTAMP)
 echo "Actual time ".TIMESTAMP." now in clipboard"
endfunction

nmap <f5> <esc>:call DuryTSTAMP()<cr>
nmap <s-f6> <esc>:call DuryHead()<cr>
nmap <f6> <esc>:call Utf8()<cr>

"###################################################################### }}} 1
" CMD handling by F9 / F10 ############################################ {{{ 1

" Apply one (cursor line) command only.
function! TypoCmdThis()
  let CMDLINE='^'.g:COMMENTOR.'=cmd\s\+'
  let LINE=getline('.')
  if LINE =~ CMDLINE
    let COMMAND=substitute(LINE,CMDLINE,'!','')
    execute COMMAND
  endif
endfunction

function! TypoCmdExec()
 let CMDCT=0
 let CMDLINE='^'.g:COMMENTOR.'=cmd\s\+'
 for LNUM in range(1,line("$"))
   let LINE=getline(LNUM)
   if LINE =~ CMDLINE
      let COMMAND=substitute(LINE,CMDLINE,'!','')
      let CMDCT=CMDCT+1
      execute COMMAND
   endif   
 endfor
 "echo " ".CMDCT." commands done."
endfunction

function! TypoCmdChck()
 echohl XVimSepar
 echo "#########################"
 let CMDCT=0
 let CMDLINE='^'.g:COMMENTOR.'=cmd\s\+'
 for LNUM in range(1,line("$"))
   let LINE=getline(LNUM)
   if LINE =~ CMDLINE
      let COMMAND=substitute(LINE,CMDLINE,'!','')
      let CMDCT=CMDCT+1
      echo CMDCT.'['.LNUM.']: '.COMMAND
   endif   
 endfor
 echohl XVimSepar
 echo " ".CMDCT." commands found."
 echohl Normal
endfunction

nmap <f9>   :call TypoCmdExec()<cr>
nmap <s-f9> :call TypoCmdChck()<cr>
nmap <f10>  :call TypoCmdThis()<cr>
"###################################################################### }}} 1

" --- end ---



