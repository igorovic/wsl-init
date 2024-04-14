
FROM dyve/ubuntu-dev-base:latest

USER root
RUN apt update \
    && apt upgrade -y 

USER vscode
WORKDIR /home/vscode

CMD [ "/bin/zsh" ]