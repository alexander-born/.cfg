local M = {}

function M.setup()
    require "nvim-treesitter.configs".setup {
      ensure_installed = "maintained",
      highlight = { enable = true },
      textobjects = {
        select = {
          enable = true,
          keymaps = {
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
        swap = {
          enable = true,
          swap_next     = { ["<leader>sa"] = "@parameter.inner", },
          swap_previous = { ["<leader>sA"] = "@parameter.inner", },
        },
      },
      playground = { enable = true }
    }
end

return M
