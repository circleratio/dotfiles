!/usr/bin/bash
SETUP_USER=tf

apt update

apt install \
  lsb-release \
  git \
  screen \
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
  gnupg ca-certificates \
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
  fonts-vlgothic fonts-migmix \
  translate-shell

# jokes
apt install \
  sysvbanner cmatrix

# Docker
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin

usermod -aG docker ${SETUP_USER}

# python modules
pip install python-dateutil

echo Done.
