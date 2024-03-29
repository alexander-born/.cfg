local function get_filename()
	local data = vim.fn.expand("%:~:.")
	if vim.bo.modified then
		data = data .. " [+]"
	elseif vim.bo.modifiable == false or vim.bo.readonly == true then
		data = data .. " [-]"
	end
	return data
end

local function lsp_not_active()
	return vim.tbl_isempty(vim.lsp.buf_get_clients(0))
end

local function diagnostics_ok()
	if lsp_not_active() then
		return ""
	end
	local w = vim.diagnostic.get(0, { severity = "Warn" })
	local e = vim.diagnostic.get(0, { severity = "Error" })
	if next(w) or next(e) then
		return ""
	end
	return " "
end

local function get_git_branch()
	local head = vim.fn.FugitiveHead(6)
	if head == "" then
		return nil
	end
	return " " .. head
end

local function null_ls_providers(filetype)
	local registered = {}
	local sources_avail, sources = pcall(require, "null-ls.sources")
	if sources_avail then
		for _, source in ipairs(sources.get_available(filetype)) do
			for method in pairs(source.methods) do
				registered[method] = registered[method] or {}
				table.insert(registered[method], source.name)
			end
		end
	end
	return registered
end

local function null_ls_sources(filetype, source)
	local methods_avail, methods = pcall(require, "null-ls.methods")
	return methods_avail and null_ls_providers(filetype)[methods.internal[source]] or {}
end

local function lsp_client_names()
	local buf_client_names = {}
	for _, client in pairs(vim.lsp.buf_get_clients(0)) do
		if client.name == "null-ls" then
			vim.list_extend(buf_client_names, null_ls_sources(vim.bo.filetype, "FORMATTING"))
			vim.list_extend(buf_client_names, null_ls_sources(vim.bo.filetype, "DIAGNOSTICS"))
		else
			table.insert(buf_client_names, client.name)
		end
	end
	return table.concat(buf_client_names, ", ")
end

local M = {}
function M.setup()
	require("lualine").setup({
		options = { theme = vim.g.color_scheme, globalstatus = true },
		sections = {
			lualine_a = { "mode" },
			lualine_b = { { get_git_branch } },
			lualine_c = {
				{ get_filename },
				{
					"diff",
					symbols = { added = " ", modified = " ", removed = " " },
				},
			},
			lualine_x = {
				{
					"diagnostics",
					sources = { "nvim_diagnostic" },
					symbols = { error = " ", warn = " ", info = " " },
				},
				{ diagnostics_ok },
				{ lsp_client_names },
				"filetype",
			},
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
	})
end
return M
