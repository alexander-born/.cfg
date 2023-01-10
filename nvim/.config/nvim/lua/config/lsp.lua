local path = require 'lspconfig/util'.path

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
            print('Virtual environment of Pipfile not yet created. To create: cd ' .. workspace .. '; pipenv shell;')
        end
    end

    -- Fallback to system Python.
    return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
end

local M = {}

function M.get_capabilities()
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    capabilities.offsetEncoding = { 'utf-16' }
    return capabilities
end

function M.setup()
    require("neodev").setup()
    require("mason").setup({ providers = { 'mason.providers.client', } })

    local lspconfig = require 'lspconfig'
    local mason_lspconfig = require 'mason-lspconfig'
    local bazel_root_dir = require 'config.bazel'.root_dir
    local servers_to_install = { 'clangd', 'pyright', 'sumneko_lua', 'bashls' }
    mason_lspconfig.setup { ensure_installed = servers_to_install, automatic_installation = true }

    local capabilities = M.get_capabilities()

    for _, server in ipairs(mason_lspconfig.get_installed_servers()) do
        local config = { capabilities = capabilities }
        if server == 'pyright' then
            config.on_init = function(client) client.config.settings.python.pythonPath = get_python_path(client.config.root_dir) end
            config.root_dir = bazel_root_dir(require 'lspconfig.server_configurations.pyright'.default_config.root_dir)
        end
        if server == 'clangd' then
            config.cmd = { 'clangd', '--background-index', '--header-insertion=never', '--offset-encoding=utf-16' }
            config.root_dir = bazel_root_dir(require 'lspconfig.server_configurations.clangd'.default_config.root_dir)
        end
        lspconfig[server].setup(config)
    end

    local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }
    for type, icon in pairs(signs) do
        local hl = 'DiagnosticSign' .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl })
    end

end

return M
