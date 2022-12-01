lvim.builtin.telescope.pickers = nil
lvim.builtin.telescope.defaults.path_display = nil

lvim.builtin.telescope.on_config_done = function(telescope)
  pcall(telescope.load_extension, "dap")
  pcall(telescope.load_extension, "neoclip")
  pcall(telescope.load_extension, "project")
end
