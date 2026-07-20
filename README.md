# base package
stow -t ~ base

mkdir -p ~/bin
stow -t ~/bin bin

# editor
stow -t ~ emacs
stow -t ~ vim
