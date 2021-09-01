let g:ackprg = 'ag --vimgrep'

function! FindUnitTest(test_name)
    exe "Ack! -G '\.cpp' " . a:test_name . " application/adp"
endfunction

