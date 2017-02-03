" name: .vimrc
" author: scott moore

" ______________________________________________________________________________
" plugins

call plug#begin()

" the nord colorscheme.
Plug 'arcticicestudio/nord-vim'

" a lightweight status line replacement.
Plug 'itchyny/lightline.vim'
let g:lightline = {
	\ 'colorscheme': 'nord'
	\ }

" generate tmux status line using vim status line.
Plug 'edkolev/tmuxline.vim'
let g:tmuxline_powerline_separators = 0
let g:tmuxline_theme = 'lightline'
let g:tmuxline_preset = {
	\ 'a':       '#S',
	\ 'b':       '#W#{?window_zoomed_flag, ^,}',
	\ 'c':       '%R',
	\ 'win':     '#I #W',
	\ 'cwin':    '#I #W',
	\ 'x':       '',
	\ 'y':       '',
	\ 'z':       '',
	\ 'options': { 'status-justify': 'right' }
	\ }

" simple, fast path fuzzy finder for files, buffers, etc.
Plug 'ctrlpvim/ctrlp.vim'
 
" allow quick movement around vim buffers.
Plug 'easymotion/vim-easymotion'

" improved hard and soft line wrapping.
" improved spell check and thesaurus completions.
Plug 'reedes/vim-pencil'
Plug 'reedes/vim-lexical'
augroup pencil
	autocmd!
	autocmd FileType markdown,mkd call pencil#init({'textwidth': 80})
	                          \ | call lexical#init()
augroup END
let g:lexical#spell_key = '<leader>s'
let g:lexical#thesaurus_key = '<leader>t'

" improved support for the javascript language.
Plug 'pangloss/vim-javascript'

call plug#end()


" ______________________________________________________________________________
" settings

" disable compatibility mode.
set nocompatible

" set better swap and backup directory.
set directory=$HOME/.vim/swap//
set backupdir=$HOME/.vim/backup//

" turn on file type detection.
if has('autocmd')
	filetype plugin indent on
endif

" turn on syntax highlighting.
if has('syntax') && !exists('g:syntax_on')
	syntax enable
endif

" attempt to set colorscheme, and suppress error messages.
silent! colorscheme nord

" enable the use of mouse for all modes.
if has('mouse')
	set mouse=a
endif

" show search pattern matches while typing, only if it's possible to timeout.
if has('reltime')
	set incsearch
endif

" ensure that backups are copies, which allows webpack-dev-server to work.
set backupcopy=yes

" highlight all search matches.
set hlsearch

" indent to same level as previous line.
set autoindent
"
" allow backspacing over everything in insert mode.
set backspace=indent,eol,start

" disable incrementing of octal numbers to create better decimal experience.
set nrformats-=octal

" set timeout for keycodes, and wait up to 100ms.
set ttimeout
set ttimeoutlen=100

" show as much as possible of truncated lines.
set display+=lastline

" set the minimal number of lines to show around the cursor.
set scrolloff=3
set sidescrolloff=3

" always show a status line.
set laststatus=2

" display command completion matches in the status line.
set wildmenu

" ignore completion matches which matches these patterns.
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
set wildignore+=*/node_modules/*

" characters to show hidden characters when in list mode.
set listchars=tab:>\ ,trail:-,nbsp:+,extends:>,precedes:<

" new splits are placed below or to the right of the current buffer.
set splitright
set splitbelow

" show line numbers.
set number

" highlight the line that the cursor is on.
set cursorline

" allow lines longer than the window to wrap.
set wrap

" set the languages used for spelling.
set spelllang=en_au,en_gb

" highlight these keywords in comments.
autocmd Syntax * call matchadd('Todo',  '\W\zs\(NOTE\|INFO\|IDEA\|TODO\|CHANGED\)')
autocmd Syntax * call matchadd('Debug', '\W\zs\(FIXME\|XXX\|BUG\|HACK\)')


" ______________________________________________________________________________
" bindings

" set the leader key to space for quick access.
noremap <space> <nop>
let mapleader = "\<space>"

" disable the use of arrow keys.
noremap <up> <nop>
noremap <down> <nop>
noremap <left> <nop>
noremap <right> <nop>

" make the command buffer easier to access.
noremap ; :

" reselect selection after indent command.
vnoremap < <gv
vnoremap > >gv

" give ctrl-c the same functionality as escape.
noremap <c-c> <esc>

" allow easier split navigation.
noremap <c-j> <c-w>j
noremap <c-k> <c-w>k
noremap <c-l> <c-w>l
noremap <c-h> <c-w>h

" move through wrapped lines, instead of actual lines.
noremap j gj
noremap k gk
