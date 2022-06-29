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
            fzy_native = {
                override_generic_sorter = false,
                override_file_sorter = true,
            }
        }
    })
    require'telescope'.load_extension('fzf')
    require'telescope'.load_extension('dap')
end

return M
