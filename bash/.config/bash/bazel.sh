bazel_get_workspace_path() {
  local workspace=$PWD
  while true; do
    if [ -f "${workspace}/WORKSPACE" ]; then
      break
    elif [ -z "$workspace" -o "$workspace" = "/" ]; then
      workspace=$PWD
      break;
    fi
    workspace=${workspace%/*}
  done
  echo $workspace
}


add_hedron_to_workspace_file()
{
    echo '
local_repository(
    name = "hedron_compile_commands",
    path = "'$HOME'/projects/bazel-compile-commands-extractor",
)
load("@hedron_compile_commands//:workspace_setup.bzl", "hedron_compile_commands_setup")
hedron_compile_commands_setup()' >> WORKSPACE
}

add_refresh_compile_commands_target()
{
    echo '
load("@hedron_compile_commands//:refresh_compile_commands.bzl", "refresh_compile_commands")

refresh_compile_commands(
    name = "refresh_compile_commands",
    exclude_headers = "all",
    exclude_external_sources = True,
    targets = [' >> BUILD
    echo '"'$1'",' >> BUILD
    echo '],
)' >> BUILD
}

refresh_compile_commands()
{
    git clone https://github.com/hedronvision/bazel-compile-commands-extractor.git ~/projects/bazel-compile-commands-extractor
    git -C ~/projects/bazel-compile-commands-extractor pull
    pushd $(bazel_get_workspace_path)
    add_hedron_to_workspace_file
    add_refresh_compile_commands_target $1
    local config="${@:2}"
    bazel run //:refresh_compile_commands -- $config --keep_going
    git co WORKSPACE
    git co BUILD
    git co .gitignore
    popd
}

export -f add_hedron_to_workspace_file
export -f add_refresh_compile_commands_target
export -f refresh_compile_commands
export -f bazel_get_workspace_path
