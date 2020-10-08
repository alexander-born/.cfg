# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth


# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


###Custom
alias watch_astas_log='find ~/.ros/ -name "astas_log_file*" | sort | tail -1 | xargs tail -f'
alias watch_reprossing_log='find ~/temp/repro -name "sut_log.txt*" | sort | tail -1 | xargs tail -f'
alias br="branch"
alias st="status"
alias co="checkout"
alias gitmagic="cp /dev/null .gitattributes && git status && git checkout -- .gitattributes"
alias git_delete_branches_expect_master="git co master && git br | grep -v master | xargs git branch -D"
alias cls='printf "\033c"'
alias gitshowbranchesof="git for-each-ref --format='%(committerdate) %09 %(authoremail) %09 %(refname)' | sort -k5n -k2M -k3n -k4n | grep -i"
alias gitmegamagic="git rm --cached -r .; git reset --hard"
alias generate-compilation-database="~/buildtools/bazel-compilation-database/generate.sh --config=host_ros_clang"
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

###  BMWRPP-BEGIN  ###
# Do not change content between BEGIN and END!
# This section is managed by a script.

if [ -f "/etc/bmwrpp-bootstrap/bashrc" ]; then
  . "/etc/bmwrpp-bootstrap/bashrc"
else
  echo "bmwrpp-bootstrap not installed, please remove BMWRPP section from /home/q456457/.bashrc"
fi
###  BMWRPP-END  ###

