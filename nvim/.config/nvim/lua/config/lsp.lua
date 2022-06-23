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


local function add_bazel_extra_paths(config)
    local cwd = vim.fn.getcwd()
    local buf = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_win_set_buf(0, buf)
    local add_extra_paths = function(_, return_code)
        if return_code == 0 then
            for _, path in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
                table.insert(config.settings.python.analysis.extraPaths, path)
            end
            table.insert(config.settings.python.analysis.extraPaths, vim.fn.getcwd())
            require('lspconfig').pyright.setup(config)
        end
        vim.api.nvim_buf_delete(buf, {})
    end
    local find_python_modules = [[find . | grep __init__.py | grep -v .runfiles | xargs -r dirname | xargs -r dirname | grep -v "\.$" | awk '$0 ~ "^"r"\\/"{ next }{ r=$0 }1' | sort | uniq | xargs -r readlink -f;]]
    vim.fn.termopen("cd external && " .. find_python_modules .. " cd " .. cwd .. " && cd bazel-bin && " .. find_python_modules, { on_exit = add_extra_paths })
end

local M = {}
function M.setup()
    local servers = { "clangd", "pyright", "sumneko_lua", "bashls", "vimls" }
    require("nvim-lsp-installer").setup({ automatic_installation = true})

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
    capabilities.offsetEncoding = { "utf-16" }

    for _, server in pairs(servers) do
        local config = {
            capabilities = capabilities,
        }
        if server == "sumneko_lua" then
          config.settings = lua_settings
        end
        if server == "pyright" then
            local cwd = vim.fn.getcwd()
            config.settings = { python = { analysis = { extraPaths = {cwd} } } }
            add_bazel_extra_paths(config)
        end
        if server == "clangd" then
            local install_path = {require'nvim-lsp-installer.servers'.get_server('clangd')}
            if install_path[1] then
                install_path = install_path[2].root_dir
                config.cmd = {install_path .. "/clangd/bin/clangd", "--background-index", "--cross-file-rename"};
             end
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


