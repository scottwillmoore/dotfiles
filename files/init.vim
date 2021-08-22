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
set nowrap

colorscheme gruvbox

noremap Y y$

if exists('g:vscode')
    xmap gc <Plug>VSCodeCommentary
    nmap gc <Plug>VSCodeCommentary
    omap gc <Plug>VSCodeCommentary
    nmap gcc <Plug>VSCodeCommentaryLine

    nnoremap j <Cmd>call VSCodeNotify('cursorMove', { 'to': 'down', 'by': 'wrappedLine', 'value': v:count ? v:count : 1 })<CR>
    nnoremap k <Cmd>call VSCodeNotify('cursorMove', { 'to': 'up', 'by': 'wrappedLine', 'value': v:count ? v:count : 1 })<CR>
    nnoremap gj j
    nnoremap gk k
else
    nnoremap j gj
    nnoremap k gk
    nnoremap gj j
    nnoremap gk k
endif
