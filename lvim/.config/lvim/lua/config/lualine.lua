local components = require "lvim.core.lualine.components"
local function get_filename()
  local data = vim.fn.expand("%:~:.")
  if vim.bo.modified then
    data = data .. " [+]"
  elseif vim.bo.modifiable == false or vim.bo.readonly == true then
    data = data .. " [-]"
  end
  return data
end

lvim.builtin.lualine.sections.lualine_c = {
  get_filename,
  components.diff,
  components.python_env,
}
