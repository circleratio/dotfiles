!/usr/bin/bash
SETUP_USER=tf

apt update

apt install \
  lsb-release \
  screen \
  vim emacs \
  fzf bat ripgrep \
  zoxide \
  ncal

# development
apt install \
  git \
  shellcheck
 
apt install \
  python3 \
  python3-bottle \
  python3-bs4 \
  python3-feedparser \
  python3-isort \
  python3-jinja2 \
  python3-numpy \
  python3-reportlab \
  python3-venv

# media
apt install \
  imagemagick jp2a \
  ffmpeg

# network
apt install \
  gnupg ca-certificates \
  curl wget w3m \
  fetchmail procmail neomutt \
  rsync dnsutils

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
