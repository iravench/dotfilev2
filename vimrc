" don't bother with vi compatibility
set nocompatible

" configure plugins
call plug#begin('~/.vim/plugged')

if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

if filereadable(expand("~/.vimrc.bundles.local"))
  source ~/.vimrc.bundles.local
endif

call plug#end()

" enable syntax highlighting
syntax enable

set autoindent
set autoread                                                 " reload files when changed on disk, i.e. via `git checkout`
set backspace=2                                              " Fix broken backspace in some setups
set clipboard=unnamed                                        " yank and paste with the system clipboard
set encoding=utf-8
set ignorecase                                               " case-insensitive search
set incsearch                                                " search as you type
set hlsearch                                                 " highlight matches
set laststatus=2                                             " always show statusline
set list                                                     " show trailing whitespace
set listchars=tab:▸\ ,trail:▫
set number                                                   " show line numbers
set ruler                                                    " show where you are
set cursorline                                               " highlight cursor line
set scrolloff=3                                              " show context above/below cursorline
set shiftwidth=2                                             " normal mode indentation commands use 2 spaces
set showcmd
set smartcase                                                " case-sensitive search if any caps
set tabstop=8                                                " actual tabs occupy 8 characters
set softtabstop=2                                            " insert mode tab and backspace use 2 spaces
set expandtab                                                " expand tabs to spaces
set wildignore=log/**,node_modules/**,target/**,tmp/**
set wildmenu                                                 " show a navigable menu for tab completion
set wildmode=longest:full,full
set complete=.,w,b,u,t,i,kspell
set lazyredraw                                               " redraw only when need to - faster macros
set showmatch                                                " highlight matching

" Backup {{{
set backup
set backupcopy=yes                                           " see :help crontab
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set backupskip=/tmp/*,/private/tmp/*
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set writebackup
" }}}

function! s:statusline_expr()
  let mod = "%{&modified ? '[+] ' : !&modifiable ? '[x] ' : ''}"
  let ro  = "%{&readonly ? '[RO] ' : ''}"
  let ft  = "%{len(&filetype) ? '['.&filetype.'] ' : ''}"
  let fug = "%{exists('g:loaded_fugitive') ? fugitive#statusline() : ''}"
  let sep = ' %= '
  let pos = ' %-12(%l : %c%V%) '
  let pct = ' %P'

  return '[%n] %f %<'.mod.ro.ft.fug.sep.pos.'%*'.pct
endfunction
let &statusline = s:statusline_expr()

" Enable 24-bit true colors if your terminal supports it.
if (has("termguicolors"))
  set termguicolors

  " https://github.com/vim/vim/issues/993#issuecomment-255651605
  " for Vim inside Tmux
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

" set colorscheme
colorscheme one
set background=dark

" Folding {{{
set foldenable                                               " enable fold
set foldlevelstart=10                                        " open most folds by default
set foldnestmax=20                                           " 20 nested fold max
set foldmethod=indent                                        " fold based on indent level
nnoremap <space> za
" }}}

" keyboard shortcuts
let mapleader = ','
" moving bw windows with hjkl
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

" navigation file/directories
nnoremap <leader>b :CtrlPBuffer<CR>
nnoremap <leader>f :CtrlP<CR>
nnoremap <leader>d :NERDTreeToggle<CR>

" formating
nnoremap <leader>l : Align

" reindent the whole file and back to current cursor location
noremap! <Leader><tab> <esc>gg=G<C-o><C-o>zz

" git
nnoremap <leader>g :GitGutterToggle<CR>

" undo
nnoremap <leader>u :GundoToggle<CR>

" window/pane
nnoremap <leader>sv :vsplit<CR>
nnoremap <leader>sh :split<CR>

" exec current line as shell command then replace it with the output
nnoremap <leader>xr !!$SHELL<CR>

" reload vimrc
noremap <silent> <leader>r :source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>

" in case you forgot to sudo
cnoremap w!! %!sudo tee > /dev/null %

" plugin settings
let g:ctrlp_match_window      = 'order:ttb,max:30'
let g:ctrlp_working_path_mode = 0
let g:NERDSpaceDelims         = 1
let g:gitgutter_enabled       = 1
let g:ale_echo_msg_format     = '[%linter%] %s'

" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
  " Use Ag over grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s --files-with-matches --nocolor -g ""'
endif

" init ctrlp buffer delete plugin
call ctrlp_bdelete#init()

" automatically rebalance windows on vim resize
augroup utils
  autocmd!
  autocmd VimResized * :wincmd =
augroup END

" fugitive
augroup fugitive
  autocmd!
  autocmd BufReadPost fugitive://* set bufhidden=delete
augroup END

" create folders not yet existed in the file path
function! s:MkNonExDir(file, buf)
  if empty(getbufvar(a:buf, '&buftype')) && a:file!~#'\v^\w+\:\/'
    let dir=fnamemodify(a:file, ':h')
    if !isdirectory(dir)
      call mkdir(dir, 'p')
    endif
  endif
endfunction

augroup BWCCreateDir
  autocmd!
  autocmd BufWritePre * :call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
augroup END

" Fix Cursor in TMUX
if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" Don't copy the contents of an overwritten selection.
vnoremap p "_dP

if filereadable(expand("~/.vimrc.local"))
  " extra .vimrc
  source ~/.vimrc.local
endif

set modelines=1
