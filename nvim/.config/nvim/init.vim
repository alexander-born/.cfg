
lua require('plugins')

source <sfile>:h/plugin/ack.vim
source <sfile>:h/plugin/color.vim
source <sfile>:h/plugin/git.vim
source <sfile>:h/plugin/html_clip.vim
source <sfile>:h/plugin/index_files.vim
source <sfile>:h/plugin/open_errors_in_qf.vim
source <sfile>:h/plugin/switch_source_header.vim
source <sfile>:h/plugin/vimspector.vim
source <sfile>:h/plugin/vimwiki.vim
source <sfile>:h/plugin/vsnip.vim

let mapleader = "\<Space>"
set number
set relativenumber
set cursorline
set nowrap
set splitright
set splitbelow
set ttimeoutlen=5
set mouse=a
set termguicolors

"search options"
set ignorecase
set smartcase
set showmatch

"indent options"
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab

set list
set listchars=tab:>-,trail:·
set matchpairs+=<:>

set wildmode=list:longest,full

augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=300}
augroup END
