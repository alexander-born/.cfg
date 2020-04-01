set history=10000

call plug#begin()
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/nerdtree'
Plug 'machakann/vim-sandwich'
Plug 'airblade/vim-gitgutter'
Plug 'scrooloose/nerdcommenter'
Plug 'iCyMind/NeoSolarized'
Plug 'kien/ctrlp.vim'
Plug 'mileszs/ack.vim'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'christoomey/vim-tmux-navigator'
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'
call plug#end()
                                       
"set termguicolors
syntax enable
set background=dark
colorscheme NeoSolarized

let mapleader = ","
set hidden
set number
set relativenumber
set nowrap
set splitright
set splitbelow

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

set viminfo='100,<50,s10,h,

"search options"
set incsearch
set ignorecase
set smartcase
set showmatch
set hlsearch

"indent options"
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab

set list
set listchars=tab:>-,trail:·

set cursorcolumn
set cursorline

set wildmenu
set wildmode=list:longest,full

set sidescroll=1

"ctrlP
"don't open in nerdtree buffer
function! CtrlPCommand()
    let c = 0
    let wincount = winnr('$')
    " Don't open it here if current buffer is not writable (e.g. NERDTree)
    while !empty(getbufvar(+expand("<abuf>"), "&buftype")) && c < wincount
        exec 'wincmd w'
        let c = c + 1
    endwhile
    exec 'CtrlP'
endfunction

map <c-t> :CtrlPBuffer<CR>
let g:ctrlp_max_height = 30
let g:ctrlp_cmd = 'call CtrlPCommand()'
let g:ctrlp_map = '<c-p>'
"let g:ctrlp_cmd = 'CtrlP'"
let g:ctrlp_working_path_mode = 'w'
"let g:ctrlp_root_markers = ["bazel"]
"let g:ctrlp_follow_symlinks = 1
let g:ctrlp_max_files = 0
let g:ctrlp_clear_cache_on_exit = 0


"airline/bufferline"
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#bufferline#enabled = 0
set laststatus=2 " otherwise airline only shows after a split
let g:bufferline_echo = 0 " with airline we see the bufferlist two times without this
set timeoutlen=1000 ttimeoutlen=0
" remove the vcs/git part
let g:airline_section_b=''
" remove the filetype part
let g:airline_section_x=''
" remove the fileencoding part
let g:airline_section_y=''
" remove the current position in the file part
let g:airline_section_z=''
" " remove separators for empty sections
let g:airline_skip_empty_sections = 1


"nerdtree"
syntax on
filetype plugin indent on
map <Leader>n :NERDTreeToggle<CR>
map <Leader>m :NERDTreeFind<CR>
:let g:NERDTreeWinSize=60
"close vim if nerdtree is last open buffer
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

"------vim-lsp"
"To enable preview window"
set completeopt+=preview
"To auto close preview window when completion is done"
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif
map <c-]> :LspDefinition<CR>
map <F7> :LspDocumentSwitchSourceHeader<CR>

"Tim Rakowski bazel target goto
"source ~/buildtools/bazel_vim/bazel.vim

"ack.vim
let g:ackprg = 'ag --vimgrep'
nnoremap <Leader>a :Ack!<Space>

"vim-codefmt
autocmd BufWrite :FormatCode *
augroup autoformat_settings
  autocmd FileType bzl AutoFormatBuffer buildifier
  autocmd FileType c,cpp,proto,javascript AutoFormatBuffer clang-format
  autocmd FileType dart AutoFormatBuffer dartfmt
  autocmd FileType go AutoFormatBuffer gofmt
  autocmd FileType gn AutoFormatBuffer gn
  autocmd FileType html,css,sass,scss,less,json AutoFormatBuffer js-beautify
  autocmd FileType java AutoFormatBuffer google-java-format
  autocmd FileType python AutoFormatBuffer yapf
  " Alternative: autocmd FileType python AutoFormatBuffer autopep8
  autocmd FileType rust AutoFormatBuffer rustfmt
  autocmd FileType vue AutoFormatBuffer prettier
augroup END


