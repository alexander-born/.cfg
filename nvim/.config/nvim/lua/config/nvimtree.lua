local M = {}
local nvim_tree = require'nvim-tree'
local nvim_tree_lib = require'nvim-tree.lib'
local change_dir = require'nvim-tree.actions.root.change-dir'
local telescope = require'telescope.builtin'
local util = require 'lspconfig.util'
local core = require "nvim-tree.core"

function M.nvim_tree_find_file()
  local function starts_with(str, pattern)
    return string.sub(str, 1, string.len(pattern)) == pattern
  end

  local path = vim.fn.expand('%:p:h')
  local new_root = util.find_git_ancestor(path) or path

  if not new_root or starts_with(new_root, vim.g.project_path) then
    core.init(vim.g.project_path)
    nvim_tree.find_file(true)
  else
    core.init(new_root)
    nvim_tree.find_file(true)
  end
end

function M.nvim_tree_toggle_project()
    change_dir.fn(vim.g.project_path)
    nvim_tree.toggle()
end

local function grep_at_current_tree_node()
    local node = nvim_tree_lib.get_node_at_cursor()
    if not node then return end
    telescope.live_grep({search_dirs = {node.absolute_path}})
end

function M.setup()
    vim.g.project_path = vim.fn.getcwd()
    nvim_tree.setup {
        disable_netrw = false,
        update_cwd = true,
        view = {
            width = 60,
            mappings = {
                list = {
                    { key = {"<Leader>gr", "gr" }, cb = grep_at_current_tree_node, mode = "n"}}
             }
        }
    }
end

return M
