alias apt='sudo apt'
# c is used for a shell function
alias c~='cd ~'
alias c-='cd -'
alias e=emacs
# f is used for fbterm
alias g=git
alias ga='git add'
alias gc='git commit -m'
alias gd='git diff'
alias gl='git log --oneline --decorate --graph --branches --tags --remotes --all'
alias gp='git push'
alias gps='git push'
alias gpl='git pull'
alias gs='git status'
alias grep='grep --color=auto'
alias h=history
alias i='curl ipinfo.io/ip'
alias l=ls
alias la='ls -la'
alias ll='ls -l'
alias ls='ls -F --color=auto --show-control-chars'
alias lt='ls --full-time --time-style="+%Y-%m-%d %H:%M:%S" $1 | grep $(date "+%F")'
alias more=batcat
alias m=neomutt
alias md=mkdir
alias m='mplayer -af volnorm'
alias ncd='cd "`ls -td */ | head -1`"'
alias p='python'
alias s='[[ -v STY ]] || screen'
alias sr='[[ -v STY ]] || screen -r'
alias sl='ls -F --color=auto --show-control-chars'
alias t=tt_plan
alias u='cd ..'
alias v=vi
alias vf='vi "$(fzf)"'
alias w='curl -4 http://wttr.in/aichi'
alias wget='wget -c'
# x is used for explorer
alias ..='cd ..'
alias .2='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias _='source ~/.bashrc'

if [ `uname -o` = 'GNU/Linux' ]; then
    alias python=python3
    alias md2x='python3 ~/tmp/md2x/md2x.py'
fi

if [ `uname -o` = 'Msys' ]; then
    alias x='explorer .'
fi

if [[ $(hostname) == 'pomera' ]]; then
    alias b=battery
    alias f='LANG=ja_JP.UTF-8 /usr/bin/fbterm -- uim-fep'
    alias fbterm='LANG=ja_JP.UTF-8 /usr/bin/fbterm -- uim-fep'
    alias won='sudo /opt/bin/wifi_switch on'
    alias woff='sudo /opt/bin/wifi_switch off'
fi
