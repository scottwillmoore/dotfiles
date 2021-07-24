call plug#begin()

Plug 'gruvbox-community/gruvbox'
Plug 'machakann/vim-sandwich'
Plug 'unblevable/quick-scope'

call plug#end()

let mapleader=" "

set background=dark
set expandtab
set foldopen=mark,search,tag,undo
set hidden
set ignorecase
set listchars=tab:»\ ,extends:›,precedes:‹,nbsp:·,trail:·
set mouse=a
set nohlsearch
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

colorscheme gruvbox

if exists('g:vscode')

xmap gc <Plug>VSCodeCommentary
nmap gc <Plug>VSCodeCommentary
omap gc <Plug>VSCodeCommentary
nmap gcc <Plug>VSCodeCommentaryLine

highlight QuickScopePrimary guifg='#fbf1c7' gui=bold
highlight QuickScopeSecondary gui=none

endif
