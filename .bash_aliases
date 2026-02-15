alias a='sudo apt'
alias ai='sudo apt install'
alias aud='sudo apt update'
alias aug='sudo apt upgrade'
# b is used for pomera 'battery' command
alias b='newbooks.py -t'
# c is used for a shell function
alias c-='cd -'
# d
# e
alias e=emacs
alias ef='emacs "$(fzf)"'
alias f=fzf-rg
# g
alias g=git
alias ga='git add'
alias gc='git commit -m'
alias gd='git difftool'
alias gl='git log --oneline --decorate --graph --branches --tags --remotes --all'
alias gm='git mv'
alias gp='git push'
alias gps='git push'
alias gpl='git pull'
alias gr='git rm'
alias gs='git status'
alias grep='grep --color=auto'
# h
alias h='history | fzf'
# i
alias i='curl ipinfo.io/ip ; echo'
# j
# k
# l
alias l=ls
alias la='ls -la'
alias ll='ls -l'
alias lla='ls -la'
alias ltr='ls -ltr'
alias lltr='ls -ltr'
alias ls='ls -F --color=auto --show-control-chars'
alias lt='ls --full-time --time-style="+%Y-%m-%d %H:%M:%S" $1 | grep $(date "+%F")'
alias le=less
# m
alias m=neomutt
alias md=mkdir
alias more=batcat
alias mplayer='mplayer -af volnorm'
alias mf='mplayer -af volnorm $(fzf)'
alias mr='mpg123 -z'
# n
alias ncd='cd "`ls -td */ | head -1`"'
alias n=newsboat
# o
alias o='onedrive --synchronize'
alias p='python'
# p
alias path='echo $PATH | tr ":" "\n" | sort'
# q
alias q=qalc
# r
# s
alias s='[[ -v STY ]] || screen -R'
alias sr='[[ -v STY ]] || screen -r'
alias sl='ls -F --color=auto --show-control-chars'
# t
alias t=train.py
# u
alias u='cd ..'
# v
alias v=vim
alias vi=vim
alias vf='vim "$(fzf)"'
# w
alias w='weather.py'
alias wget='wget -c'
# x is used for explorer
# y
alias yt=yt-dlp
alias yta='yt-dlp -x --audio-format mp3'
# z
alias ..='cd ..'
alias .2='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias _='source ~/.bashrc'

if [[ $(uname -o) = 'GNU/Linux' ]]; then
    alias python=python3
    alias md2x='python3 ~/share/md2x/md2x.py'
fi

if [[ $(uname -o) == 'Msys' ]]; then
    alias x='explorer .'
fi

if [[ $(hostname) == 'pomera' ]]; then
    alias b=battery
    alias fbterm='LANG=ja_JP.UTF-8 /usr/bin/fbterm -- uim-fep'
    alias ft='LANG=ja_JP.UTF-8 /usr/bin/fbterm -- uim-fep'
    alias won='sudo /opt/bin/wifi_switch on'
    alias woff='sudo /opt/bin/wifi_switch off'
fi
