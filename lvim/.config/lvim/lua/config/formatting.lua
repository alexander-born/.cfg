lvim.format_on_save = {
  enabled = true,
  timeout = 1000,
}

local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { command = "stylua" },
  { command = "black" },
  { command = "clang_format" },
  { command = "buildifier" },
}
