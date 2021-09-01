" faster update (default 4000)
set updatetime=100
set signcolumn=auto:2

" disable the default highlight group
let g:conflict_marker_highlight_group = ''

" Include text after begin and end markers
let g:conflict_marker_begin = '^<<<<<<< .*$'
let g:conflict_marker_end   = '^>>>>>>> .*$'

hi ConflictMarkerBegin guibg=#2f7366
hi ConflictMarkerOurs guibg=#2e5049
hi ConflictMarkerTheirs guibg=#344f69
hi ConflictMarkerEnd guibg=#2f628e
hi ConflictMarkerCommonAncestorsHunk guibg=#754a81

let g:github_enterprise_urls = ['https://cc-github.bmwgroup.net']

command! DiffHistory call s:view_git_history()
command! GitDiff call s:view_git_diff()


function! s:view_git_diff() abort
  Git difftool --name-only !
  cclose
  call s:diff_current_quickfix_entry_with_git_status()
endfunction

function! s:view_git_history() abort
    Git difftool --name-only ! !^@
    nnoremap <buffer> <CR> <CR><BAR>:call <sid>diff_current_quickfix_entry()<CR>
    call s:diff_current_quickfix_entry()
    11copen
    wincmd p
endfunction

function! s:diff_current_quickfix_entry_with_git_status() abort
    windo diffoff!
    let qf = s:get_git_diff_quickfix_list()
    if s:qf_has_diff_items(l:qf)
        let diff = s:get_current_qf_diff_entry(l:qf)
        let fugitive_file = s:get_fugitive_file(l:diff)
        let file = s:get_modified_file(l:diff)
        call s:open_git_status_on_bottom(l:file)
        call s:open_modified_file()
        call s:diff_with(l:fugitive_file)
        wincmd p
    else
        echo "Nothing to diff."
    endif
endfunction

function! s:get_current_qf_diff_entry(qf)
    return a:qf.context.items[a:qf.idx - 1].diff
endfunction

function! s:get_git_diff_quickfix_list()
    return getqflist({'context': 0, 'idx': 0})
endfunction

function! s:get_fugitive_file(diff)
    return a:diff[0].filename
endfunction

function! s:get_modified_file(diff)
    return fnameescape(strpart(a:diff[0].module, 2))
endfunction

function! s:qf_has_diff_items(qf) abort
    return get(a:qf, 'idx') && type(get(a:qf, 'context')) == type({}) && type(get(a:qf.context, 'items')) == type([])
endfunction

function! s:open_git_status_on_bottom(file) abort
  Git
  wincmd o
  exe "silent! norm /" . substitute(a:file, "\/", "\\\\\/", "g") . "\r"
  nnoremap <buffer><CR> :call <SID>open_diff_from_git_status()<CR>
  call s:add_diff_mappings()
  aboveleft wincmd s
  wincmd p
  resize 15
endfunction

function! s:open_git_status_on_left(file) abort
  Git
  wincmd o
  exe "silent! norm /" . substitute(a:file, "\/", "\\\\\/", "g") . "\r"
  nnoremap <buffer><CR> :call <SID>open_diff_from_git_status()<CR>
  call s:add_diff_mappings()
  wincmd v
  1wincmd w
  vertical resize 50
endfunction

function! s:is_current_git_status_file(idx, val) abort
    let git_dir = FugitiveGitDir()
    let working_dir = strpart(l:git_dir, 0, strlen(l:git_dir) - 4) " removes '.git'
    let file = substitute(fugitive#StatusCfile(), l:working_dir, "", "")
    let qf_entry = s:get_modified_file(a:val.diff)
    return l:qf_entry == l:file
endfunction

function! s:open_diff_from_git_status() abort
    let qf = s:get_git_diff_quickfix_list()
    if s:qf_has_diff_items(l:qf)
        let items = deepcopy(l:qf.context.items)
        call filter(l:items, function('s:is_current_git_status_file'))
        if len(l:items) == 1
            let idx = index(l:qf.context.items, l:items[0]) + 1
            call setqflist([], 'r', {'idx': l:idx})
            call s:diff_current_quickfix_entry_with_git_status()
        endif
    endif
endfunction

function! s:open_modified_file() abort
    wincmd p
    cc
    call s:add_diff_mappings()
endfunction

function! s:diff_with(filename) abort
    exe 'vertical leftabove diffsplit' a:filename
    call s:add_diff_mappings()
endfunction

function! s:add_diff_mappings() abort
    nnoremap <buffer>]q :1wincmd w <BAR> :cnext <BAR> :call <SID>diff_current_quickfix_entry_with_git_status()<CR>
    nnoremap <buffer>[q :1wincmd w <BAR> :cprevious <BAR> :call <SID>diff_current_quickfix_entry_with_git_status()<CR>
endfunction

function s:diff_current_quickfix_entry() abort
    " Cleanup windows
    windo diffoff!
    for window in getwininfo()
        if window.winnr !=? winnr() && !window.quickfix
            exe 'bdelete' window.bufnr
        endif
    endfor
    cc
    call s:add_mappings()
    let qf = s:get_git_diff_quickfix_list()
    if s:qf_has_diff_items(l:qf)
        let diff = s:get_current_qf_diff_entry(l:qf)
        exe 'vertical diffsplit' s:get_fugitive_file(l:diff)
        call s:add_mappings()
    endif
endfunction

function! s:add_mappings() abort
    nnoremap <buffer>]q :cnext <BAR> :call <sid>diff_current_quickfix_entry()<CR>
    nnoremap <buffer>[q :cprevious <BAR> :call <sid>diff_current_quickfix_entry()<CR>
endfunction
