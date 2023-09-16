alias apt='sudo apt'
alias b='bc -l'
alias e=emacs
alias fbterm='LANG=ja_JP.UTF-8 fbterm -- uim-fep'
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
alias l='ls -F --color=auto --show-control-chars'
alias la='ls -la'
alias ll='clear && ls -l'
alias m=neomutt
alias md=mkdir
alias myip='curl ipinfo.io/ip'
alias p='ps aux'
alias s='[[ -v STY ]] || screen'
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

if [ `whoami` = 'pomera' ]; then
    alias d='vi /mnt/sd/02\ 日記.txt'
    alias n='vi ~/doc/DADC/00\ note.txt'
fi
