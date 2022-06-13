local M = {}

local function StartDebugger(program, args)
    local avail, dap = pcall(require, 'dap')
    if avail then
      dap.run({
        name = "Launch",
        type = "cppdbg",
        request = "launch",
        program = function() return program end,
        cwd = vim.fn.getcwd(),
        stopOnEntry = false,
        args = args,
        runInTerminal = false,
        setupCommands = {{text = "-enable-pretty-printing", ignoreFailures = true}},
      })
    end
end

function M.DebugThisTest()
    local avail, bazel = pcall(require, 'bazel')
    if not avail then return end
    local program = bazel.get_bazel_test_executable()
    local args = {'--gtest_filter=' .. bazel.get_gtest_filter()}
    vim.cmd('new')
    local on_exit = function(_, code)
        if code == 0 then
            vim.cmd('bdelete')
            StartDebugger(program, args)
        end
    end
    vim.fn.termopen('bazel build ' .. vim.g.bazel_config .. ' -c dbg --cxxopt=-O0 ' .. vim.g.current_bazel_target, {on_exit = on_exit})
end

function M.YankLabel()
    if not vim.fn.exists('GetLabel') then return end
    local label = vim.fn.GetLabel()
    print('yanking ' .. label .. ' to + and " register')
    vim.fn.setreg('+', label)
    vim.fn.setreg('"', label)
end

function M.setup()
    -- Info: to make tab completion work copy '/etc/bash_completion.d/bazel-complete.bash' to '/etc/bash_completion.d/bazel'

    vim.g.bazel_config = vim.g.bazel_config  or ''
    if pcall(require, 'cmp') then
      vim.cmd [[ autocmd FileType bzl lua require'cmp'.setup.buffer { sources = { { name = 'bazel' }, { name = 'buffer' } } } ]]
    end


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
