lvim.builtin.dap.active = true
require('dap-python').test_runner = 'pytest'
require('dap.ext.vscode').load_launchjs()
local dap, dapui = require("dap"), require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
dap.listeners.after.event_terminated["dapui_config"] = function() dapui.close() end
dap.listeners.after.event_exited["dapui_config"] = function() dapui.close() end
dap.adapters.cppdbg = {
  id = 'cppdbg',
  type = 'executable',
  command = 'OpenDebugAD7',
}
