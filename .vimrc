" ~/.vimrc — Vim configuration
" Managed in ~/dotfiles, symlinked to ~/.vimrc by install.sh.
" Targets the stock macOS Vim (9.1, no plugins): everything here uses features
" that ship with Vim, so it works on a fresh machine with no extra install.
" Heavily commented on purpose — treat it as a reference you can prune later.

" ---------- Core behaviour ----------
set nocompatible          " use Vim's improvements, not strict vi compatibility
syntax on                 " syntax highlighting (the headline feature vimtutor mentioned)
filetype plugin indent on " detect file types, load their plugins + indent rules

set encoding=utf-8        " use UTF-8 everywhere
set hidden                " switch away from a modified buffer without being forced to save
set mouse=a               " enable mouse: scroll, click to move, drag to select
set history=1000          " remember more : commands and search patterns
let mapleader = " "       " use Space as <leader> for custom shortcuts (see below)

" ---------- Display ----------
set number                " absolute number on the current line...
set relativenumber        " ...relative numbers elsewhere (handy for 5j, 12k motions)
set ruler                 " show line/column in the bottom-right
set showcmd               " show partial commands as you type (e.g. the d in dw)
set laststatus=2          " always show the status line
set wildmenu              " tab-completion menu for : commands
set scrolloff=5           " keep 5 lines of context above/below the cursor
set linebreak             " wrap long lines at word boundaries, not mid-word
set display=lastline      " show as much as possible of a long wrapped line

" ---------- Searching ----------
set incsearch             " jump to matches as you type
set hlsearch              " highlight all matches
set ignorecase            " case-insensitive search...
set smartcase             " ...unless the pattern contains a capital letter
" <leader> then Space (i.e. Space Space) clears the leftover search highlight
nnoremap <silent> <leader><Space> :nohlsearch<CR>

" ---------- Indentation (sensible defaults; per-language tweaks further down) ----------
set autoindent            " new lines inherit the previous line's indent
set expandtab             " insert spaces, never literal tab characters
set tabstop=4             " a tab renders as 4 spaces
set softtabstop=4         " Tab / Backspace move by 4 spaces in insert mode
set shiftwidth=4          " >> and << shift by 4 spaces
set backspace=indent,eol,start  " let Backspace delete past indent / line starts

" ---------- System clipboard ----------
" macOS Vim has +clipboard, so y and p use the system clipboard directly:
" yank in Vim -> Cmd+V elsewhere, copy elsewhere -> p in Vim.
set clipboard=unnamed

" ---------- Backups / persistent undo ----------
" Keep working directories clean by stashing swap/backup/undo files under ~/.vim,
" and persist undo history so `u` still works after reopening a file.
set undofile
set undodir=~/.vim/undo//
set directory=~/.vim/swap//
set backupdir=~/.vim/backup//
" Create those directories on first run if they don't exist yet.
for s:dir in ['undo', 'swap', 'backup']
  if !isdirectory(expand('~/.vim/' . s:dir))
    call mkdir(expand('~/.vim/' . s:dir), 'p')
  endif
endfor

" ---------- Per-language settings ----------
augroup filetype_settings
  autocmd!
  " Python: PEP 8 4-space indent is already the default above; add a width guide.
  " (marimo notebooks are plain .py files, so this covers them too.)
  autocmd FileType python setlocal textwidth=88 colorcolumn=88
  " Markdown: soft-wrap prose and enable spell-check.
  autocmd FileType markdown setlocal wrap spell spelllang=en_us
  " YAML / TOML (config + frontmatter): 2-space indent is the convention.
  autocmd FileType yaml,toml setlocal tabstop=2 softtabstop=2 shiftwidth=2
augroup END

" ---------- Quality of life ----------
set confirm               " prompt to save instead of erroring when :q has unsaved changes
set splitbelow splitright " new splits open below / to the right (more intuitive)
nnoremap <leader>w :w<CR> " Space w to save (a gentler reach than :w)
