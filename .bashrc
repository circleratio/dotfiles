export HISTCONTROL=ignoredups:ignorespace:erasedups

stty stop undef

alias md=mkdir

function mcd() {
    mkdir "$1"
    cd "$1"
}

function ncd() {
    cd "`ls -td */ | head -1`"
}

function hi() {
    if [ -f ~/bin/update-workspace ]; then
        sh ~/bin/update-workspace
    fi
    cd ~/work/ws
}

function bye() {
    if [ -f ~/bin/commit-workspace ]; then
        sh ~/bin/commit-workspace
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
