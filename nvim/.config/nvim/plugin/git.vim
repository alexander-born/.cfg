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
