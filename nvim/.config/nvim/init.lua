require'utils'
require'plugins'
require'options'
require'color'

local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', { callback = function() vim.highlight.on_yank() end, group = highlight_group, pattern = '*', })

pcall(require, 'user')
