" lsp
nnoremap <leader>rn :lua vim.lsp.buf.rename()<CR>
nnoremap <leader>ca :lua vim.lsp.buf.code_action()<CR>
nnoremap [d :lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap ]d :lua vim.lsp.diagnostic.goto_next()<CR>
nnoremap gd :lua vim.lsp.buf.definition()<CR>
nnoremap gi :lua vim.lsp.buf.implementation()<CR>
nnoremap <leader>r :lua vim.lsp.buf.references()<CR>
nnoremap <leader>q :lua vim.lsp.diagnostic.set_qflist()<CR>

" filetree
nnoremap <c-n> :lua require'config.nvimtree'.nvim_tree_toggle_project()<CR>
nnoremap <Leader>n :lua require'config.nvimtree'.nvim_tree_find_file()<CR>

" parse errors from terminal and put them in quickfix list
nnoremap <Leader>e  :call OpenErrorInQuickfix()<CR>

" switch between cpp and header file
nnoremap <F7> :call SwitchSourceHeader()<CR>

" telescope
nnoremap <leader>ff :lua require('telescope.builtin').find_files({previewer = false})<CR>
nnoremap <leader>fo :lua require('telescope.builtin').oldfiles({previewer = false})<CR>
nnoremap <leader>fq :lua require('telescope.builtin').quickfix()<CR>
nnoremap <leader>fh :lua require('telescope.builtin').command_history()<CR>
nnoremap <leader>fr :lua require('telescope.builtin').registers()<CR>
nnoremap <leader>fb :lua require('telescope.builtin').buffers({sort_mru = true})<CR>
nnoremap <leader>ht :lua require('telescope.builtin').help_tags()<CR>

nnoremap <leader>f. :lua require('telescope.builtin').find_files({prompt_title = ".cfg", cwd = "$HOME/.cfg", hidden = true, file_ignore_patterns = {".git"}})<CR>
nnoremap <leader>fn :lua require('telescope.builtin').find_files({prompt_title = ".config/nvim", search_dirs = {"$HOME/.config/nvim", "$HOME/.local/share/nvim/site/pack/packer"}})<CR>

nnoremap <leader>gr  :lua require('telescope.builtin').live_grep()<CR>
nnoremap <leader>grb :lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>
nnoremap <leader>grl :lua require('telescope.builtin').live_grep({search_dirs = {"application/adp/perception/lanes", "application/adp/ros/simulation/perception/lanes", "application/adp/activities/lanes"}})<CR>
nnoremap <leader>grm :lua require('telescope.builtin').live_grep({search_dirs = {"application/adp/map"}})<CR>
nnoremap <leader>gra :lua require('telescope.builtin').live_grep({search_dirs = {"application/adp"}})<CR>
nnoremap <leader>grr :lua require('telescope.builtin').live_grep({search_dirs = {"application/adp/perception/road", "application/adp/map", "application/adp/activities/road"}})<CR>
nnoremap <leader>gr. :lua require('telescope.builtin').live_grep({cwd = "$HOME/.cfg", vimgrep_arguments = { 'rg', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case', '--hidden' }, file_ignore_patterns = {".git"}})<CR>
nnoremap <leader>grw :lua require('telescope.builtin').live_grep({cwd = "$HOME/projects/vimwiki"})<CR>
nnoremap <leader>grn :lua require('telescope.builtin').live_grep({search_dirs = {"$HOME/.config/nvim", "$HOME/.local/share/nvim/site/pack/packer"}})<CR>

" git
nnoremap <Leader>gl :G log -n 1000<CR>
nnoremap <Leader>gd :GitDiff<CR>
nnoremap <Leader>gs :G<CR>:MaximizerToggle<CR>
vnoremap <Leader>gb :GBrowse<CR>
nnoremap <leader>gb :lua require('telescope.builtin').git_branches({cwd = vim.fn.expand("%:p:h")})<CR>
nnoremap <leader>gc :lua require('telescope.builtin').git_commits({cwd = vim.fn.expand("%:p:h")})<CR>

" bazel
autocmd FileType bzl nnoremap <buffer> gd :call GoToBazelDefinition()<CR>
nnoremap gbt :call GoToBazelTarget()<CR>
nnoremap <Leader>bt  :call RunBazelHere("test " . g:bazel_config . " -c opt" )<CR>
nnoremap <Leader>bb  :call RunBazelHere("build " . g:bazel_config . " -c opt")<CR>
nnoremap <Leader>bdb :call RunBazelHere("build " . g:bazel_config . " -c dbg")<CR>
nnoremap <Leader>bdt :lua  DebugThisTest()<CR>
nnoremap <Leader>bl  :call RunBazel()<CR>

" ack
nnoremap <Leader>a :Ack!<Space>

" undotree
nnoremap <Leader>ut :UndotreeToggle<CR>

" debugger
nnoremap <leader>m :MaximizerToggle!<CR>
nnoremap <leader>dd :call vimspector#Launch()<CR>
nnoremap <leader>dc :call GotoWindow(g:vimspector_session_windows.code)<CR>
nnoremap <leader>dt :call GotoWindow(g:vimspector_session_windows.tagpage)<CR>
nnoremap <leader>dv :call GotoWindow(g:vimspector_session_windows.variables)<CR>
nnoremap <leader>dw :call GotoWindow(g:vimspector_session_windows.watches)<CR>
nnoremap <leader>ds :call GotoWindow(g:vimspector_session_windows.stack_trace)<CR>
nnoremap <leader>de :call vimspector#Reset()<CR>
nnoremap <leader>dtcb :call vimspector#CleanLineBreakpoint()<CR>

nnoremap <leader>l <Plug>VimspectorStepInto
nnoremap <leader>j <Plug>VimspectorStepOver
nnoremap <leader>k <Plug>VimspectorStepOut
nnoremap <leader>dr <Plug>VimspectorRestart
nnoremap <leader>d<space> :call vimspector#Continue()<CR>

nnoremap <leader>rc <Plug>VimspectorRunToCursor
nnoremap <leader>bp <Plug>VimspectorToggleBreakpoint
nnoremap <leader>dbp :call vimspector#ClearBreakpoints()<CR>
nnoremap <leader>cbp <Plug>VimspectorToggleConditionalBreakpoint

" todo-comments
nnoremap <leader>tq :TodoQuickfix<CR>
nnoremap <leader>ft :TodoTelescope<CR>

" trouble
nnoremap <leader>xx <cmd>TroubleToggle<cr>
nnoremap <leader>xw <cmd>TroubleToggle lsp_workspace_diagnostics<cr>
nnoremap <leader>xd <cmd>TroubleToggle lsp_document_diagnostics<cr>
nnoremap <leader>xq <cmd>TroubleToggle quickfix<cr>
nnoremap <leader>xl <cmd>TroubleToggle loclist<cr>

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

" single line diffput/diffget shortcuts
nnoremap <leader>dp V:diffput<cr>
nnoremap <leader>do V:diffget<cr>
