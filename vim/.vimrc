set nocompatible

let s:plug_vim = expand($HOME . '/.vim/autoload/plug.vim')
if !filereadable(s:plug_vim)
  silent execute '!curl -fLo ' . s:plug_vim . ' --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'jamessan/vim-gnupg'

call plug#end()

command! -bang -nargs=* Rg
    \ call fzf#vim#grep(
    \ 'rg --column --line-number --hidden --ignore-case --no-heading --color=always '.shellescape(<q-args>), 1,
    \ <bang>0 ? fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}, 'up:60%')
    \ : fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}, 'right:50%:hidden', '?'),
    \ <bang>0)
nnoremap <C-p> :Files<CR>
nnoremap <C-h> :History<CR>

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
nnoremap gr :tabprevious

set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
