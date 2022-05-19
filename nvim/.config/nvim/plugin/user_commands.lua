function UpdateConfig()
    vim.cmd('!git -C ~/.cfg pull')
    vim.cmd('!git -C ~/.cfg_work pull')
    vim.cmd('!stow nvim -d ~/.cfg -t ~')
    vim.cmd('!stow nvim -d ~/.cfg_work -t ~')
end

vim.cmd[[command! UpdateConfig execute "lua UpdateConfig()"]]
