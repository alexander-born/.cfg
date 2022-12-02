local util = require('lspconfig/util')
local path = util.path

local function get_python_path(workspace)
  -- Use activated virtualenv.
  if vim.env.VIRTUAL_ENV then
    return path.join(vim.env.VIRTUAL_ENV, 'bin', 'python')
  end

  -- Find and use virtualenv from pipenv in workspace directory.
  local pipfile = path.join(workspace, 'Pipfile')
  if vim.fn.filereadable(pipfile) == 1 then
    local venv = vim.fn.trim(vim.fn.system('PIPENV_PIPFILE=' .. pipfile .. ' pipenv --venv'))
    if vim.v.shell_error == 0 then
        return path.join(venv, 'bin', 'python')
    else
        print("Virtual environment of Pipfile not yet created. To create: cd " .. workspace .. "; pipenv shell;")
    end
  end

  -- Fallback to system Python.
  return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
end

local function get_lua_settings()
  local runtime_path = vim.split(package.path, ';')
  table.insert(runtime_path, "lua/?.lua")
  table.insert(runtime_path, "lua/?/init.lua")

  return {
    Lua = {
      runtime = { version = 'LuaJIT', path = runtime_path },
      diagnostics = { globals = {'vim'} },
      workspace = { library = vim.api.nvim_get_runtime_file("", true) },
      telemetry = { enable = false },
    },
  }
end

local M = {}

function M.get_capabilities()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
    capabilities.offsetEncoding = { "utf-16" }
    return capabilities
end

function M.setup()
    local servers = { "clangd", "pyright", "sumneko_lua", "bashls", "vimls" }
    require("mason").setup { providers = { "mason.providers.client", } }
    require("mason-lspconfig").setup({ ensure_installed = servers, automatic_installation = true})

    local capabilities = M.get_capabilities()

    for _, server in pairs(servers) do
        local config = { capabilities = capabilities }
        if server == "sumneko_lua" then
          config.settings = get_lua_settings()
        end
        if server == "pyright" then
            config.on_init = function(client) client.config.settings.python.pythonPath = get_python_path(client.config.root_dir) end
            config.root_dir = require'config.bazel'.root_dir(require'lspconfig.server_configurations.pyright'.default_config.root_dir)
        end
        if server == "clangd" then
            config.cmd = { "clangd", "--background-index", "--header-insertion=never" }
            -- config.cmd = { "clangd", "--background-index", "--header-insertion=never", "--query-driver=**"  }
            config.root_dir = require'config.bazel'.root_dir(require'lspconfig.server_configurations.clangd'.default_config.root_dir)
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


