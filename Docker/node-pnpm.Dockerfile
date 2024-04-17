FROM dyve/ubuntu-dev-base:latest

# Update .dotfiles configs and custom functions
RUN curl -sS https://raw.githubusercontent.com/igorovic/wsl-init/main/wsl/setup.sh | /bin/bash -s -- -u
RUN /bin/zsh ~/.zfunc/nodejs-dev.zsh
WORKDIR /home/vscode/dev

RUN pnpm install
    
