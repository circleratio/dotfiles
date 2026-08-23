# setup.sh

# base package
if [ -f "${HOME}/.bashrc" ] && [ ! -L "${HOME}/.bashrc" ] && [ ! -e "${HOME}/.bashrc.bak" ]; then
    mv "${HOME}/.bashrc" "${HOME}/.bashrc.bak"
fi

stow -v -t ~ base

mkdir -p ~/bin
stow -v -t ~/bin bin

# editor
#stow -v -t ~ emacs
#stow -v -t ~ vim
