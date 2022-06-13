local config = {

	-- Configure AstroNvim updates
	updater = {
		remote = "origin", -- remote to use
		channel = "nightly", -- "stable" or "nightly"
		version = "latest", -- "latest", tag name, or regex search like "v1.*" to only do updates before v2 (STABLE ONLY)
		-- branch = "neovim-0.8", -- branch name (NIGHTLY ONLY)
	},

	header = {},
	colorscheme = "everforest",
	ui = { nui_input = false, },

	plugins = require("user.plugins"),
	lsp = require("user.lsp"),
	polish = function()
		require("user.mappings")
		require("user.utils")
	end,
}

return config
