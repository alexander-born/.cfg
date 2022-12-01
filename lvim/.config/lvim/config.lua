lvim.colorscheme = "everforest"

require "config.dashboard"
require "config.options"
require "config.plugins"
require "config.formatting"
require "config.mappings"
require "config.lsp"
require "config.treesitter"
require "config.dap"
require "config.telescope"
require "config.cmp"
require "config.nvimtree"
require "config.lualine"

pcall(require, "work")
