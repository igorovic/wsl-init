FROM dyve/ubuntu-dev-base:latest

USER root
RUN apt update \
    && apt upgrade -y 

USER vscode
WORKDIR /home/vscode

RUN chezmoi update
RUN mkdir -p /home/vscode/.vscode-server && sudo chown -R vscode:vscode /home/vscode/.vscode-server
RUN curl -fsSL https://bun.sh/install | bash
