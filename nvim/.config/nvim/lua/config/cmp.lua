local M = {}

function M.setup()
    -- local luasnip = require 'luasnip'

    local cmp = require 'cmp'
    cmp.setup {
      snippet = {
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body)
        end,
     },
     formatting = {
       format = function(entry, vim_item)
         vim_item.abbr = string.sub(vim_item.abbr, 1, 100)
         return require'lspkind'.cmp_format({})(entry, vim_item)
       end

     },
      mapping = {
        ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
        ['<CR>'] = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        },
        ['<C-n>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          -- elseif luasnip.expand_or_jumpable() then
          --   luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { 'i', 's' }),
        ['<C-p>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          -- elseif luasnip.jumpable(-1) then
          --   luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'i', 's' }),
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
