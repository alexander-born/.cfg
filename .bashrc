###Custom
alias vim="nvim"
alias vi="nvim"
alias tmux='tmux -2'
setxkbmap -option caps:escape
git config --global core.editor "nvim"
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
alias cls='printf "\033c"'
alias gitdelete_branches_expect_master="git co master && git br | grep -v master | xargs git branch -D"
alias gitshowbranchesof="git for-each-ref --format='%(committerdate) %09 %(authoremail) %09 %(refname)' | sort -k5n -k2M -k3n -k4n | grep -i"
alias gitmagic="cp /dev/null .gitattributes && git status && git checkout -- .gitattributes"
alias gitmegamagic="git rm --cached -r .; git reset --hard"
alias pinggoogle="tmux new-session -s pinggoogle \; \
  send-keys 'watch -n60 curl http://www.google.com/' C-m \; \
  detach"
alias ide="tmux new-session -s shared \; \
  send-keys 'cd ~/ddad;nvim' C-m \; \
  new-window 'bash' \; \
  send-keys 'cd ~/ddad' C-m \; "
alias dlt_viewer="cd ~/Applications/dlt_viewer ; LD_LIBRARY_PATH=. ./dlt_viewer &"

alias ddad="cd ~/ddad"
alias adp="cd ~/ddad/application/adp"
alias xpad-shared="cd ~/ddad/ecu/xpad/xpad-shared"
alias traces="cd ~/traces"
alias runrviz="cd ~/ddad/bazel-bin/application/adp/bmw/vehicle/configuration/had/bmw_veh_g12_control/launch/building_blocks/rviz_ad_lite_mpad.launch.sh.runfiles/ddad; ../../rviz_ad_lite_mpad.launch.sh;"

convert_clipboard_to_unix_path() { xclip -o -sel clip | sed 's/\\/\//g' | sed 's/^file:/smb:/' | xclip -i -sel clip; echo "[INFO] clipboard updated."; }

gencompdbadp() { 
    ~/ddad/application/adp/tools/compile_commands/generate_compile_commands.sh ~/ddad/compile_commands.json --config=adp //application/adp/... ;
    sed -i 's/-fno-canonical-system-headers//' ~/ddad/compile_commands.json
}

gencompdb() { 
    bazel-compdb
    sed -i 's/-fno-canonical-system-headers//' ./compile_commands.json
}

# Install/update neovim nightly
update_nvim() {
    curl -L https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage -o /tmp/nvim;
    chmod +x /tmp/nvim;
    sudo mv /tmp/nvim /usr/local/bin;
}

find_in_advantage() {
    local vin=$(echo "$1" | sed -E "s/[0-9]+T[0-9]+_[0-9]+T[0-9]+_[0-9]+_([A-Z0-9]+)_.*.MF4/\1/g")
    local yy=$(echo "$1" | sed -E "s/^([0-9]{4}).*/\1/g")
    local mm=$(echo "$1" | sed -E "s/^[0-9]{4}([0-9]{2}).*/\1/g")
    local dd=$(echo "$1" | sed -E "s/^[0-9]{6}([0-9]{2}).*/\1/g")
    ssh advantagedp "ls /maprposix/dp.prod.munich/ad-vantage/data/store/collected/car-data/MDF4/ingest/$vin/$yy/$mm/$dd/*/*/BN_EV_FASETH_UC/*/*" | grep "$1"
}

export GIT_PS1_SHOWDIRTYSTATE='y'
export GIT_PS1_SHOWSTASHSTATE='y'
export GIT_PS1_SHOWUNTRACKEDFILES='y'
export GIT_PS1_DESCRIBE_STYLE='contains'
export GIT_PS1_SHOWUPSTREAM='auto'
export PS1='\[\033[32m\]\u@\h\[\033[00m\]:\[\033[34m\]\w\[\033[31m\]$(__git_ps1)\[\033[00m\]\$ '

# add ddad to python path
export PYTHONPATH=$PYTHONPATH:~/ddad:~/.local/bin

# bind F8 convert clipboard to unix directory
bind '"\e[19~": "convert_clipboard_to_unix_path\n"'

bind '"\e[1;5C":forward-word'
bind '"\e[1;5D":backward-word'

bind '"\C-n":menu-complete'
bind '"\C-p":menu-complete-backward'

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=100000
HISTFILESIZE=200000
export HISTCONTROL=ignoreboth:erasedups
#export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
export PROMPT_COMMAND="history -a; history -n"

 . ~/Applications/z/z.sh
 . /usr/share/doc/fzf/examples/key-bindings.bash
