lvim.builtin.treesitter.textobjects.swap = {
  enable        = true,
  swap_next     = { ["<leader>sa"] = "@parameter.inner", },
  swap_previous = { ["<leader>sA"] = "@parameter.inner", },
}

lvim.builtin.treesitter.textobjects.select = {
  enable = true,
  lookahead = true,
  keymaps = {
    ["aa"] = "@parameter.outer",
    ["ia"] = "@parameter.inner",
    ["af"] = "@function.outer",
    ["if"] = "@function.inner",
    ["ac"] = "@class.outer",
    ["ic"] = "@class.inner",
  },
}

lvim.builtin.treesitter.incremental_selection = {
  enable = true,
  keymaps = {
    init_selection = "vn",
    node_incremental = "<C-n>",
    scope_incremental = "<C-s>",
    node_decremental = "<C-p>",
  },
}

lvim.builtin.treesitter.ensure_installed = { "c", "cpp", "python", "lua" }

lvim.builtin.treesitter.disable = function(_, buf)
  local max_filesize = 100 * 1024 -- 100 KB
  local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
  if ok and stats and stats.size > max_filesize then
    return true
  end
end
