set nocompatible

let s:dein_base = '$HOME/.cache/dein'
let s:dein_src = '$HOME/.cache/dein/repos/github.com/Shougo/dein.vim'

execute 'set runtimepath+=' . s:dein_src

call dein#begin(s:dein_base)
call dein#add(s:dein_src)
call dein#end()

if has('filetype')
  filetype indent plugin on
endif

if has('syntax')
  syntax on
endif

set hlsearch
set wildmenu
set smartcase
set incsearch
set autoindent

