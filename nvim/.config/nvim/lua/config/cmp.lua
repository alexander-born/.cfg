local M = {}

function M.setup()

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
        ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
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
