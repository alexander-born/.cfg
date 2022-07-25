local M = {}

function M.setup()
    require'telescope'.setup({
        defaults = {
            mappings = {
                i = {
                    ["<C-j>"] = require('telescope.actions').cycle_history_next,
                    ["<C-k>"] = require('telescope.actions').cycle_history_prev,
                },
            },
        },
        extensions = {
            fzf = {
              fuzzy = true,                    -- false will only do exact matching
              override_generic_sorter = true,  -- override the generic sorter
              override_file_sorter = true,     -- override the file sorter
              case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
            }
        }
    })
    require'telescope'.load_extension('fzf')
    require'telescope'.load_extension('dap')
end

return M
