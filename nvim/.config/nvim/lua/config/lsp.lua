local on_attach = function(client, bufnr)
    require "lsp_signature".on_attach()  -- Note: add in lsp client on-attach
    client.resolved_capabilities.document_formatting = false
    client.resolved_capabilities.document_range_formatting = false
    -- if client.resolved_capabilities.document_formatting then
    --     vim.cmd([[
    --     augroup LspFormatting
    --         autocmd! * <buffer>
    --         autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
    --     augroup END
    --     ]])
    -- end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
capabilities.offsetEncoding = { "utf-16" }


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
function M.setup()
    local lsp_installer = require("nvim-lsp-installer")
    -- Register a handler that will be called for all installed servers.
    -- Alternatively, you may also register handlers on specific server instances instead (see example below).
    lsp_installer.on_server_ready(function(server)
        -- This setup() function is exactly the same as lspconfig's setup function.
        -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
        local config = {
            capabilities = capabilities,
            on_attach = on_attach,
        }
        if server.name == "sumneko_lua" then
          config.settings = lua_settings
        end
        if server.name == "pyright" then
            config.settings = { python = { analysis = { extraPaths = { vim.fn.getcwd() } } } }
        end
        if server.name == "clangd" then
            local install_path = {require'nvim-lsp-installer.servers'.get_server('clangd')}
            if install_path[1] then
                install_path = install_path[2].root_dir
                config.cmd = {install_path .. "/clangd/bin/clangd", "--background-index", "--cross-file-rename"};
             end
        end
        server:setup(config)
    end)

end

return M


