local M = {}

function M.setup()
  require'bufferline'.setup{
    options = {
      numbers = function(opts) return '' end,
      max_name_length = 50;
      tab_size = 0 } 
    }
end

return M
