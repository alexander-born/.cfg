local M = {}

local function write_to_file(filename, lines)
    vim.cmd('e ' .. filename)
    vim.cmd('%delete')
    for _,line in pairs(lines) do
        vim.cmd("call append(line('$'), '" .. line .. "')")
    end
    vim.cmd('1d')
    vim.cmd('w')
    vim.cmd('e#')
end

local function create_cpp_vimspector_json_for_bazel_test()
    local test_filter = require('bazel').get_gtest_filter()
    local executable =  require('bazel').get_bazel_test_executable()
    local lines = {
        '{',
        '  "configurations": {',
        '    "GTest": {',
        '      "adapter": "vscode-cpptools",',
        '      "configuration": {',
        '        "request": "launch",',
        '        "program": "' .. executable .. '",',
        '        "args": ["--gtest_filter=\'\'' .. test_filter .. '\'\'"],',
        '        "stopOnEntry": false',
        '      }',
        '    }',
        '  }',
        '}'}
    write_to_file('.vimspector.json', lines)
end

function M.DebugThisTest()
    create_cpp_vimspector_json_for_bazel_test()
    vim.cmd('new')
    vim.cmd('call termopen("bazel build " . g:bazel_config . " -c dbg " . g:current_bazel_target, {"on_exit": "StartVimspector"})')
end

function M.setup()
    -- Info: to make tab completion work copy '/etc/bash_completion.d/bazel-complete.bash' to '/etc/bash_completion.d/bazel'

    vim.g.bazel_config = vim.g.bazel_config  or '--config=adp'

    vim.cmd[[
    set errorformat=ERROR:\ %f:%l:%c:%m
    set errorformat+=%f:%l:%c:%m
    set errorformat+=[\ \ FAILED\ \ ]\ %m\ (%.%#

    " Ignore build output lines starting with INFO:, Loading:, or [    
    set errorformat+=%-GINFO:\ %.%#    
    set errorformat+=%-GLoading:\ %.%#    
    set errorformat+=%-G[%.%#    

    " Errorformat settings
    " * errorformat reference: http://vimdoc.sourceforge.net/htmldoc/quickfix.html#errorformat
    " * look for message without consuming: https://stackoverflow.com/a/36959245/10923940
    " * errorformat explanation: https://stackoverflow.com/a/29102995/10923940

    " Ignore this error message, it is always redundant
    " ERROR: <filename>:<line>:<col>: C++ compilation of rule '<target>' failed (Exit 1)
     set errorformat+=%-GERROR:\ %f:%l:%c:\ C++\ compilation\ of\ rule\ %m
     set errorformat+=%tRROR:\ %f:%l:%c:\ %m   " Generic bazel error handler
     set errorformat+=%tARNING:\ %f:%l:%c:\ %m " Generic bazel warning handler
    " this rule is missing dependency declarations for the following files included by '<another-filename>'
    "   '<fname-1>'
    "   '<fname-2>'
    "   ...
     set errorformat+=%Ethis\ rule\ is\ %m\ the\ following\ files\ included\ by\ \'%f\':
     set errorformat+=%C\ \ \'%m\'
     set errorformat+=%Z

    " Test failures
     set errorformat+=FAIL:\ %m\ (see\ %f)            " FAIL: <test-target> (see <test-log>)

    " test failures in async builds
     set errorformat+=%E%*[\ ]FAILED\ in%m
     set errorformat+=%C\ \ %f
     set errorformat+=%Z

    " Errors in the build stage
     set errorformat+=%f:%l:%c:\ fatal\ %trror:\ %m         " <filename>:<line>:<col>: fatal error: <message>
     set errorformat+=%f:%l:%c:\ %trror:\ %m                " <filename>:<line>:<col>: error: <message>
     set errorformat+=%f:%l:%c:\ %tarning:\ %m              " <filename>:<line>:<col>: warning: <message>
     set errorformat+=%f:%l:%c:\ note:\ %m                  " <filename>:<line>:<col>: note: <message>
     set errorformat+=%f:%l:%c:\ \ \ requ%tred\ from\ here  " <filename>:<line>:<col>: <message>
     set errorformat+=%f(%l):\ %tarning:\ %m                " <filename>(<line>): warning: <message>
     set errorformat+=%f:%l:%c:\ %m                         " <filename>:<line>:<col>: <message>
     set errorformat+=%f:%l:\ %m                            " <filename>:<line>: <message>
     ]]


end

return M
