# Don't do anything, when not running interactively. 
case $- in
    *i*) ;;
      *) return;;
esac

case $(uname -m) in
    armv7l)
    export LANG=ja_JP.UTF-8
    export LC_ALL=ja_JP.UTF-8
    ;;
    *)
    export LANG=C.UTF-8
    export LC_ALL=C.UTF-8
    ;;
esac

export HISTCONTROL=ignoredups:ignorespace:erasedups
export HISTIGNORE='?:??:???:exit'

export EDITOR=vim

stty stop undef

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.bash_keys ]; then
    . ~/.bash_keys
fi

function add_path() {
    if [ -d "$1" ]; then
        PATH=${PATH}:"$1"
    fi
}

add_path /opt/bin
add_path "${HOME}/.local/bin"
add_path "${HOME}/bin"
add_path /ucrt64/bin
add_path /mingw64/bin

function mcd() {
    mkdir "$1"
    cd "$1"
}

function c() {
    BOOKMARK="~/.dir_bookmark"
    BOOKMARK=`eval echo "$BOOKMARK"`
    HOME_STR=`echo $HOME | sed -e 's/\//\\\\\//g' `
    if [[ -z $1 ]] ; then
        if  [[ -z $(which fzf) ]] ; then
	    cat ${BOOKMARK}
	else
            local selected
            selected=$(fzf < "${BOOKMARK}")
            selected=$(echo ${selected} | sed -e "s/^.*://" -e "s/~/${HOME_STR}/")
            cd ${selected}
	fi
    else
        RES=$(grep ^"$1" ~/.dir_bookmark | sed -e "s/^.*://" -e "s/~/${HOME_STR}/")

        if [[ -z ${RES} ]] ; then
            cat "${BOOKMARK}"
        else
           cd "${RES}"
        fi
    fi
}

function fzf_history() {
    local l
    l=$(HISTTIMEFORMAT='' history | sed -e 's/^[[:space:]]*[0-9]\+[[:space:]]*//' | fzf --query "$READLINE_LINE")
    READLINE_LINE="$l"
    READLINE_POINT=${#l}
}
bind -x '"\C-r": fzf_history'

function fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

  if [ "x$pid" != "x" ]
  then
    echo $pid | xargs kill -${1:-9}
  fi
}

# prompt                                                                                                                        
case "$TERM" in
    xterm|xterm-color|*-256color|screen) color_prompt=yes;;
esac

if [ "$color_prompt" = yes ]; then
    PS1='\[\e[01;32m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\w \$\[\e[00m\] '
else
    PS1='\u@\h:\w\$ '
fi

unset color_prompt

# suppress: it doesn't work well with screen
#if [[ -d /usr/share/doc/fzf/examples ]]; then
#    source /usr/share/doc/fzf/examples/key-bindings.bash
#    source /usr/share/doc/fzf/examples/completion.bash
#fi

if [ -f ~/.bashrc-personal ]; then
    source ~/.bashrc-personal
fi

# remove duplicated path
export PATH=$(printf %s "$PATH" | awk -v RS=: -v ORS=: '!arr[$0]++' | sed -e "s/:$//")

# zoxide
eval "$(zoxide init bash)"

cd ~
