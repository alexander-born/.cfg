local M = {}

function M.setup(package, config)
  local available, plugin = pcall(require, package)
  if available then
      if config then
          plugin.setup(config)
      else
          plugin.setup()
      end
  end
end

function M.init(package)
  local available, plugin = pcall(require, package)
  if available then plugin.init() end
end

return M
