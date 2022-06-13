function save_telescope_extension(extension)
  local available, plugin = pcall(require, 'telescope')
  if available then
    plugin.load_extension(extension)
  end
end

function save_setup(package, config)
  local available, plugin = pcall(require, package)
  if available then
      if config then
          plugin.setup(config)
      else
          plugin.setup()
      end
  end
end

function save_init(package)
  local available, plugin = pcall(require, package)
  if available then plugin.init() end
end

local plugins = {
	-- Add plugins, the packer syntax without the "use"
	init = {
		-- You can disable default plugins as follows:
    ["nvim-lua/popup.nvim"] = { disable = true },
    ["Darazaki/indent-o-matic"] = { disable = true },
    ["rcarriga/nvim-notify"] = { disable = true },
    ["MunifTanjim/nui.nvim"] = {disable = true},
    ["antoinemadec/FixCursorHold.nvim"] = { disable = true},
    ["mrjones2014/smart-splits.nvim"] = { disable = true},
    ["famiu/bufdelete.nvim"] = {disable = true},
    ["nvim-neo-tree/neo-tree.nvim"] = { disable = true},
    ["feline-nvim/feline.nvim"] = { disable = true},
    -- ["p00f/nvim-ts-rainbow"] = {disable = true},
    ["windwp/nvim-ts-autotag"] = {disable = true},
    --["JoosepAlviste/nvim-ts-context-commentstring"] = {disable = true},
    ["stevearc/aerial.nvim"] = { disable = true},
    ["goolord/alpha-nvim"] = { disable = true},
    ["windwp/nvim-autopairs"] = { disable = true},
    ["akinsho/nvim-toggleterm.lua"] = { disable = true},
    ["lukas-reineke/indent-blankline.nvim"] = { disable = true},
    ["declancm/cinnamon.nvim"] = { disable = true},
    ["max397574/better-escape.nvim"] = { disable = true},
    ["b0o/SchemaStore.nvim"] = {disable = true},
    ["Shatur/neovim-session-manager"] = { disable = true},

		-- You can also add new plugins here as well:
		{ "inkarkat/vim-ReplaceWithRegister" },
		{ "machakann/vim-sandwich" },
		{ "tpope/vim-abolish" },
		{ "tpope/vim-dispatch" },
		{ "tpope/vim-unimpaired" },
		{ "wsdjeg/vim-fetch" },
		{ "mg979/vim-visual-multi" },
		{ "sainnhe/everforest" },
		{ "AckslD/nvim-neoclip.lua", config = function() save_setup("neoclip") end, },
		{ "onsails/lspkind-nvim", config = function() save_init("lspkind") end, },
		{ "nvim-lualine/lualine.nvim", config = function() require'user.config.lualine'.setup() end },
		{ "kyazdani42/nvim-tree.lua", config = function() require'user.config.nvimtree'.setup() end },
		-- git
		{ "tpope/vim-fugitive" },
		{ "tpope/vim-rhubarb" },
		{ "rhysd/conflict-marker.vim" },
		{ "christoomey/vim-tmux-navigator" },
		--bazel
		{ "bazelbuild/vim-bazel", requires = { "google/vim-maktaba" } },
		{ "alexander-born/bazel-vim", config = function() require("user.config.bazel").setup() end, },
		{ "alexander-born/cmp-bazel", after = "nvim-cmp" },
		-- debugger
		{ "szw/vim-maximizer" },
		{ "rcarriga/nvim-dap-ui" },
		{ "nvim-telescope/telescope-dap.nvim", config = function() save_telescope_extension("dap") end, },
		{ "mfussenegger/nvim-dap", config = function() require("user.config.dap").setup() end, },
	},
	-- All other entries override the setup() call for default plugins
	["null-ls"] = require("user.config.null-ls"),
	treesitter = { ensure_installed = { "lua", "cpp", "python" } },
	cmp = require("user.config.cmp"),
	bufferline = { options = { max_name_length = 50; tab_size = 0 }, },
	gitsigns = require("user.config.gitsigns"),
}

return plugins
