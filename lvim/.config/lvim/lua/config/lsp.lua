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

vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "clangd", "pyright" })
local lsp_manager = require("lvim.lsp.manager")

lsp_manager.setup("clangd",
  { root_dir = require 'config.bazel'.root_dir(require 'lspconfig.server_configurations.clangd'.default_config.root_dir),
    capabilities = { offsetEncoding = { "utf-16" } } })

lsp_manager.setup("pyright",
  { root_dir = require 'config.bazel'.root_dir(require 'lspconfig.server_configurations.pyright'.default_config.root_dir),
    on_init = function(client) client.config.settings.python.pythonPath = get_python_path(client.config.root_dir) end
  })
