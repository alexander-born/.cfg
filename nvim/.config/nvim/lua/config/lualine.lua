local function get_filename()
    local data = vim.fn.expand('%:~:.')
    if vim.bo.modified then
        data = data .. ' [+]'
    elseif vim.bo.modifiable == false or vim.bo.readonly == true then
        data = data .. ' [-]'
    end
    return data
end

local function lsp_not_active() return vim.tbl_isempty(vim.lsp.buf_get_clients(0)) end

local function diagnostics_ok()
    if lsp_not_active() then return '' end
    local w = vim.diagnostic.get(0, { severity = 'Warn' })
    local e = vim.diagnostic.get(0, { severity = 'Error' })
    if next(w) or next(e) then return '' end
    return ' '
 end

local function get_colors()
    if vim.g.color_scheme == 'everforest' then return {red = '#e67e80', green = '#a7c080', yellow = '#dbbc7f', orange = '#e69875'} end
    if vim.g.color_scheme == 'nord' then return {red = '#BF616A', green = '#A3BE8C', yellow = '#EBCB8B', orange = '#D08770'} end
    return {red = '#fb4934', green = '#b8bb26', yellow = '#fabd2f', orange = '#fe8019'}
end

local function get_git_branch()
    local head = vim.fn.FugitiveHead(6)
    if head == '' then return nil end
    return ' ' .. head
end

local function lsp_server()
    local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
    local clients = vim.lsp.get_active_clients()
    for _, client in ipairs(clients) do
      local filetypes = client.config.filetypes
      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 and client.name ~= 'null-ls' then
        return client.name
      end
    end
    return ''
end


local M = {}
function M.setup()
  local colors = get_colors()
  local theme = vim.g.color_scheme
  if vim.g.color_scheme == "everforest" then
      theme = require'lualine.themes.everforest'
      local normal = theme.normal.a
      theme.normal.a = theme.insert.a
      theme.insert.a = normal
  end
  require'lualine'.setup {
    options = { theme = theme, globalstatus = true },
    sections = {
      lualine_a = {'mode'},
      lualine_b = {{get_git_branch}},
      lualine_c = {{get_filename}, { 'diff', diff_color = { added = { fg = colors.green }, modified = { fg = colors.orange }, removed = { fg = colors.red }}, symbols = {added = ' ', modified = ' ', removed = ' '} }},
      lualine_x = {{'diagnostics', sources = {'nvim_diagnostic'}, symbols = {error = ' ', warn = ' ', info = ' '}, diagnostics_color = {hint = {fg = colors.green}}}, {diagnostics_ok}, {lsp_server}, 'filetype' },
      lualine_y = {'progress'},
      lualine_z = {'location'}
    },
  }
end

return M
