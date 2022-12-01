local M = {}
function M.setup()
    -- disable the default highlight group
    vim.g.conflict_marker_highlight_group = ''

    -- Include text after begin and end markers
    vim.g.conflict_marker_begin = '^<<<<<<< .*$'
    vim.g.conflict_marker_end   = '^>>>>>>> .*$'

    vim.cmd[[
    hi ConflictMarkerBegin guibg=#2f7366
    hi ConflictMarkerOurs guibg=#2e5049
    hi ConflictMarkerTheirs guibg=#344f69
    hi ConflictMarkerEnd guibg=#2f628e
    hi ConflictMarkerCommonAncestorsHunk guibg=#754a81
    ]]
end
return M
