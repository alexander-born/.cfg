if astronvim.is_available "telescope.nvim" then
local map = vim.keymap.set
-- lsp
map('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename' })
map('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Goto previous diagnostic' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Goto next diagnostic' })
map('n', 'gd', vim.lsp.buf.definition, { desc = 'Goto defintion' })
map('n', 'gi', vim.lsp.buf.implementation, { desc = 'Goto implementation' })
map('n', '<leader>r', vim.lsp.buf.references, { desc = 'Find references' })
map('n', '<leader>q', vim.diagnostic.setqflist, { desc = 'Diagnostics to QF' })

-- filetree
map('n', '<C-n>', require'user.config.nvimtree'.nvim_tree_toggle_project, { desc = 'NvimTree' })
map('n', '<Leader>n', require'user.config.nvimtree'.nvim_tree_find_file, { desc = 'NvimTree find file' })

-- parse errors from terminal and put them in quickfix list
map('n', '<Leader>e',  vim.fn.OpenErrorInQuickfix)

-- switch between cpp and header file
map('n', '<F7>', vim.fn.SwitchSourceHeader)

-- telescope
local builtin = require'telescope.builtin'
map('n', '<leader>ff',  function() builtin.find_files({previewer = false}) end, { desc = 'Files' })
map('n', '<leader>fo',  function() builtin.oldfiles({previewer = false}) end, { desc = 'Oldfiles' })
map('n', '<leader>fw',  function() builtin.oldfiles({previewer = false, cwd_only = true}) end, { desc = 'Cwd' })
map('n', '<leader>fb',  function() builtin.buffers({sort_mru = true}) end, { desc = 'Buffers' })
map('n', '<leader>fq',  builtin.quickfix, { desc = 'Qickfix' })
map('n', '<leader>fh',  builtin.command_history, { desc = 'Commands' })
map('n', '<leader>fr',  builtin.registers, { desc = 'Registers' })
map('n', '<leader>fl',  builtin.resume, { desc = 'Last Search' })
map('n', '<leader>ht',  builtin.help_tags, { desc = 'Help tags' })
map('n', '<leader>gr',  builtin.live_grep, { desc = 'Grep' })
map('n', '<leader>grb', builtin.current_buffer_fuzzy_find, { desc = 'Fuzzy buffer' })
map('n', '<leader>fy',  require'telescope'.extensions.neoclip.default, { desc = 'Yanks' })
map('n', '<leader>f.',  function() builtin.find_files({prompt_title = ".cfg", cwd = "$HOME", search_dirs = {"$HOME/.cfg", "$HOME/.cfg_work"}, hidden = true, file_ignore_patterns = {".git"}}) end, { desc = '.cfg' })
map('n', '<leader>fn',  function() builtin.find_files({prompt_title = ".config/nvim", search_dirs = {"$HOME/.config/nvim", "$HOME/.local/share/nvim/site/pack/packer"}}) end, { desc = 'nvim' })
map('n', '<leader>fa',  function() builtin.find_files({prompt_title = "application/adp", search_dirs = {"application/adp"}, hidden = true, file_ignore_patterns = {".git"}, previewer = false}) end, { desc = 'adp' })
map('n', '<leader>gr.', function() builtin.live_grep({cwd = "$HOME", search_dirs = {"$HOME/.cfg", "$HOME/.cfg_work"}, vimgrep_arguments = { 'rg', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case', '--hidden' }, file_ignore_patterns = {".git"}}) end, { desc = '.cfg' })
map('n', '<leader>grw', function() builtin.live_grep({cwd = "$HOME/projects/vimwiki"}) end, { desc = 'vimwiki' })
map('n', '<leader>grn', function() builtin.live_grep({search_dirs = {"$HOME/.config/nvim", "$HOME/.local/share/nvim/site/pack/packer"}}) end, { desc = 'nvim' })

-- git
map('n', '<leader>gb', function() builtin.git_branches({cwd = vim.fn.expand("%:p:h")}) end, { desc = 'Git branches' })
map('n', '<leader>gc', function() builtin.git_bcommits({cwd = vim.fn.expand("%:p:h")}) end, { desc = 'Git commits' })
map('n', '<Leader>gl', ':G log -n 1000<CR>', { desc = 'Git log' })
map('n', '<Leader>gd', ':GitDiff<CR>', { desc = 'Git diff' })
map('n', '<Leader>gs', ':G | MaximizerToggle<CR>', { desc = 'Git status' })
map('v', '<Leader>gb', ':GBrowse<CR>', { desc = 'Git browse' })

-- bazel
vim.api.nvim_create_autocmd("FileType", { pattern = "bzl", callback = function() map('n', 'gd', vim.fn.GoToBazelDefinition, { buffer = 0 }) end })
map('n', 'gbt',         vim.fn.GoToBazelTarget, { desc = 'Goto bazel build' })
map('n', '<Leader>bl',  vim.fn.RunBazel, { desc = 'Bazel last' })
map('n', '<Leader>bdt', require'user.config.bazel'.DebugThisTest, { desc = 'Bazel debug test' })
map('n', '<Leader>y',   require'user.config.bazel'.YankLabel, {}, { desc = 'Yank bazel label' })
map('n', '<Leader>bt',  function() vim.fn.RunBazelHere("test "  .. vim.g.bazel_config) end, { desc = 'Bazel test' })
map('n', '<Leader>bb',  function() vim.fn.RunBazelHere("build " .. vim.g.bazel_config) end, { desc = 'Bazel build' })
map('n', '<Leader>br',  function() vim.fn.RunBazelHere("run "   .. vim.g.bazel_config) end, { desc = 'Bazel run' })
map('n', '<Leader>bdb', function() vim.fn.RunBazelHere("build " .. vim.g.bazel_config .. " -c dbg --cxxopt=-O0 ") end, { desc = 'Bazel debug build' })

-- debugger
local dap = require'telescope'.extensions.dap
map('n', '<leader>m',   ':MaximizerToggle!<CR>', { desc = 'Maximizer toggle' })
map('n', '<leader>dt',  require("dapui").toggle, { desc = 'Toggle UI' })
map('n', '<leader>bp',  require'dap'.toggle_breakpoint, { desc = 'Breakpoint' })
map('n', '<leader>l',   require'dap'.step_into, { desc = 'Step into' })
map('n', '<leader>j',   require'dap'.step_over, { desc = 'Step over' })
map('n', '<leader>k',   require'dap'.step_out, { desc = 'Step out' })
map('n', '<leader>rc',  require'dap'.run_to_cursor, { desc = 'Run to cursor' })
map('n', '<leader>dpa', require'user.config.dap'.set_python_args_from_input, { desc = 'Set python arguments' })
map('n', '<leader>dr',  require'dap'.repl.open, { desc = 'Repl open' })
map('n', '<leader>dh',  require('dap.ui.widgets').hover, { desc = 'Hover' })
map('n', '<leader>ds',  require('dap.ui.widgets').sidebar(require('dap.ui.widgets').scopes).toggle, { desc = 'Sidebar toggle' })
map('n', '<leader>df',  dap.frames, { desc = 'Frames' })
map('n', '<leader>dd',  dap.commands, { desc = 'Commands' })
map('n', '<leader>de',  require'user.config.dap'.end_debug_session, { desc = 'End debug session' })
map('n', '<leader>d<space>', require'dap'.continue, { desc = 'Continue' })

-- multicursor
vim.cmd[[
let g:VM_maps = {}
let g:VM_maps['Find Under']         = '<M-n>'
let g:VM_maps['Find Subword Under'] = '<M-n>'
let g:VM_maps['Add Cursor Down']    = '<M-j>'
let g:VM_maps['Add Cursor Up']      = '<M-k>'
]]

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
end
