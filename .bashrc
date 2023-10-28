# Don't do anything, when not running interactively. 
case $- in
    *i*) ;;
      *) return;;
esac

export LANG=C.UTF-8
export LC_ALL=C.UTF-8

export HISTCONTROL=ignoredups:ignorespace:erasedups
export HISTIGNORE='?:??:???:exit'

stty stop undef

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -d /opt/bin ]; then
    PATH=$PATH:/opt/bin
fi
PATH=$PATH:$HOME/bin

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

cd ~
