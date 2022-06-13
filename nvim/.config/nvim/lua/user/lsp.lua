local overwrite_clangd_settings = function(clangd_settings)
	local install_path = { require("nvim-lsp-installer.servers").get_server("clangd") }
	if install_path[1] then
		install_path = install_path[2].root_dir
		clangd_settings = {
			cmd = { install_path .. "/clangd/bin/clangd", "--background-index", "--cross-file-rename" },
			capabilities = { offsetEncoding = { "utf-16" } },
		}
	end
	return clangd_settings
end

local lsp = {
	on_attach = function(client, bufnr)
		vim.keymap.del("n", "gr", { buffer = bufnr })
	end,
	["server-settings"] = { clangd = overwrite_clangd_settings },
}

return lsp
