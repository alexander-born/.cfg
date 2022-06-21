local M = {}
function M.setup()
  vim.g.vimwiki_list = { {
      ext = ".md",
      path = "~/projects/vimwiki/",
      syntax = "markdown"
    } }
end
return M
