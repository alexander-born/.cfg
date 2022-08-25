local M = {}

local function StartDebugger(program, args, bazel_root)
    require'dap'.run({
        name = "Launch",
        type = "cppdbg",
        request = "launch",
        program = function() return program end,
        cwd = bazel_root,
        stopOnEntry = false,
        args = args,
        runInTerminal = false,
        setupCommands = {{text = "-enable-pretty-printing", ignoreFailures = true}},
    })
end

function M.DebugThisTest()
    local program = require('bazel').get_bazel_test_executable()
    local args = {'--gtest_filter=' .. require('bazel').get_gtest_filter()}
    local bazel_root = require'bazel'.get_bazel_workspace()
    vim.cmd('new')
    local start_debugger = function(_, success)
        if success == 0 then
            vim.cmd('bdelete')
            StartDebugger(program, args, bazel_root)
        end
    end
    vim.fn.termopen('bazel build ' .. vim.g.bazel_config .. ' -c dbg --cxxopt=-O0 ' .. vim.g.current_bazel_target, {on_exit = start_debugger, cwd = bazel_root })
end

function M.YankLabel()
    local label = vim.fn.GetLabel()
    print('yanking ' .. label .. ' to + and " register')
    vim.fn.setreg('+', label)
    vim.fn.setreg('"', label)
end

local function get_bazel_python_modules(program, bazel_root)
    local Path = require'plenary.path'
    local extra_paths = {}
    local add_extra_paths = function(_, stdout)
        for _, line in ipairs(stdout) do
            if Path:new(line):exists() and line ~= "" then
                table.insert(extra_paths, line)
            end
        end
    end
    local find_python_modules = [[sed 's/.* //' ]] .. program .. [[.runfiles_manifest | grep __init__.py | xargs -r dirname | xargs -r dirname | grep -v "external$" | sort | uniq | awk '! /\/$/ { $0 = $0 "/" } last && last == substr($0, 1, length(last)) { next; } { last = $0; sub(/\/$/, "", $0); print }']]
    local jobid = vim.fn.jobstart(find_python_modules, { on_stdout = add_extra_paths })
    vim.fn.jobwait({jobid})
    table.insert(extra_paths, program .. ".runfiles/" .. Basename(bazel_root))
    return extra_paths
end

local function get_python_path(program, bazel_root)
    local extra_paths = get_bazel_python_modules(program, bazel_root)
    local env = ""
    local sep = ""
    for _, extra_path in pairs(extra_paths) do
        env = env .. sep .. extra_path
        sep = ":"
    end
    return env
end

function M.DebugBazelPython()
    local program = require('bazel').get_bazel_test_executable()
    local bazel_root = require'bazel'.get_bazel_workspace()
    vim.cmd('new')
    local start_debugger = function(_, success)
        if success == 0 then
            vim.cmd('bdelete')
            require'dap'.run({
                name = "Launch",
                type = "python",
                request = "launch",
                program = "${file}",
                args = vim.g.python_debug_args or {""},
                cwd = bazel_root,
                env = {PYTHONPATH = get_python_path(program, bazel_root)},
                stopOnEntry = false,
                runInTerminal = false,
            })
        end
    end
    vim.fn.termopen('bazel build ' .. vim.g.bazel_config .. ' ' .. vim.g.current_bazel_target, {on_exit = start_debugger, cwd = bazel_root })
end

function M.setup()
    -- Info: to make tab completion work copy '/etc/bash_completion.d/bazel-complete.bash' to '/etc/bash_completion.d/bazel'

    vim.g.bazel_config = vim.g.bazel_config  or ''

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
