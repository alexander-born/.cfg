local util = require('lspconfig/util')
local path = util.path

local function get_python_path(workspace)
  -- Use activated virtualenv.
  if vim.env.VIRTUAL_ENV then
    return path.join(vim.env.VIRTUAL_ENV, 'bin', 'python')
  end

  -- Find and use virtualenv from pipenv in workspace directory.
  local pipfile = path.join(workspace, 'Pipfile')
  if vim.fn.filereadable(pipfile) then
    local venv = vim.fn.trim(vim.fn.system('PIPENV_PIPFILE=' .. pipfile .. ' pipenv --venv'))
    return path.join(venv, 'bin', 'python')
  end

  -- Fallback to system Python.
  return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
end

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
        if server == "pyright" then
            config.on_init = function(client) client.config.settings.python.pythonPath = get_python_path(client.config.root_dir) end
        end
        if server == "clangd" then
            config.cmd = { "clangd", "--background-index", "--header-insertion=never" }
            config.root_dir = require'config.bazel'.root_dir_clangd()
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


