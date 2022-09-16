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
    return vim.fn.trim(vim.fn.system(command))
end

local function get_bazel_python_modules(program)
    local runfiles = program .. ".runfiles"
    local extra_paths = { runfiles, BufDir(), runfiles .. '/' .. bazel.get_workspace_name() }
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

local function setup_pyright(extra_paths)
    local config = { capabilities = require'config.lsp'.get_capabilities() }
    config.settings = { python = { analysis = { extraPaths = extra_paths } } }
    require('lspconfig')['pyright'].setup(config)
end

local function add_python_deps_to_pyright(target, workspace)
    local query = "bazel cquery " .. vim.g.bazel_config .. " '" .. target .. "' --output starlark --starlark:expr='providers(target)[\"PyInfo\"].imports'"

    local ws_name = Basename(workspace)
    local function parse_and_add_extra_path(_, stdout)
        local extra_paths = {workspace}
        local query_output = stdout[1]
        local depset = query_output:match("depset%(%[(.*)%]")
        if depset == nil then return end
        for extra_path in depset:gmatch('"(.-)"') do
            if extra_path:match("^" .. ws_name) then
                local path = extra_path:gsub("^" .. ws_name, workspace .. "/bazel-bin")
                table.insert(extra_paths, path)
            else
                table.insert(extra_paths, workspace .. "/external/" .. extra_path)
            end
        end
        setup_pyright(extra_paths)
    end

    vim.fn.jobstart(query, { on_stdout = parse_and_add_extra_path })
end

function M.setup_pyright_with_bazel_for_this_target()
    local workspace = bazel.get_workspace()
    vim.fn.BazelGetCurrentBufTarget()
    add_python_deps_to_pyright(vim.g.current_bazel_target, workspace)
end

function M.DebugBazel(type, bazel_config, get_program, args, get_env)
    local start_debugger = function(bazel_info)
        local cwd = bazel_info.runfiles .. "/" .. bazel_info.workspace_name
        StartDebugger(type, get_program(bazel_info.executable), args, cwd, get_env(bazel_info.executable))
    end
    bazel.run_here('build', bazel_config, { on_success = start_debugger})
end

function M.DebugBazelPy(get_program)
    local args = vim.g.python_debug_args or {""}
    local get_env = function(executable) return { PYTHONPATH = get_python_path(executable) } end
    M.DebugBazel("python", vim.g.bazel_config, get_program, args, get_env)
end

function M.DebugPythonBinary()
    M.DebugBazelPy(function(_) return "${file}" end)
end

function M.DebugPytest()
    M.DebugBazelPy(function(bazel_executable) return bazel_executable .. '_pytest_runner.py' end)
end

local function default_program(executable) return executable end
local function default_env(_) return {} end

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
        M.DebugBazel("cppdbg", vim.g.bazel_config_dbg, default_program, {}, default_env)
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
