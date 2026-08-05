test -f ~/.profile && . ~/.profile
test -f ~/.bashrc && . ~/.bashrc

test -f ${HOME}/.cargo/env && . "${HOME}/.cargo/env"
