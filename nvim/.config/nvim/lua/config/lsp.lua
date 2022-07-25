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

local function get_bazel_extra_paths()
    local Path = require'plenary.path'
    local extra_paths = {}
    local add_extra_paths = function(_, stdout)
        for _, line in ipairs(stdout) do
            if Path:new(line):exists() and line ~= "" then
                table.insert(extra_paths, line)
            end
        end
    end
    local find_python_modules = [[find . | grep __init__.py | grep -v .runfiles | xargs -r dirname | xargs -r dirname | grep -v "\.$" | awk '$0 ~ "^"r"\\/"{ next }{ r=$0 }1' | sort | uniq | xargs -r readlink -f;]]
    local jobid = vim.fn.jobstart("cd external && " .. find_python_modules .. " cd " .. vim.fn.getcwd() .. " && cd bazel-bin && " .. find_python_modules, { on_stdout = add_extra_paths })
    vim.fn.jobwait({jobid})
    table.insert(extra_paths, vim.fn.getcwd())
    return extra_paths
end

local M = {}
function M.setup()
    local servers = { "clangd", "pyright", "sumneko_lua", "bashls", "vimls" }
    require("mason").setup()
    require("mason-lspconfig").setup({ ensure_installed = servers, automatic_installation = true})

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
            config.settings = { python = { analysis = { extraPaths = get_bazel_extra_paths() } } }
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


