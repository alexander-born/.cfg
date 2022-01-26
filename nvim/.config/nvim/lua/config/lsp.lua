local on_attach = function(client, bufnr)
    require "lsp_signature".on_attach()  -- Note: add in lsp client on-attach
    if client.resolved_capabilities.document_formatting then
        vim.cmd([[
        augroup LspFormatting
            autocmd! * <buffer>
            autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
        augroup END
        ]])
    end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
capabilities.offsetEncoding = { "utf-16" }

-- Configure lua language server for neovim development
local lua_settings = {
  Lua = {
    runtime = {
      -- LuaJIT in the case of Neovim
      version = 'LuaJIT',
      path = vim.split(package.path, ';'),
    },
    diagnostics = {
      -- Get the language server to recognize the `vim` global
      globals = {'vim'},
    },
    workspace = {
      -- Make the server aware of Neovim runtime files
      library = {
        [vim.fn.expand('$VIMRUNTIME/lua')] = true,
        [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
        [vim.fn.expand('$HOME/.config/nvim/lua')] = true,
      },
    },
  }
}

local M = {}
function M.setup()
    local lsp_installer = require("nvim-lsp-installer")
    -- Register a handler that will be called for all installed servers.
    -- Alternatively, you may also register handlers on specific server instances instead (see example below).
    lsp_installer.on_server_ready(function(server)
        local opts = {}

        -- (optional) Customize the options passed to the server
        -- if server.name == "tsserver" then
        --     opts.root_dir = function() ... end
        -- end

        -- This setup() function is exactly the same as lspconfig's setup function.
        -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
        local config = {
            capabilities = capabilities,
            on_attach = on_attach,
        }
        if server == "lua" then
          config.settings = lua_settings
        end
        if server == "vim" then
            local plugin_path = vim.fn.stdpath('data')..'/site/pack/packer'
            config.init_options = { runtimepath = vim.fn.expand("~/.config/nvim/" .. ',' .. plugin_path) }
        end
        if server.name == "pyright" then
            config.settings = { python = { analysis = { extraPaths = { vim.fn.getcwd() } } } }
        end
        if server.name == "clangd" then
            install_path = {require'nvim-lsp-installer.servers'.get_server('clangd')}
            if install_path[1] then 
                install_path = install_path[2].root_dir
                -- config.cmd = {require"lspinstall.util".install_path("cpp") .. "/clangd/bin/clangd", "--background-index", "--cross-file-rename"};
                config.cmd = {install_path .. "/clangd/bin/clangd", "--background-index", "--cross-file-rename", "--compile-commands-dir=" .. vim.fn.getcwd()};
             end
        end
        server:setup(config)
    end)

end

return M


