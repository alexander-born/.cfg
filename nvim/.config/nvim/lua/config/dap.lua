local M = {}

local function split_by_space(input)
    local chunks = {}
    for substring in input:gmatch("%S+") do
       table.insert(chunks, substring)
    end
    return chunks
end

function M.set_python_args(args)
    require'dap'.configurations.python[1].args = split_by_space(args)
end

function M.set_python_args_from_input()
    local args = vim.fn.input("python args for debugging: ")
    M.set_python_args(args)
end

function M.end_debug_session()
    require'dap'.terminate()
    require'dapui'.close()
end

function M.setup()
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
      layouts = {
        {
          elements = {
            'scopes',
            'breakpoints',
            'watches',
          },
          size = 40,
          position = 'left',
        },
        {
          elements = {
            'repl',
          },
          size = 10,
          position = 'bottom',
        },
      },
    })
end

return M
