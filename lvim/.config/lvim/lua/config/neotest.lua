local M = {}
function M.setup()
    local neotest = require("neotest")
    neotest.setup({
        adapters = { require("neotest-python") },
        discovery = { enabled = false },
    })
end
return M
