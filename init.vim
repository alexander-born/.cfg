
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
Plug 'ggandor/lightspeed.nvim'
" undotree
Plug 'mbbill/undotree'
" appearance
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'hoob3rt/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'akinsho/nvim-bufferline.lua'
Plug 'norcalli/nvim-colorizer.lua'
Plug 'folke/todo-comments.nvim'
" filetree
Plug 'kyazdani42/nvim-tree.lua'
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
Plug 'tpope/vim-rhubarb'
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

" spcific user config {{{
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
let g:everforest_disable_italic_comment = 1
set background=dark
exe "colorscheme " . g:color_scheme
autocmd ColorScheme everforest call everforest#highlight('DiffText', ['NONE', 'NONE', 'NONE'], ['#546b76', '17', 'LightBlue'])
" }}}

" custom function {{{
lua << EOF
local function write_to_file(filename, lines)
    vim.cmd('e ' .. filename)
    vim.cmd('%delete')
    for _,line in pairs(lines) do
        vim.cmd("call append(line('$'), '" .. line .. "')")
    end
    vim.cmd('1d')
    vim.cmd('w')
    vim.cmd('e#')
end

function _G.create_cpp_vimspector_json_for_bazel_test()
    local test_filter = require('bazel').get_gtest_filter()
    local executable =  require('bazel').get_bazel_test_executable()
    local lines = {
        '{',
        '  "configurations": {',
        '    "GTest": {',
        '      "adapter": "vscode-cpptools",',
        '      "configuration": {',
        '        "request": "launch",',
        '        "program": "' .. executable .. '",',
        '        "args": ["--gtest_filter=\'\'' .. test_filter .. '\'\'"],',
        '        "stopOnEntry": false',
        '      }',
        '    }',
        '  }',
        '}'}
    write_to_file('.vimspector.json', lines)
end

function _G.DebugThisTest()
    create_cpp_vimspector_json_for_bazel_test()
    vim.cmd('new')
    vim.cmd('call termopen("bazel build " . g:bazel_config . " -c dbg " . g:current_bazel_target, {"on_exit": "StartVimspector"})')
end
EOF

function! StartVimspector(job_id, code, event) dict
    if a:code == 0
        close
        call vimspector#Launch()
    endif
endfun

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
" Y will yank to end of line
nnoremap Y y$
" deletes visual selection and pastes without changing default register
vnoremap p "_dP
" go to first file on line
nnoremap gf ^f/gf

" parse errors from terminal and put them in quickfix list
nnoremap <Leader>e  :call OpenErrorInQuickfix()<CR>

" switch between cpp and header file
nnoremap <F7> :call SwitchSourceHeader()<CR>

" single line diffput/diffget shortcuts
nnoremap <leader>dp V:diffput<cr>
nnoremap <leader>do V:diffget<cr>


" }}}

" plugin configuration

" lualine {{{
lua << EOF

local function get_filename()
    local data = vim.fn.expand('%:~:.')
    if vim.bo.modified then
        data = data .. ' [+]'
    elseif vim.bo.modifiable == false or vim.bo.readonly == true then
        data = data .. ' [-]'
    end
    return data
end

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

" filetree {{{
nnoremap <c-n> :lua NvimTreeToggleProject()<CR>
nnoremap <Leader>n :lua nvim_tree_find_file()<CR>

lua << EOF
vim.g.project_path = vim.fn.getcwd()
vim.g.nvim_tree_width = 60
vim.g.nvim_tree_bindings = { { key = {"<Leader>gr", "gr" }, cb = ":lua grep_at_current_tree_node()<CR>"} }

function nvim_tree_find_file()
  local function starts_with(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
  end

  local cur_path = vim.fn.expand('%:p:h')

  if starts_with(cur_path, vim.g.project_path) then
    require('nvim-tree').find_file(true)
  else
    require('nvim-tree').refresh()
    require('nvim-tree.lib').change_dir(cur_path)
    require('nvim-tree').find_file(true)
  end
end

function NvimTreeToggleProject()
    vim.cmd('lcd ' .. vim.g.project_path)
    require'nvim-tree'.toggle()
end
function grep_at_current_tree_node()
    local node = require('nvim-tree.lib').get_node_at_cursor()
    if not node then return end
    require('telescope.builtin').live_grep({search_dirs = {node.absolute_path}})
end
EOF

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

" lightspeed {{{
nmap ,s <Plug>Lightspeed_s
nmap ,S <Plug>Lightspeed_S
lua require'lightspeed'.setup { }
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
nnoremap <leader>fq :lua require('telescope.builtin').quickfix()<CR>
nnoremap <leader>fh :lua require('telescope.builtin').command_history()<CR>
nnoremap <leader>fr :lua require('telescope.builtin').registers()<CR>
nnoremap <leader>grb :lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>
nnoremap <leader>grl :lua require('telescope.builtin').live_grep({search_dirs = {"application/adp/perception/lanes", "application/adp/ros/simulation/perception/lanes", "application/adp/activities/lanes"}})<CR>
nnoremap <leader>grm :lua require('telescope.builtin').live_grep({search_dirs = {"application/adp/map"}})<CR>
nnoremap <leader>gra :lua require('telescope.builtin').live_grep({search_dirs = {"application/adp"}})<CR>
nnoremap <leader>grr :lua require('telescope.builtin').live_grep({search_dirs = {"application/adp/perception/road", "application/adp/map", "application/adp/activities/road"}})<CR>
nnoremap <leader>fg :lua require('telescope.builtin').live_grep()<CR>
nnoremap <leader>gr :lua require('telescope.builtin').live_grep()<CR>
nnoremap <leader>fb :lua require('telescope.builtin').buffers()<CR>
nnoremap <leader>ht :lua require('telescope.builtin').help_tags()<CR>

nnoremap <leader>gr. :lua require('telescope.builtin').live_grep({cwd = "$HOME/.cfg", vimgrep_arguments = { 'rg', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case', '--hidden' }, file_ignore_patterns = {".git"}})<CR>
nnoremap <leader>grw :lua require('telescope.builtin').live_grep({cwd = "$HOME/projects/vimwiki"})<CR>
nnoremap <leader>grn :lua require('telescope.builtin').live_grep({cwd = "$HOME/.config/nvim"})<CR>
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
nnoremap <Leader>gd  :GitDiff<CR>
nnoremap <Leader>gs  :G<CR>:MaximizerToggle<CR>
nnoremap <leader>gb :lua require('telescope.builtin').git_branches({cwd = vim.fn.expand("%:p:h")})<CR>
nnoremap <leader>gc :lua require('telescope.builtin').git_commits({cwd = vim.fn.expand("%:p:h")})<CR>

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

let g:github_enterprise_urls = ['https://cc-github.bmwgroup.net']

command! DiffHistory call s:view_git_history()
command! GitDiff call s:view_git_diff()

" custom git functions {{{

function! s:view_git_diff() abort
  Git difftool --name-only !
  cclose
  call s:diff_current_quickfix_entry_with_git_status()
endfunction

function! s:view_git_history() abort
    Git difftool --name-only ! !^@
    nnoremap <buffer> <CR> <CR><BAR>:call <sid>diff_current_quickfix_entry()<CR>
    call s:diff_current_quickfix_entry()
    11copen
    wincmd p
endfunction

function! s:diff_current_quickfix_entry_with_git_status() abort
    windo diffoff!
    let qf = s:get_git_diff_quickfix_list()
    if s:qf_has_diff_items(l:qf)
        let diff = s:get_current_qf_diff_entry(l:qf)
        let fugitive_file = s:get_fugitive_file(l:diff)
        let file = s:get_modified_file(l:diff)
        call s:open_git_status_on_bottom(l:file)
        call s:open_modified_file()
        call s:diff_with(l:fugitive_file)
        wincmd p
    else
        echo "Nothing to diff."
    endif
endfunction

function! s:get_current_qf_diff_entry(qf)
    return a:qf.context.items[a:qf.idx - 1].diff
endfunction

function! s:get_git_diff_quickfix_list()
    return getqflist({'context': 0, 'idx': 0})
endfunction

function! s:get_fugitive_file(diff)
    return a:diff[0].filename
endfunction

function! s:get_modified_file(diff)
    return fnameescape(strpart(a:diff[0].module, 2))
endfunction

function! s:qf_has_diff_items(qf) abort
    return get(a:qf, 'idx') && type(get(a:qf, 'context')) == type({}) && type(get(a:qf.context, 'items')) == type([])
endfunction

function! s:open_git_status_on_bottom(file) abort
  Git
  wincmd o
  exe "silent! norm /" . substitute(a:file, "\/", "\\\\\/", "g") . "\r"
  nnoremap <buffer><CR> :call <SID>open_diff_from_git_status()<CR>
  call s:add_diff_mappings()
  aboveleft wincmd s
  wincmd p
  resize 15
endfunction

function! s:open_git_status_on_left(file) abort
  Git
  wincmd o
  exe "silent! norm /" . substitute(a:file, "\/", "\\\\\/", "g") . "\r"
  nnoremap <buffer><CR> :call <SID>open_diff_from_git_status()<CR>
  call s:add_diff_mappings()
  wincmd v
  1wincmd w
  vertical resize 50
endfunction

function! s:is_current_git_status_file(idx, val) abort
    let git_dir = FugitiveGitDir()
    let working_dir = strpart(l:git_dir, 0, strlen(l:git_dir) - 4) " removes '.git'
    let file = substitute(fugitive#StatusCfile(), l:working_dir, "", "")
    let qf_entry = s:get_modified_file(a:val.diff)
    return l:qf_entry == l:file
endfunction

function! s:open_diff_from_git_status() abort
    let qf = s:get_git_diff_quickfix_list()
    if s:qf_has_diff_items(l:qf)
        let items = deepcopy(l:qf.context.items)
        call filter(l:items, function('s:is_current_git_status_file'))
        if len(l:items) == 1
            let idx = index(l:qf.context.items, l:items[0]) + 1
            call setqflist([], 'r', {'idx': l:idx})
            call s:diff_current_quickfix_entry_with_git_status()
        endif
    endif
endfunction

function! s:open_modified_file() abort
    wincmd p
    cc
    call s:add_diff_mappings()
endfunction

function! s:diff_with(filename) abort
    exe 'vertical leftabove diffsplit' a:filename
    call s:add_diff_mappings()
endfunction

function! s:add_diff_mappings() abort
    nnoremap <buffer>]q :1wincmd w <BAR> :cnext <BAR> :call <SID>diff_current_quickfix_entry_with_git_status()<CR>
    nnoremap <buffer>[q :1wincmd w <BAR> :cprevious <BAR> :call <SID>diff_current_quickfix_entry_with_git_status()<CR>
endfunction

function s:diff_current_quickfix_entry() abort
    " Cleanup windows
    windo diffoff!
    for window in getwininfo()
        if window.winnr !=? winnr() && !window.quickfix
            exe 'bdelete' window.bufnr
        endif
    endfor
    cc
    call s:add_mappings()
    let qf = s:get_git_diff_quickfix_list()
    if s:qf_has_diff_items(l:qf)
        let diff = s:get_current_qf_diff_entry(l:qf)
        exe 'vertical diffsplit' s:get_fugitive_file(l:diff)
        call s:add_mappings()
    endif
endfunction

function! s:add_mappings() abort
    nnoremap <buffer>]q :cnext <BAR> :call <sid>diff_current_quickfix_entry()<CR>
    nnoremap <buffer>[q :cprevious <BAR> :call <sid>diff_current_quickfix_entry()<CR>
endfunction

" }}}

" }}}

" bazel {{{
" Info: to make tab completion work copy '/etc/bash_completion.d/bazel-complete.bash' to '/etc/bash_completion.d/bazel'
let g:bazel_config = get(g:, 'bazel_config', "--config=adp")

autocmd FileType bzl nnoremap <buffer> gd :call GoToBazelDefinition()<CR>
nnoremap gbt :call GoToBazelTarget()<CR>

nnoremap <Leader>bt  :call RunBazelHere("test " . g:bazel_config . " -c opt" )<CR>
nnoremap <Leader>bb  :call RunBazelHere("build " . g:bazel_config . " -c opt")<CR>
nnoremap <Leader>bdb :call RunBazelHere("build " . g:bazel_config . " -c dbg")<CR>
nnoremap <Leader>bdt :lua  DebugThisTest()<CR>
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

" undotree {{{
nnoremap <Leader>ut :UndotreeToggle<CR>
" if has("persistent_undo")
"    let target_path = expand('~/.local/nvim/.undodir')

"     " create the directory and any parent directories
"     " if the location does not exist.
"     if !isdirectory(target_path)
"         call mkdir(target_path, "p", 0700)
"     endif

"     let &undodir=target_path
"     set undofile
" endif
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
" nnoremap <leader>do :call GotoWindow(g:vimspector_session_windows.output)<CR>
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
    swap = {
      enable = true,
      swap_next = {
        ["<leader>sa"] = "@parameter.inner",
      },
      swap_previous = {
        ["<leader>sA"] = "@parameter.inner",
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
        if server == "python" then 
            config.settings = { python = { analysis = { extraPaths = { vim.fn.getcwd() } } } }
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
  source = {
    path = true;
    buffer = true;
    calc = true;
    nvim_lsp = true;
    nvim_lua = true;
    vsnip = true;
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

