# setup.sh

# base package
stow -v -t ~ base

mkdir -p ~/bin
stow -v -t ~/bin bin

# editor
#stow -v -t ~ emacs
#stow -v -t ~ vim
