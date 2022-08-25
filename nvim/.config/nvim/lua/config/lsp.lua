local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

local lua_settings = {
  Lua = {
    runtime = {
      -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
      version = 'LuaJIT',
      -- Setup your lua path
      path = runtime_path,
    },
    diagnostics = {
      -- Get the language server to recognize the `vim` global
      globals = {'vim'},
    },
    workspace = {
      -- Make the server aware of Neovim runtime files
      library = vim.api.nvim_get_runtime_file("", true),
    },
    -- Do not send telemetry data containing a randomized but unique identifier
    telemetry = {
      enable = false,
    },
  },
}

local M = {}

function M.get_capabilities()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
    capabilities.offsetEncoding = { "utf-16" }
    return capabilities
end

function M.setup()
    local servers = { "clangd", "pyright", "sumneko_lua", "bashls", "vimls" }
    require("mason").setup()
    require("mason-lspconfig").setup({ ensure_installed = servers, automatic_installation = true})

    local capabilities = M.get_capabilities()

    for _, server in pairs(servers) do
        local config = { capabilities = capabilities }
        if server == "sumneko_lua" then
          config.settings = lua_settings
        end
        if server == "clangd" then
            config.cmd = {require'mason-core.path'.bin_prefix('clangd'), "--background-index", "--cross-file-rename"};
        end
        require('lspconfig')[server].setup(config)
    end

    local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl })
    end

end

return M


