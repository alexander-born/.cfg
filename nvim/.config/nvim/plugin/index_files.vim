"index all files in folder (recursivly)
function! IndexFiles(path)
    echom "Add all files to arglist from " . a:path
    exe "silent args " . a:path . "/**/*.cpp"
    echom "Opening all files from " . a:path
    silent! argdo e
    echom "Closing all files from " . a:path
    silent! argdo bw
    echom "Clear arglist"
    argdelete *
endfunction
