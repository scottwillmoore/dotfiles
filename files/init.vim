call plug#begin()

Plug 'machakann/vim-sandwich'
Plug 'unblevable/quick-scope'

call plug#end()

set expandtab
set foldopen=mark,search,tag,undo
set hidden
set nohlsearch
set ignorecase
set listchars=tab:»\ ,extends:›,precedes:‹,nbsp:·,trail:·
set mouse=a
set number
set scrolloff=4
set shiftwidth=4
set showmode
set sidescrolloff=4
set smartcase
set smartindent
set softtabstop=4
set spelllang="en_au,en_gb"
set splitbelow
set splitright
set tabstop=4
set wrap

let mapleader=" "

if exists('g:vscode')

xmap gc  <Plug>VSCodeCommentary
nmap gc  <Plug>VSCodeCommentary
omap gc  <Plug>VSCodeCommentary
nmap gcc <Plug>VSCodeCommentaryLine

highlight QuickScopePrimary guifg='#fbf1c7' gui=bold
highlight QuickScopeSecondary gui=none

endif
