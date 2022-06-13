local lsp_formatting = function(bufnr)
	vim.lsp.buf.format({
		filter = function(client)
			return client.name ~= "clangd"
		end,
		bufnr = bufnr,
	})
end

local on_attach = function(client, bufnr)
	if client.server_capabilities.documentFormattingProvider then
		vim.api.nvim_create_autocmd("BufWritePre", {
			desc = "Auto format before save",
			pattern = "<buffer>",
			callback = function()
				lsp_formatting(bufnr)
			end,
		})
	end
end

return function(config)
	local null_ls = require("null-ls")
	config.sources = {
		null_ls.builtins.formatting.clang_format,
		null_ls.builtins.formatting.black,
		null_ls.builtins.formatting.json_tool,
		null_ls.builtins.formatting.buildifier,
		-- null_ls.builtins.formatting.stylua,
	}
	config.on_attach = on_attach
	return config
end
