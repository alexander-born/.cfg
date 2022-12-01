lvim.plugins = {
  --general
  { 'sainnhe/everforest', config = function() require 'config.everforest'.setup() end },
  { "folke/trouble.nvim", cmd = "TroubleToggle", },
  { 'mg979/vim-visual-multi' },
  { 'inkarkat/vim-ReplaceWithRegister' },
  { 'vimwiki/vimwiki', config = function() require 'config.vimwiki'.setup() end },
  { 'christoomey/vim-tmux-navigator' },
  { 'szw/vim-maximizer' },

  --git
  {
    "tpope/vim-fugitive",
    cmd = {
      "G",
      "Git",
      "Gdiffsplit",
      "Gread",
      "Gwrite",
      "Ggrep",
      "GMove",
      "GDelete",
      "GBrowse",
      "GRemove",
      "GRename",
      "Glgrep",
      "Gedit"
    },
    ft = { "fugitive" }
  },
  { 'rhysd/conflict-marker.vim', config = function() require 'config.conflict_marker'.setup() end },

  --telescope
  { 'AckslD/nvim-neoclip.lua', config = function() require('neoclip').setup() end },
  { 'nvim-telescope/telescope-dap.nvim' },
  { 'nvim-telescope/telescope-project.nvim' },

  --debug
  { 'mfussenegger/nvim-dap-python', config = function() require 'dap-python'.setup() end },

  --test
  { "nvim-neotest/neotest", requires = { "antoinemadec/FixCursorHold.nvim", "nvim-neotest/neotest-python" },
    config = function() require 'config.neotest'.setup() end },

  --treesitter
  { 'nvim-treesitter/nvim-treesitter-textobjects' },

  --lsp
  { 'onsails/lspkind-nvim', config = function() require 'lspkind'.init() end },
  { 'j-hui/fidget.nvim', config = function() require 'fidget'.setup() end },

  -- bazel
  { 'google/vim-maktaba' },
  { 'bazelbuild/vim-bazel' },
  { 'alexander-born/bazel-vim', config = function() require 'config.bazel'.setup() end },
  { 'alexander-born/cmp-bazel' },
}
