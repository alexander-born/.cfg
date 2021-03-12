###Custom
alias vim="nvim"
alias vi="nvim"
alias git="git "
alias br="branch"
alias st="status"
alias co="checkout"
alias cls='printf "\033c"'
alias gitdelete_branches_expect_master="git co master && git br | grep -v master | xargs git branch -D"
alias gitshowbranchesof="git for-each-ref --format='%(committerdate) %09 %(authoremail) %09 %(refname)' | sort -k5n -k2M -k3n -k4n | grep -i"
alias gitmagic="cp /dev/null .gitattributes && git status && git checkout -- .gitattributes"
alias gitmegamagic="git rm --cached -r .; git reset --hard"
alias gencompdb="~/buildtools/bazel-compilation-database/generate.sh"
alias pinggoogle="tmux new-session -s pinggoogle \; \
  send-keys 'watch -n60 curl http://www.google.com/' C-m \; \
  detach"
alias ide="tmux new-session -s shared \; \
  send-keys 'cd ~/ddad;nvim' C-m \; \
  new-window 'bash' \; \
  send-keys 'cd ~/ddad' C-m \; \
  split-window -h \; \
  send-keys 'cd ~/ddad/application/adp' C-m \; "
alias dlt_viewer="cd ~/Applications/dlt_viewer ; LD_LIBRARY_PATH=. ./dlt_viewer &"

alias ddad="cd ~/ddad"
alias adp="cd ~/ddad/application/adp"
alias xpad-shared="cd ~/ddad/ecu/xpad/xpad-shared"
alias traces="cd ~/traces"
alias runrviz="cd ~/ddad/bazel-bin/application/adp/bmw/vehicle/configuration/had/bmw_veh_g12_control/launch/building_blocks/rviz_ad_lite_mpad.launch.sh.runfiles/ddad; ../../rviz_ad_lite_mpad.launch.sh;"

convert_clipboard_to_unix_path() { xclip -o -sel clip | sed 's/\\/\//g' | sed 's/^file:/smb:/' | xclip -i -sel clip; echo "[INFO] clipboard updated."; }

# bind F8 convert clipboard to unix directory
bind '"\e[19~": "convert_clipboard_to_unix_path\n"'

bind '"\e[1;5C":forward-word'
bind '"\e[1;5D":backward-word'

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000
#export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
export PROMPT_COMMAND="history -a; history -n"

 . ~/Applications/z/z.sh
