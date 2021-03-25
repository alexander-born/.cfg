
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
Plug 'glepnir/galaxyline.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'ryanoasis/vim-devicons'
Plug 'akinsho/nvim-bufferline.lua'
" nerdtree
Plug 'scrooloose/nerdtree'
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

" galaxyline {{{
lua << EOF
local gl = require 'galaxyline'
local gls = gl.section
local devicons = require 'nvim-web-devicons'
local vcs = require 'galaxyline.provider_vcs'
local lspclient = require 'galaxyline.provider_lsp'
local condition = require 'galaxyline.condition'

gl.short_line_list = {'vim-plug', 'tagbar', 'Mundo', 'MundoDiff', 'coc-explorer', 'startify'}

-- Gruvbox
local colors = {
  bg0_h = '#1d2021',
  bg0 = '#282828',
  bg1 = '#3c3836',
  bg2 = '#504945',
  bg3 = '#665c54',
  bg4 = '#7c6f64',
  gray = '#928374',
  fg0 = '#fbf1c7',
  fg1 = '#ebdbb2',
  fg2 = '#d5c4a1',
  fg3 = '#bdae93',
  fg4 = '#a89984',
  bright_red = '#fb4934',
  bright_green = '#b8bb26',
  bright_yellow = '#fabd2f',
  bright_blue = '#83a598',
  bright_purple = '#d3869b',
  bright_aqua = '#8ec07c',
  bright_orange = '#fe8019',
  neutral_red = '#cc241d',
  neutral_green = '#98971a',
  neutral_yellow = '#d79921',
  neutral_blue = '#458588',
  neutral_purple = '#b16286',
  neutral_aqua = '#689d6a',
  neutral_orange = '#d65d0e',
  faded_red = '#9d0006',
  faded_green = '#79740e',
  faded_yellow = '#b57614',
  faded_blue = '#076678',
  faded_purple = '#8f3f71',
  faded_aqua = '#427b58',
  faded_orange = '#af3a03',
}

local mode_map = {
  ['n'] = {'NORMAL', colors.fg3, colors.bg2},
  -- ['n'] = {'NORMAL', colors.bright_green, colors.faded_green},
  ['i'] = {'INSERT', colors.bright_blue, colors.faded_blue},
  ['R'] = {'REPLACE', colors.bright_red, colors.faded_red},
  ['v'] = {'VISUAL', colors.bright_orange, colors.faded_orange},
  ['V'] = {'V-LINE', colors.bright_orange, colors.faded_orange},
  ['c'] = {'COMMAND', colors.bright_yellow, colors.faded_yellow},
  ['s'] = {'SELECT', colors.bright_orange, colors.faded_orange},
  ['S'] = {'S-LINE', colors.bright_orange, colors.faded_orange},
  ['t'] = {'TERMINAL', colors.bright_aqua, colors.faded_aqua},
  [''] = {'V-BLOCK', colors.bright_orange, colors.faded_orange},
  [''] = {'S-BLOCK', colors.bright_orange, colors.faded_orange},
  ['Rv'] = {'VIRTUAL'},
  ['rm'] = {'--MORE'},
}

local sep = {
  right_filled = '', -- e0b2
  left_filled = '', -- e0b0
  right = '', -- e0b3
  left = '', -- e0b1
}

local icons = {
  dos = '', -- e70f
  unix = '', -- f17c
  mac = '', -- f179
  paste = '', -- f691
  git = '', -- f7a1
  added = '', -- f457
  removed = '', --f458
  modified = '', --f459
  locker = '', -- f023
  not_modifiable = '', -- f05e
  unsaved = '', -- f0c7
  pencil = '', -- f040
  page = '☰', -- 2630
  line_number = '', -- e0a1
  connected = '', -- f817
  disconnected = '', -- f818
  ok = '', -- f058
  error = '', -- f658
  warning = '', -- f06a
  info = '', -- f05a
  hint = '', -- f834
}

local function mode_hl()
  local mode = mode_map[vim.fn.mode()]
  if mode == nil then
    mode = mode_map['v']
    return {'V-BLOCK', mode[2], mode[3]}
  end
  return mode
end

local function highlight(group, fg, bg, gui)
  local cmd = string.format('highlight %s guifg=%s guibg=%s', group, fg, bg)
  if gui ~= nil then cmd = cmd .. ' gui=' .. gui end
  vim.cmd(cmd)
end

local function buffer_not_empty()
  if vim.fn.empty(vim.fn.expand('%:t')) ~= 1 then return true end
  return false
end

local function diagnostic_exists()
  return not vim.tbl_isempty(vim.lsp.buf_get_clients(0))
end

local function diag(severity)
	local n = vim.lsp.diagnostic.get_count(0, severity)
	if n == 0 then return '' end
	local diag_mapping = {
    ['Warning'] = icons.warning,
    ['Error'] = icons.error,
    ['Information'] = icons.info,
    ['Hint'] = icons.hint,
	}
	return string.format(' %s %d ', diag_mapping[severity], n)
end

local function wide_enough(width)
  local squeeze_width = vim.fn.winwidth(0)
  if squeeze_width > width then return true end
  return false
end

local function in_vcs()
  if vim.bo.buftype == 'help' then return false end
  return condition.check_git_workspace()
end

gls.left[1] = {
  ViMode = {
    provider = function()
      local label, fg, nested_fg = unpack(mode_hl())
      highlight('GalaxyViMode', colors.bg1, fg)
      highlight('GalaxyViModeInv', fg, nested_fg)
      highlight('GalaxyViModeNested', colors.fg2, nested_fg)
      highlight('GalaxyViModeInvNested', nested_fg, colors.bg1)
      return string.format('  %s ', label)
    end,
    separator = sep.left_filled,
    separator_highlight = 'GalaxyViModeInv',
  }
}
gls.left[2] = {
  FileIcon = {
    provider = function()
      local extention = vim.fn.expand('%:e')
      local icon, iconhl = devicons.get_icon(extention)
      if icon == nil then return '' end
      local fg = vim.fn.synIDattr(vim.fn.hlID(iconhl), 'fg')
      local _, _, bg = unpack(mode_hl())
      highlight('GalaxyFileIcon', fg, bg)
      return ' ' .. icon .. ' '
    end,
    condition = buffer_not_empty,
  }
}
gls.left[3] = {
  FileName = {
    provider = function()
      if not buffer_not_empty() then return '' end
      local fname
      if wide_enough(120) then
        fname = vim.fn.fnamemodify(vim.fn.expand('%'), ':~:.')
      else
        fname = vim.fn.expand '%:t'
      end
      if #fname == 0 then return '' end
      if vim.bo.readonly then fname = fname .. ' ' .. icons.locker end
      if not vim.bo.modifiable then fname = fname .. ' ' .. icons.not_modifiable end
      if vim.bo.modified then fname = fname .. ' ' .. icons.pencil end
      return ' ' .. fname .. ' '
    end,
    highlight = 'GalaxyViModeNested',
    condition = buffer_not_empty,
  }
}
gls.left[4] = {
  LeftSep = {
    provider = function() return sep.left_filled end,
    highlight = 'GalaxyViModeInvNested',
  }
}
gls.left[5] = {
  Paste = {
    provider = function()
      if vim.o.paste then return 'Paste ' end
      return ''
    end,
    icon = '  ' .. icons.paste .. ' ',
    highlight = {colors.bright_purple, colors.bg1},
  }
}
gls.left[6] = {
  GitIcon = {
    provider = function ()
      highlight('DiffAdd', colors.bright_green, colors.bg1)
      highlight('DiffChange', colors.bright_orange, colors.bg1)
      highlight('DiffDelete', colors.bright_red, colors.bg1)
      if in_vcs() and wide_enough(85) then
        return '  ' .. icons.git .. ' '
      end
      return ''
    end,
    highlight = {colors.bright_red, colors.bg1},
  }
}
gls.left[7] = {
  GitBranch = {
    provider = function ()
      if in_vcs() and wide_enough(85) then
        return vcs.get_git_branch()
      end
      return ''
    end,
    highlight = {colors.fg2, colors.bg1},
  }
}
gls.left[8] = {
  DiffAdd = {
    provider = function ()
      if condition.check_git_workspace() and wide_enough(95) then
        return vcs.diff_add()
      end
      return ''
    end,
    icon = icons.added .. ' ',
    highlight = {colors.bright_green, colors.bg1},
  }
}
gls.left[9] = {
  DiffModified = {
    provider = function ()
      if condition.check_git_workspace() and wide_enough(95) then
        return vcs.diff_modified()
      end
      return ''
    end,
    icon = icons.modified .. ' ',
    highlight = {colors.bright_orange, colors.bg1},
  }
}
gls.left[10] = {
  DiffRemove = {
    provider = function ()
      if condition.check_git_workspace() and wide_enough(95) then
        return vcs.diff_remove()
      end
      return ''
    end,
    icon = icons.removed .. ' ',
    highlight = {colors.bright_red, colors.bg1},
  }
}

gls.right[1] = {
  CocStatus = {
    provider = function ()
      if not buffer_not_empty() or not wide_enough(110) then return '' end
      if vim.fn.exists('*coc#rpc#start_server') == 1 then
        return '  ' .. vim.fn['coc#status']() .. ' '
      end
      return ''
    end,
    highlight = {colors.fg4, colors.bg1},
  }
}
gls.right[2] = {
  LspStatus = {
    provider = function()
      local connected = diagnostic_exists()
      if connected then
        return string.format('%s %s ', icons.connected, lspclient.get_lsp_client())
      else
        return ''
      end
    end,
    highlight = {colors.fg4, colors.bg1},
  }
}
gls.right[3] = {
  DiagnosticOk = {
    provider = function()
      if not diagnostic_exists() then return '' end
      local w = vim.lsp.diagnostic.get_count(0, 'Warning')
      local e = vim.lsp.diagnostic.get_count(0, 'Error')
      local i = vim.lsp.diagnostic.get_count(0, 'Information')
      local h = vim.lsp.diagnostic.get_count(0, 'Hint')
      if w ~= 0 or e ~= 0 or i ~= 0 or h ~= 0 then return '' end
      return icons.ok .. ' '
    end,
    highlight = {colors.bright_green, colors.bg1},
  }
}
gls.right[4] = {
  DiagnosticError = {
    provider = function()
      return diag('Error')
    end,
    highlight = {colors.bright_red, colors.bg1},
  }
}
gls.right[5] = {
  DiagnosticWarn = {
    provider = function()
      return diag('Warning')
    end,
    highlight = {colors.bright_yellow, colors.bg1},
  }
}
gls.right[6] = {
  DiagnosticInfo = {
    provider = function()
      return diag('Information')
    end,
    highlight = {colors.bright_blue, colors.bg1},
  }
}
gls.right[7] = {
  DiagnosticHint = {
    provider = function()
      return diag('Hint')
    end,
    highlight = {colors.bright_yellow, colors.bg1},
  }
}
gls.right[8] = {
  RightSepNested = {
    provider = function() return sep.right_filled end,
    highlight = 'GalaxyViModeInvNested',
  }
}
gls.right[9] = {
  FileFormat = {
    provider = function()
      if not buffer_not_empty() or not wide_enough(70) then return '' end
      local icon = icons[vim.bo.fileformat] or ''
      return string.format('  %s %s ', icon, vim.bo.fileencoding)
    end,
    highlight = 'GalaxyViModeNested',
  }
}
gls.right[10] = {
  RightSep = {
    provider = function() return sep.right_filled end,
    highlight = 'GalaxyViModeInv',
  }
}
gls.right[11] = {
  PositionInfo = {
    provider = function()
      if not buffer_not_empty() or not wide_enough(60) then return '' end
      return string.format(
        '  %s %s:%s ',
        icons.line_number, vim.fn.line('.'), vim.fn.col('.')
      )
    end,
    highlight = 'GalaxyViMode',
  }
}
gls.right[12] = {
  PercentInfo = {
    provider = function ()
      if not buffer_not_empty() or not wide_enough(65) then return '' end
      local percent = math.floor(100 * vim.fn.line('.') / vim.fn.line('$'))
      return string.format(' %s %s%s', icons.page, percent, '% ')
    end,
    highlight = 'GalaxyViMode',
    separator = sep.right,
    separator_highlight = 'GalaxyViMode',
  }
}

local short_map = {
  ['vim-plug'] = 'Plugins',
  ['coc-explorer'] = 'Explorer',
  ['startify'] = 'Starfity',
  ['tagbar'] = 'Tagbar',
  ['Mundo'] = 'History',
  ['MundoDiff'] = 'Diff',
}

function has_file_type()
    local f_type = vim.bo.filetype
    if not f_type or f_type == '' then
        return false
    end
    return true
end

gls.short_line_left[1] = {
  BufferType = {
    provider = function ()
      local label, fg, nested_fg = unpack(mode_hl())
      highlight('GalaxyViMode', colors.bg1, fg)
      highlight('GalaxyViModeInv', fg, nested_fg)
      highlight('GalaxyViModeInvNested', nested_fg, colors.bg1)
      local name = short_map[vim.bo.filetype] or 'Editor'
      return string.format('  %s ', name)
    end,
    highlight = 'GalaxyViMode',
    condition = has_file_type,
    separator = sep.left_filled,
    separator_highlight = 'GalaxyViModeInv',
  }
}
gls.short_line_left[2] = {
  ShortLeftSepNested = {
    provider = function() return sep.left_filled end,
    highlight = 'GalaxyViModeInvNested',
  }
}
gls.short_line_right[1] = {
  ShortRightSepNested = {
    provider = function() return sep.right_filled end,
    highlight = 'GalaxyViModeInvNested',
  }
}
gls.short_line_right[2] = {
  ShortRightSep = {
    provider = function() return sep.right_filled end,
    highlight = 'GalaxyViModeInv',
  }
}
EOF
" }}}

" indent-blankline {{{
" let g:indent_blankline_filetype = ['python']
let g:indentLine_fileType = ['python', 'json', 'bzl']
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

" bazel-lsp Tim Rakowski {{{
source ~/buildtools/bazel_vim/bazel.vim
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
let g:vimwiki_list = [{'path': '~/vimwiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]
let g:mkdp_browser = 'firefox'
" }}}

" telescope {{{
nnoremap <leader>ff :lua require('telescope.builtin').find_files({previewer = false})<CR>
nnoremap <leader>fo :lua require('telescope.builtin').oldfiles({previewer = false})<CR>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

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

" git signs {{{
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
