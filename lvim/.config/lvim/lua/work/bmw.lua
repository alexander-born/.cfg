local function project_configuration()
  local live_grep = require 'telescope.builtin'.live_grep
  local function map_live_grep(key, opts, desc)
    vim.keymap.set('n', key, function() live_grep(opts) end, { desc = desc })
  end

  local function add_ddad_mapping()
    map_live_grep('<leader>grl',
      { search_dirs = { "application/adp/perception/lanes", "application/adp/ros/simulation/perception/lanes",
        "application/adp/activities/lanes" } }, "Grep Lanes")
    map_live_grep('<leader>grm', { search_dirs = { "application/adp/map" } }, "Grep Map")
    map_live_grep('<leader>gra', { search_dirs = { "application/adp" } }, "Grep ADP")
    map_live_grep('<leader>grr',
      { search_dirs = { "application/adp/perception/road", "application/adp/map", "application/adp/activities/road" } }
      , "Grep Road")
  end

  local bazel = require 'bazel'
  if bazel.is_bazel_workspace() then
    if bazel.get_workspace_name() == "ddad" then
      vim.g.bazel_config = vim.env.BAZELCONFIG or ''
      vim.g.bazel_config_dbg = vim.env.BAZELCONFIGDBG or ''
      add_ddad_mapping()
    end
    if bazel.get_workspace_name() == "perception" then
      vim.g.bazel_config = vim.env.BAZELCONFIGPERCEPTION25 or ''
      vim.g.bazel_config_dbg = vim.env.BAZELCONFIGPERCEPTION25 or '-c dbg --copt=-O0'
    end
    if bazel.get_workspace_name() == "orion" then
      vim.g.bazel_config = '--config=clang11'
      vim.g.bazel_config_dbg = '--config=clang11 --compilation_mode=dbg --copt=-O0'
    end
  end
end

vim.g.github_enterprise_urls = { 'https://cc-github.bmwgroup.net' }

function refresh_compile_commands_current_target()
  vim.fn.BazelGetCurrentBufTarget()
  vim.cmd('new')
  vim.fn.termopen('refresh_compile_commands ' .. vim.g.current_bazel_target)
end

local map = vim.keymap.set
local builtin = require 'telescope.builtin'
map('n', '<leader>f.',
  function() builtin.find_files({ prompt_title = ".cfg", cwd = "$HOME",
      search_dirs = { "$HOME/.cfg_work", "$HOME/.cfg" },
      hidden = true, file_ignore_patterns = { ".git" } })
  end, { desc = "Find .cfg" })
map('n', '<leader>gr.',
  function() builtin.live_grep({ cwd = "$HOME", search_dirs = { "$HOME/.cfg_work", "$HOME/.cfg" },
      vimgrep_arguments = { 'rg', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column',
        '--smart-case', '--hidden' }, file_ignore_patterns = { ".git" } })
  end, { desc = "Grep .cfg" })

vim.api.nvim_create_autocmd("DirChanged", {
  callback = function()
    project_configuration()
  end,
})
