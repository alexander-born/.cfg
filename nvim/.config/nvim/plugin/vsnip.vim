" Jump forward or backward
imap <expr> <C-j> vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<C-j>'
smap <expr> <C-j> vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<C-j>'
imap <expr> <C-k> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-k>'
smap <expr> <C-k> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-k>'

function s:TM_INCLUDEGUARD(context) abort
    let l:guard = expand('%')
    let l:guard = substitute(guard, "[./]", "_", "g")
    return toupper(guard)
endfunction
call vsnip#variable#register('TM_INCLUDEGUARD', function('s:TM_INCLUDEGUARD'))

