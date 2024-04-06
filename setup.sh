#!/bin/bash

install_deps(){
    apt update && apt upgrade -y && apt install software-properties-common wget curl git neovim locales -y \
    && apt-add-repository ppa:ansible/ansible -y \
    && mkdir -p -m 755 /etc/apt/keyrings \
    && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt update && apt install yamllint ansible-lint ansible jq unzip gh -y 
}

display_help() {
    echo "---------------------------------------" >&2
    echo "run playbooks with ansible-playbook"
    echo
    echo "example:"
    echo "ansible-playbook -i localhost playbooks/wsl-setup.yaml "
    echo
    # echo some stuff here for the -a or --add-options 
    exit 1
}

editor_nvim(){
    echo "alias vim=\"nvim\"" | tee -a ~/.bashrc \
    && echo "alias vi=\"nvim\"" | tee -a ~/.bashrc \
    && echo "alias ap=\"ansible-playbook\"" | tee -a ~/.bashrc \
    && git config --global core.editor nvim
}

gen_locales(){
    locale-gen en_US.UTF-8
}

# check if sudo exists since it's not available in some docker images
if ! command -v sudo &> /dev/null
then
    install_deps
else
    FUNC=$(declare -f install_deps)
    sudo bash -c "$FUNC; install_deps"
fi
editor_nvim
display_help