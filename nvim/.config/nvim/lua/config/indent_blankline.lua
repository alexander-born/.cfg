local M = {}

function M.setup()
    save.setup('indent_blankline', {filetype = {'python', 'json', 'bzl'} })
end

return M
