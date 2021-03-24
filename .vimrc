
" plugins {{{

call plug#begin()
" general
Plug 'inkarkat/vim-ReplaceWithRegister'
Plug 'machakann/vim-sandwich'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-dispatch'
Plug 'wsdjeg/vim-fetch'
" appearance
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'Yggdroot/indentLine'
Plug 'vim-airline/vim-airline'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'akinsho/nvim-bufferline.lua'
" colorschemes
Plug 'morhetz/gruvbox'
Plug 'sainnhe/gruvbox-material'
" grep
Plug 'mileszs/ack.vim'
" wiki
Plug 'vimwiki/vimwiki'
" git
Plug 'tpope/vim-fugitive'
Plug 'lewis6991/gitsigns.nvim'
" tmux jump windows
Plug 'christoomey/vim-tmux-navigator'
" autoformat
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'
Plug 'google/vim-maktaba'
" bazel
Plug 'bazelbuild/vim-bazel'
" file explorer
Plug 'scrooloose/nerdtree'
Plug 'kyazdani42/nvim-tree.lua'
" debugging
Plug 'szw/vim-maximizer'
Plug 'puremourning/vimspector'
" telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
" lsp
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-compe'
Plug 'glepnir/lspsaga.nvim'
Plug 'aymericbeaumet/vim-symlink'
call plug#end()

" }}}

" color {{{
syntax enable
set termguicolors
set background=dark
let g:gruvbox_material_background = 'soft'
let g:gruvbox_material_enable_bold = 0
colorscheme gruvbox-material
" }}}

" general {{{
let mapleader = "\<Space>"
set hidden
set number
set relativenumber
set cursorcolumn
set cursorline
set nowrap
set splitright
set splitbelow
set ttimeoutlen=5
set viminfo='100,<50,s10,h,
set history=10000
set sidescroll=1

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
set matchpairs+=<:>

set wildmenu
set wildmode=list:longest,full
autocmd FileType vim setlocal foldmethod=marker

" }}}

" custom function {{{
function! BazelGetCurrentBufTarget()
    let bazel_file_label=system("bazel query " . bufname("%") . " --color no --curses no --noshow_progress | tr -d '[:space:]'")
    let bazel_file_package=split(bazel_file_label, ":")[0]
    let g:current_bazel_target=system("bazel query \"attr('srcs', " . bazel_file_label . ", " . bazel_file_package . ":*)\" --color no --curses no --noshow_progress | tr -d '[:space:]'")
endfunction

function! RunBazel()
    :execute 'Bazel ' . g:bazel_command . ' ' . g:current_bazel_target
endfunction

function! RunBazelHere(command)
    :let g:bazel_command = a:command
    :call BazelGetCurrentBufTarget()
    :call RunBazel()
endfunction

function! AdaptFilePath(filepath, pattern, replacement)
    let index = strridx(a:filepath, a:pattern) 
    if (index != -1)
        return a:filepath[0:index] . a:replacement
    endif
    return a:filepath
endfunction

function! SwitchSourceHeader()
    let filepath = expand('%:p:h')
    let filename = expand("%:t:r")
    let fileending = expand("%:e")
    if (fileending == "cpp")
        let filetype = ".h"
        let filepath = AdaptFilePath(filepath, "/src", "includes/**")
        let filepath = AdaptFilePath(filepath, "/Sources", "Includes/**")
    endif
    if (fileending == "h")
        let filetype = ".cpp"
        let filepath = AdaptFilePath(filepath, "/includes", "src/**")
        let filepath = AdaptFilePath(filepath, "/Includes", "Sources/**")
    endif
    exe "find " . filepath . "/" . filename . filetype
endfunction

"index all files in folder (recursivly)
function! IndexFiles(path)
    echom "Add all files to arglist from " . a:path
    exe "silent args " . a:path . "/**/*.cpp"
    echom "Opening all files from " . a:path
    silent argdo e
    echom "Closing all files from " . a:path
    silent argdo bw
    echom "Clear arglist"
    argdelete *
endfunction

function! CopyFormatted(line1, line2)
    execute a:line1 . "," . a:line2 . "TOhtml"
    %yank +
    call system('xclip -o -sel clip | xclip -i -sel clip -target text/html')
    bwipeout!
endfunction

command! -range=% HtmlClip silent call CopyFormatted(<line1>,<line2>)
" }}}

" keybindings {{{

" easy navigation between window splits and tmux panes
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" copy full file path to clipboard
nnoremap <Leader>f :let @+=expand("%")<CR>

nnoremap <leader>ff :lua require('telescope.builtin').find_files({previewer = false})<CR>
nnoremap <leader>fo :lua require('telescope.builtin').oldfiles({previewer = false})<CR>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

nnoremap <c-n> :NERDTreeToggle<CR>
nnoremap <Leader>n :NERDTreeFind<CR>
nnoremap <Leader>a :Ack!<Space>

" copy visual selection to clipboard with ctrl-c
vnoremap <C-c> "+y
" deletes visual selection and pastes without changing default register
vnoremap p "_dP

nnoremap <F7> :call SwitchSourceHeader()<CR>
nnoremap <F6> :s/\\/\//g <CR>

nnoremap <Leader>bt  :call RunBazelHere("test --config=adp")<CR>
nnoremap <Leader>bdt :call RunBazelHere("test --config=adp -c dbg")<CR>
nnoremap <Leader>bb  :call RunBazelHere("build --config=adp")<CR>
nnoremap <Leader>bdb :call RunBazelHere("build --config=adp -c dbg")<CR>
nnoremap <Leader>bl  :call RunBazel()<CR>

" }}}

" plugin configuration {{{


" vim-commentary {{{
autocmd FileType c,cpp,java set commentstring=//\ %s
" }}}

" vim-airline {{{
let g:airline_theme = 'gruvbox_material'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#bufferline#enabled = 0
set laststatus=2 " otherwise airline only shows after a split
"let g:bufferline_echo = 0 " with airline we see the bufferlist two times without this
set timeoutlen=1000 ttimeoutlen=0
" remove the vcs/git part
let g:airline_section_b=''
" remove the filetype part
let g:airline_section_x=''
" remove the fileencoding part
let g:airline_section_y=''
" remove the current position in the file part
"let g:airline_section_z=''
" remove separators for empty sections
let g:airline_skip_empty_sections = 1
" }}}

" indent-blankline {{{
let g:indent_blankline_filetype = ['python']
" }}}

" bufferline {{{
lua << EOF
require'bufferline'.setup{
    options = {
        max_name_length = 50;
        tab_size = 0,
    }
}
EOF
" }}}

" nerdtree {{{
syntax on
filetype plugin indent on
:let g:NERDTreeWinSize=60
"close vim if nerdtree is last open buffer
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" }}}

" lua tree {{{
let g:nvim_tree_side = 'left'
let g:nvim_tree_width = 40 "30 by default
let g:nvim_tree_ignore = [ '.git', 'node_modules', '.cache' ] "empty by default
let g:nvim_tree_auto_open = 0 "0 by default, opens the tree when typing `vim $DIR` or `vim`
let g:nvim_tree_auto_close = 1 "0 by default, closes the tree when it's the last window
let g:nvim_tree_auto_ignore_ft = {} "empty by default, don't auto open tree on specific filetypes.
let g:nvim_tree_quit_on_open = 1 "0 by default, closes the tree when you open a file
let g:nvim_tree_follow = 1 "0 by default, this option allows the cursor to be updated when entering a buffer
let g:nvim_tree_indent_markers = 1 "0 by default, this option shows indent markers when folders are open
let g:nvim_tree_hide_dotfiles = 1 "0 by default, this option hides files and folders starting with a dot `.`
let g:nvim_tree_git_hl = 0 "0 by default, will enable file highlight for git attributes (can be used without the icons).
let g:nvim_tree_root_folder_modifier = ':~' "This is the default. See :help filename-modifiers for more options
let g:nvim_tree_tab_open = 1 "0 by default, will open the tree when entering a new tab and the tree was previously open
let g:nvim_tree_width_allow_resize  = 1 "0 by default, will not resize the tree when opening a file
let g:nvim_tree_disable_netrw = 0 "1 by default, disables netrw
let g:nvim_tree_hijack_netrw = 0 "1 by default, prevents netrw from automatically opening when opening directories (but lets you keep its other utilities)
let g:nvim_tree_add_trailing = 1 "0 by default, append a trailing slash to folder names
let g:nvim_tree_show_icons = {
    \ 'git': 1,
    \ 'folders': 1,
    \ 'files': 1,
    \ }
"If 0, do not show the icons for one of 'git' 'folder' and 'files'
"1 by default, notice that if 'files' is 1, it will only display
"if nvim-web-devicons is installed and on your runtimepath

" default will show icon by default if no icon is provided
" default shows no icon by default
let g:nvim_tree_icons = {
    \ 'default': '',
    \ 'symlink': '',
    \ 'git': {
    \   'unstaged': "✗",
    \   'staged': "✓",
    \   'unmerged': "",
    \   'renamed': "➜",
    \   'untracked': "★"
    \   },
    \ 'folder': {
    \   'default': "",
    \   'open': "",
    \   'empty': "",
    \   'empty_open': "",
    \   'symlink': "",
    \   'symlink_open': "",
    \   }
    \ }

nnoremap <C-n> :NvimTreeToggle<CR>
nnoremap <leader>r :NvimTreeRefresh<CR>
nnoremap <leader>n :NvimTreeFindFile<CR>
" }}}

" icons {{{
lua << EOF
require'nvim-web-devicons'.setup {
 -- globally enable default icons (default to false)
 -- will get overriden by `get_icons` option
 default = true;
}
EOF
" }}}

" bazel-lsp Tim Rakowski {{{
source ~/buildtools/bazel_vim/bazel.vim
" }}}

" ack.vim {{{
let g:ackprg = 'ag --vimgrep'
" }}}

" vim-codefmt {{{
autocmd BufWrite :FormatCode *
augroup autoformat_settings
  autocmd FileType bzl AutoFormatBuffer buildifier
  autocmd FileType c,cpp,proto,javascript AutoFormatBuffer clang-format
  "autocmd FileType dart AutoFormatBuffer dartfmt
  "autocmd FileType go AutoFormatBuffer gofmt
  "autocmd FileType gn AutoFormatBuffer gn
  "autocmd FileType html,css,sass,scss,less,json AutoFormatBuffer js-beautify
  "autocmd FileType java AutoFormatBuffer google-java-format
  autocmd FileType python AutoFormatBuffer black
  "Alternative: autocmd FileType python AutoFormatBuffer autopep8
  "autocmd FileType rust AutoFormatBuffer rustfmt
  "autocmd FileType vue AutoFormatBuffer prettier
augroup END
" }}}

" vim-wiki {{{
let g:vimwiki_list = [{'path': '~/vimwiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]
let g:mkdp_browser = 'firefox'
" }}}

" telescope {{{
" telescope faster fuzzy
lua << EOF
require('telescope').setup {
    extensions = {
        fzy_native = {
            override_generic_sorter = false,
            override_file_sorter = true,
        }
    }
}
require('telescope').load_extension('fzy_native')
EOF

" update oldfiles on the fly
function! s:update_oldfiles(file)
  if !exists('v:oldfiles')
    return
  endif
  let idx = index(v:oldfiles, a:file)
  if idx != -1
    call remove(v:oldfiles, idx)
  endif
  call insert(v:oldfiles, a:file, 0)
endfunction

autocmd BufNewFile,BufRead,BufEnter,BufFilePre *
          \ call s:update_oldfiles(expand('<afile>:p'))
" }}}

" git gutter {{{
" faster update (default 4000)
set updatetime=100
set signcolumn=auto:2
lua << EOF
require('gitsigns').setup()
EOF
" }}}

" vim-bazel {{{

" }}}

" vimspector {{{
let g:vimspector_install_gadgets = [ 'debugpy', 'vscode-cpptools' ]
fun! GotoWindow(id)
    call win_gotoid(a:id)
    MaximizerToggle
endfun

" Debugger remaps
nnoremap <leader>m :MaximizerToggle!<CR>
nnoremap <leader>dd :call vimspector#Launch()<CR>
nnoremap <leader>dc :call GotoWindow(g:vimspector_session_windows.code)<CR>
nnoremap <leader>dt :call GotoWindow(g:vimspector_session_windows.tagpage)<CR>
nnoremap <leader>dv :call GotoWindow(g:vimspector_session_windows.variables)<CR>
nnoremap <leader>dw :call GotoWindow(g:vimspector_session_windows.watches)<CR>
nnoremap <leader>ds :call GotoWindow(g:vimspector_session_windows.stack_trace)<CR>
nnoremap <leader>do :call GotoWindow(g:vimspector_session_windows.output)<CR>
nnoremap <leader>de :call vimspector#Reset()<CR>

nnoremap <leader>dtcb :call vimspector#CleanLineBreakpoint()<CR>

nmap <leader>l <Plug>VimspectorStepInto
nmap <leader>j <Plug>VimspectorStepOver
nmap <leader>k <Plug>VimspectorStepOut
nmap <leader>dr <Plug>VimspectorRestart
nnoremap <leader>d<space> :call vimspector#Continue()<CR>

nmap <leader>rc <Plug>VimspectorRunToCursor
nmap <leader>bp <Plug>VimspectorToggleBreakpoint
nmap <leader>dbp :call vimspector#ClearBreakpoints()<CR>
nmap <leader>cbp <Plug>VimspectorToggleConditionalBreakpoint
" }}}

" nvim-lsp {{{

" formatting {{{
hi link LspDiagnosticsVirtualTextError Red
hi link LspDiagnosticsVirtualTextWarning Yellow
hi link LspDiagnosticsUnderlineError Red
hi link LspDiagnosticsUnderlineWarning Yellow
" }}}

" server configs {{{
lua << EOF

local lspconfig = require'lspconfig'
local on_attach = require'compe'.on_attach

lspconfig.clangd.setup{
    on_attach = on_attach;
    root_dir = lspconfig.util.root_pattern("compile_commands.json", "compile_flags.txt") or dirname
}

lspconfig.pyright.setup{
    on_attach = on_attach;
}

require'compe'.setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = true;

  source = {
    path = true;
    buffer = true;
    nvim_lsp = true;
  };
}

EOF

" }}}

" autocompletion {{{

inoremap <silent><expr> <C-Space> compe#complete()
inoremap <silent><expr> <CR>      compe#confirm('<CR>')
inoremap <silent><expr> <C-e>     compe#close('<C-e>')
inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
inoremap <silent><expr> <C-b>     compe#scroll({ 'delta': -4 })

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect
let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']
let g:completion_matching_smart_case = 1

" Avoid showing message extra message when using completion
set shortmess+=c

" }}}

" lspsaga {{{
lua << EOF
local saga = require 'lspsaga'
saga.init_lsp_saga{}
EOF
" }}}

" keybindings {{{
nnoremap <silent> gh :Lspsaga lsp_finder<CR>
nnoremap <silent> <leader>ca :Lspsaga code_action<CR>
vnoremap <silent> <leader>ca :<C-U>Lspsaga range_code_action<CR>
nnoremap <silent> K :Lspsaga hover_doc<CR>
nnoremap <silent> <C-f> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>
nnoremap <silent> <C-b> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>
nnoremap <silent> gs :Lspsaga signature_help<CR>
nnoremap <silent> <leader>rn :Lspsaga rename<CR>
nnoremap <silent> <leader>gd :Lspsaga preview_definition<CR>
nnoremap <silent> <leader>sd :Lspsaga show_line_diagnostics<CR>
nnoremap <silent> [d :Lspsaga diagnostic_jump_next<CR>
nnoremap <silent> ]d :Lspsaga diagnostic_jump_prev<CR>

nnoremap gd :lua vim.lsp.buf.definition()<CR>
nnoremap gi :lua vim.lsp.buf.implementation()<CR>
nnoremap gr :lua vim.lsp.buf.references()<CR>
nnoremap <leader>q :lua vim.lsp.diagnostic.set_loclist()<CR>
" }}}

" }}}

" }}}
