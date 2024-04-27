
FROM dyve/ubuntu-dev-base:latest

USER root
RUN apt update \
    && apt upgrade -y 

USER vscode
WORKDIR /home/vscode

RUN chezmoi update
RUN mkdir -p /home/vscode/.pnpm-store/v3 && mkdir -p /home/vscode/.local/share/pnpm && mkdir -p /home/vscode/.vscode-server
# export SHELL to help pnpm install script to identify shell
RUN export SHELL=/bin/zsh && /bin/zsh ~/.zfunc/nodejs-dev.zsh && mkdir -p /home/vscode/dev && sudo chown -R vscode:vscode /home/vscode/dev
RUN sudo chown -R vscode:vscode /home/vscode/.pnpm-store && sudo chown -R vscode:vscode /home/vscode/.local/share/pnpm \
    && sudo chown -R vscode:vscode /home/vscode/.local/share/pnpm

CMD [ "/bin/zsh" ]