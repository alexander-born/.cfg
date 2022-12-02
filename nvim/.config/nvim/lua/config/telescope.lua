local M = {}

function M.setup()
    local project_actions = require'telescope._extensions.project.actions'
    local telescope = require'telescope'
    local actions = require'telescope.actions'
    local work_actions_available, work_project_actions = pcall(require, 'work.project.actions')
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
                on_project_selected = function(prompt_bufnr)
                  project_actions.change_working_directory(prompt_bufnr, false)
                  if work_actions_available then work_project_actions(prompt_bufnr) end
                end
            }
        }
    })
    telescope.load_extension('fzf')
    telescope.load_extension('dap')
    telescope.load_extension('project')
end

return M
