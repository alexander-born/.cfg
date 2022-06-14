-- lsp
-- Remap space as leader key
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local map = vim.keymap.set
map('n', '<leader>rn', vim.lsp.buf.rename)
map('n', '<leader>ca', vim.lsp.buf.code_action)
map('n', '[d', vim.diagnostic.goto_prev)
map('n', ']d', vim.diagnostic.goto_next)
map('n', 'gd', vim.lsp.buf.definition)
map('n', 'gi', vim.lsp.buf.implementation)
map('n', '<leader>r', vim.lsp.buf.references)
map('n', '<leader>q', vim.diagnostic.setqflist)

-- filetree
map('n', '<C-n>', require'config.nvimtree'.nvim_tree_toggle_project)
map('n', '<Leader>n', require'config.nvimtree'.nvim_tree_find_file)

-- parse errors from terminal and put them in quickfix list
map('n', '<Leader>e',  vim.fn.OpenErrorInQuickfix)

-- switch between cpp and header file
map('n', '<F7>', vim.fn.SwitchSourceHeader)

-- telescope
local builtin = require'telescope.builtin'
map('n', '<leader>ff',  function() builtin.find_files({previewer = false}) end)
map('n', '<leader>fo',  function() builtin.oldfiles({previewer = false}) end)
map('n', '<leader>fw',  function() builtin.oldfiles({previewer = false, cwd_only = true}) end)
map('n', '<leader>fb',  function() builtin.buffers({sort_mru = true}) end)
map('n', '<leader>fq',  builtin.quickfix)
map('n', '<leader>fh',  builtin.command_history)
map('n', '<leader>fr',  builtin.registers)
map('n', '<leader>fl',  builtin.resume)
map('n', '<leader>ht',  builtin.help_tags)
map('n', '<leader>gr',  builtin.live_grep)
map('n', '<leader>grb', builtin.current_buffer_fuzzy_find)
map('n', '<leader>fy',  require'telescope'.extensions.neoclip.default)
map('n', '<leader>f.',  function() builtin.find_files({prompt_title = ".cfg", cwd = "$HOME", search_dirs = {"$HOME/.cfg", "$HOME/.cfg_work"}, hidden = true, file_ignore_patterns = {".git"}}) end)
map('n', '<leader>fn',  function() builtin.find_files({prompt_title = ".config/nvim", search_dirs = {"$HOME/.config/nvim", "$HOME/.local/share/nvim/site/pack/packer"}}) end)
map('n', '<leader>fa',  function() builtin.find_files({prompt_title = "application/adp", search_dirs = {"application/adp"}, hidden = true, file_ignore_patterns = {".git"}, previewer = false}) end)
map('n', '<leader>gr.', function() builtin.live_grep({cwd = "$HOME", search_dirs = {"$HOME/.cfg", "$HOME/.cfg_work"}, vimgrep_arguments = { 'rg', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case', '--hidden' }, file_ignore_patterns = {".git"}}) end)
map('n', '<leader>grw', function() builtin.live_grep({cwd = "$HOME/projects/vimwiki"}) end)
map('n', '<leader>grn', function() builtin.live_grep({search_dirs = {"$HOME/.config/nvim", "$HOME/.local/share/nvim/site/pack/packer"}}) end)

-- git
map('n', '<leader>gb', function() builtin.git_branches({cwd = vim.fn.expand("%:p:h")}) end)
map('n', '<leader>gc', function() builtin.git_bcommits({cwd = vim.fn.expand("%:p:h")}) end)
map('n', '<Leader>gl', ':G log -n 1000<CR>')
map('n', '<Leader>gd', ':GitDiff<CR>')
map('n', '<Leader>gs', ':G | MaximizerToggle<CR>')
map('v', '<Leader>gb', ':GBrowse<CR>')

-- bazel
vim.api.nvim_create_autocmd("FileType", { pattern = "bzl", callback = function() map('n', 'gd', vim.fn.GoToBazelDefinition, { buffer = 0 }) end })
map('n', 'gbt',         vim.fn.GoToBazelTarget)
map('n', '<Leader>bl',  vim.fn.RunBazel)
map('n', '<Leader>bdt', require'config.bazel'.DebugThisTest)
map('n', '<Leader>y',   require'config.bazel'.YankLabel)
map('n', '<Leader>bt',  function() vim.fn.RunBazelHere("test "  .. vim.g.bazel_config) end)
map('n', '<Leader>bb',  function() vim.fn.RunBazelHere("build " .. vim.g.bazel_config) end)
map('n', '<Leader>br',  function() vim.fn.RunBazelHere("run "   .. vim.g.bazel_config) end)
map('n', '<Leader>bdb', function() vim.fn.RunBazelHere("build " .. vim.g.bazel_config .. " -c dbg --cxxopt=-O0 ") end)

-- debugger
local dap = require'telescope'.extensions.dap
map('n', '<leader>m',   ':MaximizerToggle!<CR>')
map('n', '<leader>dt',  require("dapui").toggle)
map('n', '<leader>bp',  require'dap'.toggle_breakpoint)
map('n', '<leader>l',   require'dap'.step_into)
map('n', '<leader>j',   require'dap'.step_over)
map('n', '<leader>k',   require'dap'.step_out)
map('n', '<leader>rc',  require'dap'.run_to_cursor)
map('n', '<leader>dpa', require'config.dap'.set_python_args_from_input)
map('n', '<leader>dr',  require'dap'.repl.open)
map('n', '<leader>dh',  require('dap.ui.widgets').hover)
map('n', '<leader>ds',  require('dap.ui.widgets').sidebar(require('dap.ui.widgets').scopes).toggle)
map('n', '<leader>df',  dap.frames)
map('n', '<leader>dd',  dap.commands)
map('n', '<leader>de',  require'config.dap'.end_debug_session)
map('n', '<leader>d<space>', require'dap'.continue)

-- todo-comments
map('n', '<leader>tq', ':TodoQuickfix<CR>')
map('n', '<leader>ft', ':TodoTelescope<CR>')

-- trouble
map('n', '<leader>xx', ':TroubleToggle<CR>')
map('n', '<leader>xw', ':TroubleToggle workspace_diagnostics<CR>')
map('n', '<leader>xd', ':TroubleToggle document_diagnostics<CR>')
map('n', '<leader>xq', ':TroubleToggle quickfix<CR>')
map('n', '<leader>xl', ':TroubleToggle loclist<CR>')

map('t', '<ESC>', '<C-\\><C-n>')
-- easy navigation between window splits and tmux panes
map('n', '<C-J>', '<C-W><C-J>')
map('n', '<C-K>', '<C-W><C-K>')
map('n', '<C-L>', '<C-W><C-L>')
map('n', '<C-H>', '<C-W><C-H>')

-- esc in terminal leaves insert mode

-- move selected lines up/down
map('v', 'J', [[:m '>+1<CR>gv=gv]])
map('v', 'K', [[:m '<-2<CR>gv=gv]])

-- copy full file path to clipboard
map('n', '<Leader>f', ':let @+=expand("%")<CR>')

-- copy visual selection to clipboard with ctrl-c
map('v', '<C-c>', '"+y')

-- Y will yank to end of line
map('n', 'Y', 'y$')

-- deletes visual selection and pastes without changing default register
map('v', 'p', '"_dP')

-- go to first file on line
map('n', 'gf', '^f/gf')

-- beginning/end of line
map({'n','v'}, 'H', '^')
map({'n','v'}, 'L', '$')
--
-- single line diffput/diffget shortcuts
map('n', '<leader>dp', 'V:diffput<CR>')
map('n', '<leader>do', 'V:diffget<CR>')
