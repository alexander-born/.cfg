local M = {}

local avail, dap = pcall(require, 'dap')

local function split_by_space(input)
    local chunks = {}
    for substring in input:gmatch("%S+") do
       table.insert(chunks, substring)
    end
    return chunks
end

function M.set_python_args(args)
    if not avail then return end
    dap.configurations.python[1].args = split_by_space(args)
end

function M.set_python_args_from_input()
    local args = vim.fn.input("python args for debugging: ")
    M.set_python_args(args)
end

function M.end_debug_session()
    if not avail then return end
    require'dap'.terminate()
    require'dapui'.close()
end

function M.setup()
    if not avail then return end
    vim.fn.sign_define('DapBreakpoint', {text='🛑', texthl='', linehl='', numhl=''})

    local dap, dapui = require("dap"), require("dapui")
    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
    dap.listeners.after.event_terminated["dapui_config"] = function() dapui.close() end
    dap.listeners.after.event_exited["dapui_config"] = function() dapui.close() end

    dap.adapters.cppdbg = {
      id = 'cppdbg',
      type = 'executable',
      command = 'OpenDebugAD7',
    }

    dap.adapters.python = {
      type = 'executable';
      command = 'python';
      args = { '-m', 'debugpy.adapter' };
    }

    dap.configurations.python = {
      {
        type = 'python',
        request = 'launch',
        name = "Launch file",
        program = "${file}",
        args = {},
        pythonPath = function() return '/usr/bin/python' end,
      },
    }

    dapui.setup({
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
