FROM mcr.microsoft.com/devcontainers/base:ubuntu22.04 as build 

RUN apt update \
    && apt upgrade -y 

RUN apt install -y gcc make git unzip wget ninja-build gettext cmake unzip curl build-essential libncurses-dev

FROM build as neovim
WORKDIR /neovim
RUN git clone --depth 1 --branch stable https://github.com/neovim/neovim.git && \
    cd neovim && git checkout stable && make CMAKE_BUILD_TYPE=Release

FROM build as zsh
WORKDIR /zsh
# isntall zsh 5.9
RUN wget -O "./zsh-5.9.tar.xz" https://www.zsh.org/pub/zsh-5.9.tar.xz \
    && tar xvf zsh-5.9.tar.xz && cd zsh-5.9 \
    && ./configure --with-tcsetpgrp && make

FROM build as misc
RUN mkdir /misc
WORKDIR /misc
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ./fzf \
    && wget -O /misc/starship-install.sh https://starship.rs/install.sh \
    && wget -O /misc/zoxide-install.sh https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh \
    && curl https://zyedidia.github.io/eget.sh | /bin/sh \
    && ./eget -a .deb gopasspw/git-credential-gopass

FROM mcr.microsoft.com/devcontainers/base:ubuntu22.04 as base

RUN apt update \
    && apt upgrade -y 

# libncruses-dev: for zsh instal
# cmake ninja-build: for neovim install
RUN apt install -y gcc make cmake ninja-build jq git unzip tmux zsh ripgrep wget libncurses-dev
RUN --mount=target=/neovim,source=/neovim,from=neovim,readwrite cd /neovim/neovim && make install
RUN --mount=target=/zsh,source=/zsh,from=zsh,readwrite cd /zsh/zsh-5.9 && make install
RUN --mount=target=/misc,source=/misc,from=misc,readwrite /usr/bin/sh /misc/starship-install.sh --yes \
    && /bin/bash /misc/zoxide-install.sh && dpkg -i /misc/git-credential-gopass*.deb
RUN mkdir -p /etc/apt/keyings \ 
    && wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list \
    && chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list \
    && apt update -y && apt install eza
RUN rm -rf "/root/.oh-my-zsh" 

# clean some 
RUN apt autoremove -y libncurses-dev ninja-build cmake 
RUN --mount=target=/misc,source=/misc,from=misc,readwrite /misc/fzf/install --all --no-bash --no-fish
RUN git clone --depth=1 --filter=blob:none https://github.com/tmux-plugins/tpm /home/vscode/.tmux/plugins/tpm >/dev/null 2>/dev/null \
    # temporarly enable plugin manager with TMUX_PLUGIN_MANAGER_PATH
    && TMUX_PLUGIN_MANAGER_PATH=/home/vscode/.tmux/plugins /bin/bash /home/vscode/.tmux/plugins/tpm/bin/install_plugins
RUN mkdir -p /home/vscode/.config \
    && mkdir -p /home/vscode/.zsh \
    && mkdir -p /home/vscode/.cache/zsh && touch /home/vscode/.cache/zsh/history 
RUN chmod 0700 /home/vscode/.cache && chmod 0700 /home/vscode/.cache/zsh \
    && chmod 0600 /home/vscode/.cache/zsh/history
    
RUN git clone https://github.com/zsh-users/zsh-autosuggestions.git /home/vscode/.zsh/zsh-autosuggestions 
RUN /bin/sh -c "$(curl -fsLS get.chezmoi.io)"

# change user's UID to match the host
# This is important if we want to use the ssh-agent
ARG UID=1000
ENV SSH_AUTH_SOCK=/ssh-agent
RUN /usr/sbin/groupmod -g ${UID} vscode \
    && /usr/sbin/usermod -u ${UID} -g ${UID} vscode
RUN sudo chown -R ${UID}:${UID} /home/vscode
RUN chsh -s /bin/zsh vscode

USER vscode
WORKDIR /home/vscode
# reinstall zoxide as vscode
RUN --mount=target=/misc,source=/misc,from=misc,readwrite /bin/bash /misc/zoxide-install.sh 
# chezmoi needs full path at this stage since .zshrc and PATH are not properly configured yet
RUN  /usr/bin/chezmoi init --apply igorovic
# install tmux plugins
RUN /home/vscode/.tmux/plugins/tpm/bin/install_plugins 
RUN rm -rf /home/vscode/.oh-my-zsh
# download and install nvim plugins
RUN nvim --headless "+Lazy install" "+Lazy update" "+Lazy sync" +qa

# #RUN curl -sS https://raw.githubusercontent.com/igorovic/wsl-init/main/wsl/setup.sh | /bin/bash
CMD [ "/bin/zsh" ]