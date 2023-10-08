alias apt='sudo apt'
alias e=emacs
alias g=git
alias ga='git add'
alias gc='git commit -m'
alias gd='git diff --name-only'
alias gl='git log --oneline --decorate --graph --branches --tags --remotes --all'
alias gp='git push'
alias gps='git push'
alias gpl='git pull'
alias gs='git status'
alias grep='grep --color=auto'
alias h=history
alias l=ls
alias la='ls -la'
alias ll='ls -l'
alias ls='ls -F --color=auto --show-control-chars'
alias m=neomutt
alias md=mkdir
alias myip='curl ipinfo.io/ip'
alias p='python'
alias s='[[ -v STY ]] || screen'
alias sr='[[ -v STY ]] || screen -r'
alias sl='ls -F --color=auto --show-control-chars'
alias u='cd ..'
alias v=vi
alias wget='wget -c'
alias ..='cd ..'
alias .2='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'

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
