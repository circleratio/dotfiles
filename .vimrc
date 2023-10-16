set nocompatible

let s:dein_base = '$HOME/.cache/dein'
let s:dein_src = '$HOME/.cache/dein/repos/github.com/Shougo/dein.vim'
let s:dein_dir = expand($HOME . '/.vim/dein')

execute 'set runtimepath+=' . s:dein_src

call dein#begin(s:dein_base)
call dein#add(s:dein_src)
call dein#end()

let s:toml = s:dein_dir . '/dein.toml'
call dein#load_toml(s:toml, {'lazy': 0})

if dein#check_install()
  call dein#install()
endif

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
set shellslash
set nobackup
set nowritebackup
set encoding=utf-8

if has("unix")
    " unix settings
elseif has ("win32")
    set guifont=Terminal:h16:cSHIFTJIS:qDRAFT
endif

inoremap jk <ESC>
