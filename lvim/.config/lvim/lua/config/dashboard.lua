lvim.builtin.project.active = false
lvim.builtin.alpha.startify.section.bottom_buttons = nil
lvim.builtin.alpha.dashboard.section.buttons.entries = {
  { "f", lvim.icons.ui.FindFile .. "  Find File", "<CMD>Telescope find_files<CR>" },
  { "n", lvim.icons.ui.NewFile .. "  New File", "<CMD>ene!<CR>" },
  { "p", lvim.icons.ui.Project .. "  Projects ", "<CMD>Telescope project<CR>" },
  { "r", lvim.icons.ui.History .. "  Recent files", ":Telescope oldfiles <CR>" },
  { "t", lvim.icons.ui.FindText .. "  Find Text", "<CMD>Telescope live_grep<CR>" },
  {
    "c",
    lvim.icons.ui.Gear .. "  Configuration",
    "<CMD>edit " .. require("lvim.config"):get_user_config_path() .. " <CR>",
  },
}
