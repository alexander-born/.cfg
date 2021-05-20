
" plugins {{{

call plug#begin()
" general
Plug 'inkarkat/vim-ReplaceWithRegister'
Plug 'machakann/vim-sandwich'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-unimpaired'
Plug 'wsdjeg/vim-fetch'
" appearance
Plug 'lukas-reineke/indent-blankline.nvim' , { 'branch': 'lua' }
Plug 'hoob3rt/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'ryanoasis/vim-devicons'
Plug 'akinsho/nvim-bufferline.lua'
Plug 'norcalli/nvim-colorizer.lua'
Plug 'folke/todo-comments.nvim'
" nerdtree
Plug 'scrooloose/nerdtree'
" colorschemes
Plug 'sainnhe/everforest'
Plug 'sainnhe/gruvbox-material'
Plug 'ChristianChiarulli/nvcode-color-schemes.vim'
" grep
Plug 'mileszs/ack.vim'
" wiki
Plug 'vimwiki/vimwiki'
" markdown
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
" git
Plug 'tpope/vim-fugitive'
Plug 'lewis6991/gitsigns.nvim'
Plug 'rhysd/conflict-marker.vim'
" tmux jump windows
Plug 'christoomey/vim-tmux-navigator'
" python
Plug 'alfredodeza/pytest.vim'
" autoformat
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'
Plug 'google/vim-maktaba'
" bazel
Plug 'bazelbuild/vim-bazel'
Plug 'alexander-born/bazel-vim'
" debugging
Plug 'szw/vim-maximizer'
Plug 'puremourning/vimspector'
" telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
" treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'nvim-treesitter/playground'
" trouble
Plug 'folke/trouble.nvim'
" lsp
Plug 'neovim/nvim-lspconfig'
Plug 'kabouzeid/nvim-lspinstall'
Plug 'hrsh7th/nvim-compe'
Plug 'ray-x/lsp_signature.nvim'
Plug 'onsails/lspkind-nvim'
Plug 'aymericbeaumet/vim-symlink'
" snippets
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
Plug 'rafamadriz/friendly-snippets'
call plug#end()

" }}}

" general {{{
let g:color_scheme = 'everforest' " gruvbox-material, nord, everforest

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
augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=300}
augroup END

" }}}

" specific user config {{{
if filereadable(expand("~/.user.vim"))
    source ~/.user.vim
endif
if filereadable(expand("~/.config/nvim/user.vim"))
    source ~/.config/nvim/user.vim
endif
" }}}

" color {{{
syntax enable
set termguicolors
let g:gruvbox_material_background = 'soft'
let g:everforest_background = 'hard'
set background=dark
exe "colorscheme " . g:color_scheme
" }}}

" custom function {{{
lua << EOF
function _G.get_g_test_name()
    local ts_utils = require'nvim-treesitter.ts_utils'
    local node = ts_utils.get_node_at_cursor()
    local test_node = nil
    while node ~= nil do
        if node:type() == 'function_definition' then test_node = node end
        node = node:parent()
    end
    if test_node == nil then return end
    local parameter_list = test_node:named_child(0):named_child(1)
    local test_suite = parameter_list:named_child(0)
    local test_name = parameter_list:named_child(1)
    return ts_utils.get_node_text(test_suite)[1] .. '.' .. ts_utils.get_node_text(test_name)[1]
end
EOF
function! GetExecutableFromBazelTarget()
    let l:executable = substitute(g:current_bazel_target, ':', '/', '')
    let l:executable = substitute(l:executable, '//', 'bazel-bin/', '')
    return substitute(l:executable, '/', '\\/', 'g')
endfunction

function! AdaptVimspectorJson()
    let l:test_filter = luaeval("get_g_test_name()")
    call BazelGetCurrentBufTarget()
    let g:executable = GetExecutableFromBazelTarget()
    e .vimspector.json
    exe '%s/"program": ".*",/"program": "' . g:executable .  '",/g'
    if (test_filter == "null")
        exe '%s/"args": \[.*\],/"args": \[\],/g'
    else
        exe '%s/"args": \[.*\],/"args": \["--gtest_filter=*' . test_filter . '*"\],/g'
    endif
    w
    e#
endfunction

function! DebugThisTest()
    call AdaptVimspectorJson()
    call RunBazelHere("build " . g:bazel_config . " -c dbg ")
endfunction

function! OpenErrorInQuickfix()
    cexpr []
    caddexpr getline(0,'$')
    copen
    let l:qf_list = []
    for entry in getqflist()
        if (entry.valid == 1) 
            if (entry.bufnr !=0)
                call add(l:qf_list, entry)
            else
                call FindUnitTest(split(entry.text, '\.')[-1])
                for test in getqflist()
                    call add(l:qf_list, test)
                endfor
            endif
        endif
    endfor
    call setqflist(l:qf_list)
endfunction

function! FindUnitTest(test_name)
    exe "Ack! -G '\.cpp' " . a:test_name . " application/adp"
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
    silent! argdo e
    echom "Closing all files from " . a:path
    silent! argdo bw
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

" general keybindings {{{

" easy navigation between window splits and tmux panes
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" esc in terminal leaves insert mode
tnoremap <ESC> <C-\><C-n>

" copy full file path to clipboard
nnoremap <Leader>f :let @+=expand("%")<CR>

" copy visual selection to clipboard with ctrl-c
vnoremap <C-c> "+y
" deletes visual selection and pastes without changing default register
vnoremap p "_dP
" go to first file on line
nnoremap gf ^f/gf

" parse errors from terminal and put them in quickfix list
nnoremap <Leader>e  :call OpenErrorInQuickfix()<CR>

" switch between cpp and header file
nnoremap <F7> :call SwitchSourceHeader()<CR>


" }}}

" plugin configuration

" lualine {{{
lua << EOF

local function get_filename() return vim.fn.expand('%:~:.') end
local function lsp_not_active() return vim.tbl_isempty(vim.lsp.buf_get_clients(0)) end

local function diagnostics_ok()
    if lsp_not_active() then return '' end
    local w = vim.lsp.diagnostic.get_count(0, 'Warning')
    local e = vim.lsp.diagnostic.get_count(0, 'Error')
    if w ~= 0 or e ~= 0 then return '' end
    return ' '
 end

local function get_colors()
    if vim.g.color_scheme == 'everforest' then return {red = '#e67e80', green = '#a7c080', yellow = '#dbbc7f', orange = '#e69875'} end
    if vim.g.color_scheme == 'nord' then return {red = '#BF616A', green = '#A3BE8C', yellow = '#EBCB8B', orange = '#D08770'} end
    return {red = '#fb4934', green = '#b8bb26', yellow = '#fabd2f', orange = '#fe8019'}
end

local function get_git_branch()
    head = vim.fn.FugitiveHead(6)
    if head == '' then return nil end
    return ' ' .. head
end

local colors = get_colors()

require'lualine'.setup {
  options = { theme = vim.g.color_scheme },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {{get_git_branch}},
    lualine_c = {{get_filename}, { 'diff', color_added = colors.green, color_modified = colors.orange, color_removed = colors.red, symbols = {added = ' ', modified = ' ', removed = ' '} }},
    lualine_x = {{'diagnostics', sources = {'nvim_lsp'}, color_error = colors.red, color_warn = colors.yellow, color_info = nil, symbols = {error = ' ', warn = ' ', info = ' '}}, {diagnostics_ok}, 'filetype' }, 
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
}
EOF
" }}}

" vim-commentary {{{
autocmd FileType c,cpp,java set commentstring=//\ %s
" }}}

" indent-blankline {{{
let g:indent_blankline_filetype = ['python', 'json', 'bzl']
" }}}

" bufferline {{{
lua << EOF
require'bufferline'.setup{
    options = {
        numbers = "buffer_id",
        number_style = "",
        max_name_length = 50;
        tab_size = 0,
    }
}
EOF
" }}}

" nvim-colorizer {{{
lua require'colorizer'.setup()
" }}}

" nerdtree {{{
nnoremap <c-n> :NERDTreeToggle<CR>
nnoremap <Leader>n :NERDTreeFind<CR>

syntax on
filetype plugin indent on
:let g:NERDTreeWinSize=60
:let g:NERDTreeMapHelp = '<F1>'
"close vim if nerdtree is last open buffer
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
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

" ack.vim {{{
nnoremap <Leader>a :Ack!<Space>

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
let g:vimwiki_list = [{'path': '~/projects/vimwiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]
let g:mkdp_browser = 'firefox'
" }}}

" telescope {{{
nnoremap <leader>ff :lua require('telescope.builtin').find_files({previewer = false})<CR>
nnoremap <leader>fo :lua require('telescope.builtin').oldfiles({previewer = false})<CR>
nnoremap <leader>fb :lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>
nnoremap <leader>fh :lua require('telescope.builtin').command_history()<CR>
nnoremap <leader>fr :lua require('telescope.builtin').registers()<CR>
nnoremap <leader>gb :lua require('telescope.builtin').git_branches({cwd = vim.fn.expand("%:p:h")})<CR>
nnoremap <leader>gc :lua require('telescope.builtin').git_commits({cwd = vim.fn.expand("%:p:h")})<CR>
nnoremap <leader>fg :lua require('telescope.builtin').live_grep()<CR>
nnoremap <leader>bu :lua require('telescope.builtin').buffers()<CR>
nnoremap <leader>ht :lua require('telescope.builtin').help_tags()<CR>

nnoremap <leader>g. :lua require('telescope.builtin').live_grep({cwd = "$HOME/.cfg", vimgrep_arguments = { 'rg', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case', '--hidden' }, file_ignore_patterns = {".git"}})<CR>
nnoremap <leader>gw :lua require('telescope.builtin').live_grep({cwd = "$HOME/projects/vimwiki"})<CR>
nnoremap <leader>gn :lua require('telescope.builtin').live_grep({cwd = "$HOME/.config/nvim"})<CR>
nnoremap <leader>f. :lua require('telescope.builtin').find_files({prompt_title = ".cfg", cwd = "$HOME/.cfg", hidden = true, file_ignore_patterns = {".git"}})<CR>
nnoremap <leader>fn :lua require('telescope.builtin').find_files({prompt_title = ".config/nvim", cwd = "$HOME/.config/nvim"})<CR>

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

" git {{{

nnoremap <Leader>gl  :G log -n 1000<CR>
nnoremap <Leader>gs  :G<CR>:MaximizerToggle<CR>

" faster update (default 4000)
set updatetime=100
set signcolumn=auto:2
lua << EOF
require('gitsigns').setup()
EOF

" disable the default highlight group
let g:conflict_marker_highlight_group = ''

" Include text after begin and end markers
let g:conflict_marker_begin = '^<<<<<<< .*$'
let g:conflict_marker_end   = '^>>>>>>> .*$'

highlight ConflictMarkerBegin guibg=#2f7366
highlight ConflictMarkerOurs guibg=#2e5049
highlight ConflictMarkerTheirs guibg=#344f69
highlight ConflictMarkerEnd guibg=#2f628e
highlight ConflictMarkerCommonAncestorsHunk guibg=#754a81
" }}}

" bazel {{{
" Info: to make tab completion work copy '/etc/bash_completion.d/bazel-complete.bash' to '/etc/bash_completion.d/bazel'
let g:bazel_config = get(g:, 'bazel_config', "--config=adp")

autocmd FileType bzl nnoremap <buffer> gd :call GoToBazelDefinition()<CR>
nnoremap gbt :call GoToBazelTarget()<CR>

nnoremap <Leader>bt  :call RunBazelHere("test " . g:bazel_config . " -c opt" )<CR>
nnoremap <Leader>bdt :call DebugThisTest()<CR>
nnoremap <Leader>bb  :call RunBazelHere("build " . g:bazel_config . " -c opt")<CR>
nnoremap <Leader>bdb :call RunBazelHere("build " . g:bazel_config . " -c dbg")<CR>
nnoremap <Leader>bl  :call RunBazel()<CR>

" errorformats {{{ 
set errorformat=ERROR:\ %f:%l:%c:%m
set errorformat+=%f:%l:%c:%m
set errorformat+=[\ \ FAILED\ \ ]\ %m\ (%.%#

" Ignore build output lines starting with INFO:, Loading:, or [    
set errorformat+=%-GINFO:\ %.%#    
set errorformat+=%-GLoading:\ %.%#    
set errorformat+=%-G[%.%#    
" Errorformat settings
"
" * errorformat reference: http://vimdoc.sourceforge.net/htmldoc/quickfix.html#errorformat
" * look for message without consuming: https://stackoverflow.com/a/36959245/10923940
" * errorformat explanation: https://stackoverflow.com/a/29102995/10923940

" Ignore this error message, it is always redundant
" ERROR: <filename>:<line>:<col>: C++ compilation of rule '<target>' failed (Exit 1)
 set errorformat+=%-GERROR:\ %f:%l:%c:\ C++\ compilation\ of\ rule\ %m
 set errorformat+=%tRROR:\ %f:%l:%c:\ %m   " Generic bazel error handler
 set errorformat+=%tARNING:\ %f:%l:%c:\ %m " Generic bazel warning handler
" this rule is missing dependency declarations for the following files included by '<another-filename>'
"   '<fname-1>'
"   '<fname-2>'
"   ...
 set errorformat+=%Ethis\ rule\ is\ %m\ the\ following\ files\ included\ by\ \'%f\':
 set errorformat+=%C\ \ \'%m\'
 set errorformat+=%Z

" Test failures
 set errorformat+=FAIL:\ %m\ (see\ %f)            " FAIL: <test-target> (see <test-log>)

" test failures in async builds
 set errorformat+=%E%*[\ ]FAILED\ in%m
 set errorformat+=%C\ \ %f
 set errorformat+=%Z

" Errors in the build stage
 set errorformat+=%f:%l:%c:\ fatal\ %trror:\ %m         " <filename>:<line>:<col>: fatal error: <message>
 set errorformat+=%f:%l:%c:\ %trror:\ %m                " <filename>:<line>:<col>: error: <message>
 set errorformat+=%f:%l:%c:\ %tarning:\ %m              " <filename>:<line>:<col>: warning: <message>
 set errorformat+=%f:%l:%c:\ note:\ %m                  " <filename>:<line>:<col>: note: <message>
 set errorformat+=%f:%l:%c:\ \ \ requ%tred\ from\ here  " <filename>:<line>:<col>: <message>
 set errorformat+=%f(%l):\ %tarning:\ %m                " <filename>(<line>): warning: <message>
 set errorformat+=%f:%l:%c:\ %m                         " <filename>:<line>:<col>: <message>
 set errorformat+=%f:%l:\ %m                            " <filename>:<line>: <message>
" }}}

" }}}

" debugger {{{

" send gdb commands with '-exec <command>' in vimspector console window

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

" snippets {{{
let g:vsnip_snippet_dirs = [expand("~/.cfg/nvim/.vsnip")]
" Jump forward or backward
imap <expr> <C-j> vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<C-j>'
smap <expr> <C-j> vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<C-j>'
imap <expr> <C-k> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-k>'
smap <expr> <C-k> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-k>'

function s:TM_INCLUDEGUARD(context) abort
    let l:guard = expand('%')
    let l:guard = substitute(guard, "[./]", "_", "g")
    return toupper(guard)
endfunction
call vsnip#variable#register('TM_INCLUDEGUARD', function('s:TM_INCLUDEGUARD'))
" }}}

" treesitter {{{
lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  highlight = {
    enable = true,              -- false will disable the whole extension
    -- disable = {"json"},        -- list of language that will be disabled
  },
}
require "nvim-treesitter.configs".setup {
  textobjects = {
    select = {
      enable = true,
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
  },
  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
    keybindings = {
      toggle_query_editor = 'o',
      toggle_hl_groups = 'i',
      toggle_injected_languages = 't',
      toggle_anonymous_nodes = 'a',
      toggle_language_display = 'I',
      focus_language = 'f',
      unfocus_language = 'F',
      update = 'R',
      goto_node = '<cr>',
      show_help = '?',
    },
  }
}
EOF
" }}}

" todo-comments {{{
lua require("todo-comments").setup {}
nnoremap <leader>tq :TodoQuickfix<CR>
nnoremap <leader>ft :TodoTelescope<CR>
" }}}

" trouble {{{
lua require("trouble").setup {}
nnoremap <leader>xx <cmd>TroubleToggle<cr>
nnoremap <leader>xw <cmd>TroubleToggle lsp_workspace_diagnostics<cr>
nnoremap <leader>xd <cmd>TroubleToggle lsp_document_diagnostics<cr>
nnoremap <leader>xq <cmd>TroubleToggle quickfix<cr>
nnoremap <leader>xl <cmd>TroubleToggle loclist<cr>
" }}}

" nvim-lsp {{{

" formatting {{{
hi link LspDiagnosticsVirtualTextError Red
hi link LspDiagnosticsVirtualTextWarning Yellow
hi link LspDiagnosticsUnderlineError Red
hi link LspDiagnosticsUnderlineWarning Yellow
" }}}

" lspplugins {{{
lua require('lspkind').init()
" }}}

" server configs {{{
lua << EOF
require'lspinstall'.setup() -- important

local on_attach = function(client, bufnr)
  require "lsp_signature".on_attach()  -- Note: add in lsp client on-attach
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = {
    'documentation',
    'detail',
    'additionalTextEdits',
  }
}

-- Configure lua language server for neovim development
local lua_settings = {
  Lua = {
    runtime = {
      -- LuaJIT in the case of Neovim
      version = 'LuaJIT',
      path = vim.split(package.path, ';'),
    },
    diagnostics = {
      -- Get the language server to recognize the `vim` global
      globals = {'vim'},
    },
    workspace = {
      -- Make the server aware of Neovim runtime files
      library = {
        [vim.fn.expand('$VIMRUNTIME/lua')] = true,
        [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
      },
    },
  }
}

local function setup_servers()
    local servers = require'lspinstall'.installed_servers()
    for _, server in pairs(servers) do
        local config = { 
            capabilities = capabilities,
            on_attach = on_attach,
        }
        if server == "lua" then
          config.settings = lua_settings
        end
        if server == "vim" then
            config.init_options = { runtimepath = vim.fn.expand("~/.vim/") .. "," .. vim.fn.expand("~/.config/nvim/") }
        end
        if server == "cpp" then
            config.cmd = {require"lspinstall.util".install_path("cpp") .. "/clangd/bin/clangd", "--background-index", "--cross-file-rename"};
            -- config.cmd = {require"lspinstall.util".install_path("cpp") .. "/clangd/bin/clangd", "--background-index", "--cross-file-rename", "--compile-commands-dir=" .. vim.fn.getcwd()};
        end
        require'lspconfig'[server].setup(config)
    end
end

setup_servers()

-- Automatically reload after `:LspInstall <server>` so we don't have to restart neovim
require'lspinstall'.post_install_hook = function ()
  setup_servers() -- reload installed servers
  vim.cmd("bufdo e") -- this triggers the FileType autocmd that starts the server
end

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
    calc = true;
    nvim_lsp = true;
    nvim_lua = true;
    vsnip = true;
    ultisnips = true;
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

" keybindings {{{

nnoremap <leader>rn :lua vim.lsp.buf.rename()<CR>
nnoremap <leader>ca :lua vim.lsp.buf.code_action()<CR>
nnoremap [d :lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap ]d :lua vim.lsp.diagnostic.goto_next()<CR>

nnoremap gd :lua vim.lsp.buf.definition()<CR>
nnoremap gi :lua vim.lsp.buf.implementation()<CR>
nnoremap <leader>r :lua vim.lsp.buf.references()<CR>
nnoremap <leader>q :lua vim.lsp.diagnostic.set_loclist()<CR>
" }}}

" }}}

