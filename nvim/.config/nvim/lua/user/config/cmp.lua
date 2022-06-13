return {
  formatting = {
    fields = { 'abbr', 'kind', 'menu' },
    format = function(entry, vim_item)
      vim_item.abbr = string.sub(vim_item.abbr, 1, 100)
      return require'lspkind'.cmp_format({})(entry, vim_item)
     end
  },
}
