lvim.builtin.nvimtree.setup.renderer.icons.show.git = false
lvim.builtin.nvimtree.setup.disable_netrw = false
lvim.builtin.nvimtree.setup.view.width = 60

local function grep_at_current_tree_node()
  local node = require('nvim-tree.lib').get_node_at_cursor()
  if not node then return end
  require('telescope.builtin').live_grep({ search_dirs = { node.absolute_path } })
end

table.insert(lvim.builtin.nvimtree.setup.view.mappings.list,
  { key = { "<Leader>gr", "gr" }, cb = grep_at_current_tree_node, mode = "n" })
