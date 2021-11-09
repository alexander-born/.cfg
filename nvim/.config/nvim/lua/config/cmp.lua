local M = {}

function M.setup()

    -- Set completeopt to have a better completion experience
    vim.o.completeopt = 'menuone,noselect'

    local cmp = require 'cmp'
    cmp.setup {
      snippet = {
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body)
        end,
     },
     formatting = {
       format = require'lspkind'.cmp_format({})
     },
      mapping = {
        ['<CR>'] = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        },
      },
      sources = {
        { name = 'nvim_lsp' },
        { name = 'vsnip' },
        { name = 'path' },
        { name = 'buffer' },
      },
    }

    vim.cmd [[ autocmd FileType bzl lua require'cmp'.setup.buffer { sources = { { name = 'bazel' }, { name = 'buffer' } } } ]]
end

return M
