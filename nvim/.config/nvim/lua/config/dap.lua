local M = {}

function M.setup()
    require('dap')
    vim.fn.sign_define('DapBreakpoint', {text='🛑', texthl='', linehl='', numhl=''})

    local dap_install = require("dap-install")
    local dbg_list = require("dap-install.api.debuggers").get_installed_debuggers()

    for _, debugger in ipairs(dbg_list) do
        dap_install.config(debugger, {})
    end

    local dap = require('dap')
    dap.adapters.python = {
      type = 'executable';
      command = 'python';
      args = { '-m', 'debugpy.adapter' };
    }

    dap.configurations.python = {
      {
        type = 'python';
        request = 'launch';
        name = "Launch file";
        program = "${file}";
        pythonPath = function() return '/usr/bin/python' end;
      },
    }

    -- dap.adapters.lldb = {
    --   type = 'executable',
    --   command = '/usr/bin/lldb-vscode-12',
    --   name = "lldb"
    -- }
    --
    -- dap.configurations.cpp = {
    --   {
    --     name = "Launch",
    --     type = "lldb",
    --     request = "launch",
    --     program = function()
    --       return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    --     end,
    --     cwd = '${workspaceFolder}',
    --     stopOnEntry = true,
    --     args = {},
    --     runInTerminal = false,
    --   },
    -- }
    
    require("dapui").setup({
      sidebar = {
        elements = {
          -- Provide as ID strings or tables with "id" and "size" keys
          { id = "scopes", size = 0.25 },
          { id = "breakpoints", size = 0.25 },
          { id = "watches", size = 00.25 },
        },
      },
      tray = {
        elements = { "repl" },
      },
    })
end

return M
