function! StartVimspector(job_id, code, event) dict
    if a:code == 0
        close
        call vimspector#Launch()
    endif
endfun

" send gdb commands with '-exec <command>' in vimspector console window

let g:vimspector_install_gadgets = [ 'debugpy', 'vscode-cpptools' ]
fun! GotoWindow(id)
    call win_gotoid(a:id)
    MaximizerToggle
endfun
