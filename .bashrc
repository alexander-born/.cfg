###Custom
alias vim="nvim"
alias vi="nvim"
alias watch_astas_log='find ~/.ros/ -name "astas_log_file*" | sort | tail -1 | xargs tail -f'
alias watch_reprossing_log='find ~/temp/repro -name "sut_log.txt*" | sort | tail -1 | xargs tail -f'
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

bind '"\e[1;5C":forward-word'
bind '"\e[1;5D":backward-word'

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000
#export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
export PROMPT_COMMAND="history -a; history -n"
