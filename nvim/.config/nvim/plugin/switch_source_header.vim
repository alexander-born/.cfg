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
