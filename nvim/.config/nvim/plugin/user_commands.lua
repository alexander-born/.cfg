function UpdateConfig()
    vim.cmd('!git -C ~/.cfg pull')
    vim.cmd('!git -C ~/.cfg_work pull')
end

vim.cmd[[command! UpdateConfig execute "lua UpdateConfig()"]]
