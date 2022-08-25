function Dirname(str)
	if str:match(".-/.-") then
		local name = string.gsub(str, "(.*/)(.*)", "%1")
		return name
	else
		return ''
	end
end

function Basename(str)
	local name = string.gsub(str, "(.*/)(.*)", "%2")
	return name
end

vim.cmd[[
function! CopyFormatted(line1, line2)
    execute a:line1 . "," . a:line2 . "TOhtml"
    %yank +
    call system('xclip -o -sel clip | xclip -i -sel clip -target text/html')
    bwipeout!
endfunction

command! -range=% HtmlClip silent call CopyFormatted(<line1>,<line2>)

function! OpenErrorInQuickfix()
    cexpr []
    caddexpr getline(0,'$')
    copen
    let l:qf_list = []
    for entry in getqflist()
        if (entry.valid == 1) 
            if (entry.bufnr !=0)
                call add(l:qf_list, entry)
            endif
        endif
    endfor
    call setqflist(l:qf_list)
endfunction

function! AdaptFilePath(filepath, pattern, replacement)
    let index = strridx(a:filepath, a:pattern) 
    if (index != -1)
        return a:filepath[0:index] . a:replacement
    endif
    return a:filepath
endfunction

function! SwitchSourceHeader()
    let filepath = expand('%:p:h')
    let filename = expand("%:t:r")
    let fileending = expand("%:e")
    if (fileending == "cpp")
        let filetype = ".h"
        let filepath = AdaptFilePath(filepath, "/src", "includes/**")
        let filepath = AdaptFilePath(filepath, "/Sources", "Includes/**")
    endif
    if (fileending == "h")
        let filetype = ".cpp"
        let filepath = AdaptFilePath(filepath, "/includes", "src/**")
        let filepath = AdaptFilePath(filepath, "/Includes", "Sources/**")
    endif
    exe "find " . filepath . "/" . filename . filetype
endfunction
]]

function UpdateConfig()
    vim.cmd('!stow -D nvim -d ~/.cfg -t ~')
    vim.cmd('!stow -D nvim -d ~/.cfg_work -t ~')
    vim.cmd('!git -C ~/.cfg pull')
    vim.cmd('!git -C ~/.cfg_work pull')
    vim.cmd('!stow nvim -d ~/.cfg -t ~')
    vim.cmd('!stow nvim -d ~/.cfg_work -t ~')
    vim.cmd('!for f in ~/.config/bash/*; do source $f; done')
end

vim.cmd[[command! UpdateConfig execute "lua UpdateConfig()"]]
vim.cmd[[command! SetupPyrightForBazel execute "lua require'config.bazel'.setup_pyright_with_bazel()"]]
vim.cmd[[command! PyrightForBazelSetup execute "lua require'config.bazel'.setup_pyright_with_bazel()"]]
