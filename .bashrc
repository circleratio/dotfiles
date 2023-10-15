# Don't do anything, when not running interactively. 
case $- in
    *i*) ;;
      *) return;;
esac

export HISTCONTROL=ignoredups:ignorespace:erasedups

stty stop undef

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -d /opt/bin ]; then
    PATH=$PATH:/opt/bin/:$HOME/bin
else
    PATH=$PATH:$HOME/bin
fi

function mcd() {
    mkdir "$1"
    cd "$1"
}

function ncd() {
    cd "`ls -td */ | head -1`"
}

function hi() {
    if [ -f ~/bin/update-workspace ]; then
        bash ~/bin/update-workspace
    fi
    cd ~/work
}

function bye() {
    if [ -f ~/bin/commit-workspace ]; then
        bash ~/bin/commit-workspace
    fi
    echo "Bye!"
}

function c() {
    BOOKMARK="~/.dir_bookmark"
    BOOKMARK=`eval echo "$BOOKMARK"`
    if [ -z $1 ] ; then
        cat "$BOOKMARK"
    else
        HOME_STR=`echo $HOME | sed -e 's/\//\\\\\//g' `
        RES=`grep ^"$1" ~/.dir_bookmark | sed -e "s/^.*://" -e "s/~/$HOME_STR/"`

        if [ -z $RES ] ; then
            cat "$BOOKMARK"
        else
           cd "$RES"
        fi
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

if [ -f ~/.bashrc-personal ]; then
    source ~/.bashrc-personal
fi

cd ~
