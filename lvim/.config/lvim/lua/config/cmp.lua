lvim.builtin.cmp.completion.keyword_length = 2
lvim.builtin.cmp.formatting.format = function(entry, vim_item)
  vim_item.abbr = string.sub(vim_item.abbr, 1, 100)
  return require 'lspkind'.cmp_format({})(entry, vim_item)
end
table.insert(lvim.builtin.cmp.sources, 1, { name = "bazel" })
