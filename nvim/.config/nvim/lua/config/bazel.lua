local bazel = require'bazel'

local M = {}

local function StartDebugger(type, program, args, cwd, env)
    require'dap'.run({
        name = "Launch",
        type = type,
        request = "launch",
        program = function() return program end,
        env = env,
        args = args,
        cwd = cwd,
        runInTerminal = false,
        stopOnEntry = false,
        setupCommands = {{text = "-enable-pretty-printing", ignoreFailures = true}},
    })
end

function M.YankLabel()
    local label = vim.fn.GetLabel()
    print('yanking ' .. label .. ' to + and " register')
    vim.fn.setreg('+', label)
    vim.fn.setreg('"', label)
end

local function get_python_imports(program)
    local command = "grep 'python_imports =' "  .. program .. [[ | sed "s|.*'\(.*\)'|\1|"]]
    return vim.fn.system(command):gsub("\n","")
end

local function get_bazel_python_modules(program)
    local runfiles = program .. ".runfiles"
    local extra_paths = { runfiles, BufDir(), runfiles .. '/' .. Basename(bazel.get_workspace()) }
    local imports = Split(get_python_imports(program), ':')
    for _, import in pairs(imports) do
        table.insert(extra_paths, runfiles .. '/' .. import)
    end
    return extra_paths
end

local function get_python_path(program)
    local extra_paths = get_bazel_python_modules(program)
    local env = ""
    local sep = ""
    for _, extra_path in pairs(extra_paths) do
        env = env .. sep .. extra_path
        sep = ":"
    end
    return env
end

function M.setup_pyright_with_bazel_for_this_target()
    local program = bazel.get_executable()
    local root = bazel.get_workspace()
    local setup_pyright = function(_, success)
        if success == 0 then
            vim.cmd('bdelete')
            local config = { capabilities = require'config.lsp'.get_capabilities() }
            config.settings = { python = { analysis = { extraPaths = get_bazel_python_modules(program) } } }
            require('lspconfig')['pyright'].setup(config)
        end
    end
    vim.cmd('new')
    vim.fn.termopen('bazel build ' .. vim.g.bazel_config .. ' ' .. vim.g.current_bazel_target, {on_exit = setup_pyright, cwd = root })
end

local function default_program(bazel_executable) return bazel_executable end
local function default_env(_) return {} end

function M.DebugBazel(type, bazel_config, get_program, args, get_env)
    local bazel_executable = bazel.get_executable()
    local bazel_root = bazel.get_workspace()
    local on_exit = function(_, success)
        if success == 0 then
            vim.cmd('bdelete')
            local cwd = bazel_executable .. '.runfiles/' .. Basename(bazel_root)
            local env = get_env(bazel_executable)
            StartDebugger(type, get_program(bazel_executable), args, cwd, env)
        end
    end
    vim.cmd('new')
    vim.fn.termopen('bazel build ' .. bazel_config .. ' ' .. vim.g.current_bazel_target, {on_exit = on_exit, cwd = bazel_root })
end

function M.DebugBazelPy(get_program)
    local args = vim.g.python_debug_args or {""}
    local get_env = function(bazel_executable) return { PYTHONPATH = get_python_path(bazel_executable) } end
    M.DebugBazel("python", vim.g.bazel_config, get_program, args, get_env)
end

function M.DebugPythonBinary()
    M.DebugBazelPy(function(_) return "${file}" end)
end

function M.DebugPytest()
    M.DebugBazelPy(function(bazel_executable) return bazel_executable .. '_pytest_runner.py' end)
end

function M.DebugGTest()
    local args = {'--gtest_filter=' .. bazel.get_gtest_filter()}
    M.DebugBazel("cppdbg", vim.g.bazel_config_dbg, default_program, args, default_env)
end

function M.DebugTest()
    if vim.bo.filetype == "python" then
        M.DebugPytest()
    elseif vim.bo.filetype == "cpp" then
        M.DebugGTest()
    else
        print("Debugging not supported for this filetype")
    end
end

function M.DebugRun()
    if vim.bo.filetype == "python" then
        M.DebugPythonBinary()
    else
        vim.fn.RunBazelHere("run "   .. vim.g.bazel_config_dbg)
    end
end

function M.root_dir_clangd()
    return function(fname)
        if bazel.is_bazel_cache(fname) then
            return bazel.get_workspace_from_cache(fname)
        elseif bazel.is_bazel_workspace(fname) then
            return bazel.get_workspace(fname)
        end
        return require'lspconfig.server_configurations.clangd'.default_config.root_dir(fname)
    end
end

function M.setup()
    -- Info: to make tab completion work copy '/etc/bash_completion.d/bazel-complete.bash' to '/etc/bash_completion.d/bazel'

    vim.g.bazel_config = vim.g.bazel_config  or ''
    vim.g.bazel_config_dbg = vim.g.bazel_config_dbg  or ''

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
