FROM rust:latest

# Install base utils
RUN apt-get update
RUN apt-get install -y \
  curl \
  psmisc

# Install Node.js
RUN curl -fsSL "https://deb.nodesource.com/setup_18.x" | bash -
RUN apt-get install -y nodejs

# Easilly use any nodejs package manager
RUN corepack enable

# Install Tarpaulin
RUN cargo install cargo-tarpaulin

# Install Tauri dependencies
# https://tauri.app/v1/guides/getting-started/prerequisites#setting-up-linux
RUN apt-get install -y \
  libwebkit2gtk-4.0-dev \
  build-essential \
  curl \
  wget \
  libssl-dev \
  libgtk-3-dev \
  libayatana-appindicator3-dev \
  librsvg2-dev 

# Install tauri-driver dependencies
RUN apt-get install -y \
  webkit2gtk-4.0-dev \
  webkit2gtk-driver \
  xvfb \
  x11vnc

# Install tauri-driver
# https://tauri.app/v1/guides/testing/webdriver/introduction#system-dependencies
RUN cargo install tauri-driver
COPY ../tauri/x.start.sh /x.start.sh
RUN chmod +x /x.start.sh

RUN apt install -y gcc make jq git unzip tmux zsh ripgrep fzf wget pass sudo
RUN wget -O /usr/bin/nvim-linux64.tar.gz https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz \
    && tar -xv -C /usr/bin/ -f /usr/bin/nvim-linux64.tar.gz \
    && ln -fs /usr/bin/nvim-linux64/bin/nvim /usr/bin/nvim \
    && ln -fs /usr/bin/nvim-linux64/bin/nvim /usr/local/bin/nvim \
    && rm /usr/bin/nvim-linux64.tar.gz

# --gecos skip interactive part
RUN mkdir -p /etc/sudoers.d \
    && adduser --disabled-password --gecos "" --shell /bin/zsh vscode \
    && usermod -aG sudo vscode \
    && echo "vscode     ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode \
    && chsh -s /bin/zsh vscode

#RUN echo "auth       [success=ignore default=1] pam_succeed_if.so user = vscode" >> /etc/pam.d/su
#RUN echo "auth       sufficient   pam_succeed_if.so use_uid user ingroup vscode" >> /etc/pam.d/su

# change user's UID to match the host
# This is important if we want to use the ssh-agent
ARG UID=1000
ENV SSH_AUTH_SOCK=/ssh-agent
RUN /usr/sbin/groupmod -g ${UID} vscode \
    && /usr/sbin/usermod -u ${UID} -g ${UID} vscode \
    # add vscode to root group
    && /usr/sbin/usermod -G 0 vscode
RUN chown -R ${UID}:${UID} /home/vscode
RUN chsh -s /bin/zsh vscode

#USER ${UID}:${UID}
WORKDIR /home/vscode
RUN su -c "curl -sS https://raw.githubusercontent.com/igorovic/wsl-init/main/wsl/setup.sh | /bin/bash" vscode
USER vscode
CMD ["/bin/zsh"]