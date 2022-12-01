local M = {}

function M.setup()
    vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("IndentBlanklineBigFile", {}),
    pattern = "*",
    callback = function()
        if vim.api.nvim_buf_line_count(0) > 3000 then
            require("indent_blankline.commands").disable()
        end
    end,
})
end

return M
