!/usr/bin/bash

apt install \
  git \
  screen \n
  gpg \
  vim emacs \
  fzf bat ripgrep \
  python3 \
  ncal

# media
apt install \
  imagemagick jp2a \
  ffmpeg

# network
apt install \
  curl wget w3m \
  fetchmail procmail neomutt \
  rsync

# documentation
apt install \
  texlive texlive-latex-extra texlive-fonts-extra texlive-extra-utils texlive-lang-japanese \
  fonts-noto-cjk fonts-mplus \
  fonts-ipafont-gothic fonts-ipafont-mincho \
  fonts-ipaexfont-gothic fonts-ipaexfont-mincho \
  fonts-ipamj-mincho \
  fonts-vlgothic fonts-migmix

# jokes
apt install \
  sysvbanner cmatrix

echo Done.
