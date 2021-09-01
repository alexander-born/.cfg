local M = {}

function M.setup()
  require'compe'.setup {
    enabled = true;
    source = {
      path = true;
      buffer = true;
      calc = true;
      nvim_lsp = true;
      nvim_lua = true;
      vsnip = true;
    };
  }

  vim.cmd[[
  " Set completeopt to have a better completion experience
  set completeopt=menuone,noinsert,noselect
  let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']
  let g:completion_matching_smart_case = 1

  " Avoid showing message extra message when using completion
  set shortmess+=c
  ]]
end

return M
