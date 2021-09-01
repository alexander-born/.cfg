function! OpenErrorInQuickfix()
    cexpr []
    caddexpr getline(0,'$')
    copen
    let l:qf_list = []
    for entry in getqflist()
        if (entry.valid == 1) 
            if (entry.bufnr !=0)
                call add(l:qf_list, entry)
            else
                call FindUnitTest(split(entry.text, '\.')[-1])
                for test in getqflist()
                    call add(l:qf_list, test)
                endfor
            endif
        endif
    endfor
    call setqflist(l:qf_list)
endfunction

