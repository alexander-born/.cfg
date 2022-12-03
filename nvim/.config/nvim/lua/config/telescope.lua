local telescope = require'telescope'

local function on_project_selected(prompt_bufnr)
    local project_actions = require'telescope._extensions.project.actions'
    local user_actions_available, user_project_actions = pcall(require, 'user.project.actions')
    project_actions.change_working_directory(prompt_bufnr, false)
    vim.g.project_path = vim.fn.getcwd()
    if user_actions_available then user_project_actions(prompt_bufnr) end
end

local M = {}

function M.project()
    telescope.extensions.project.project{
        display_type = 'full',
        attach_mappings = function(prompt_bufnr, map)
            map({'n', 'i'}, '<CR>', on_project_selected)
            return true
        end,
    }
end

function M.setup()
    local actions = require'telescope.actions'
    telescope.setup({
        defaults = {
            mappings = {
                i = {
                    ["<C-j>"] = actions.cycle_history_next,
                    ["<C-k>"] = actions.cycle_history_prev,
                },
            },
        },
        extensions = {
            fzf = {
              fuzzy = true,                    -- false will only do exact matching
              override_generic_sorter = true,  -- override the generic sorter
              override_file_sorter = true,     -- override the file sorter
              case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
            },
            project = {
                base_dirs = {{path = '~', max_depth = 4},},
            }
        }
    })
    telescope.load_extension('fzf')
    telescope.load_extension('dap')
    telescope.load_extension('project')
end

return M
