set -e

install_node(){
    /usr/bin/bash -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
    nvm install --lts 
    nvm use --lts 
    npm i -g pnpm  
    # reset pnpm global store in container - to avoid conflicts with the host's store
    pnpm config set store-dir "${$(pnpm config get store-dir):-$HOME/.pnpm-store}" --global
}

install_node
#if [[ ! $(which node) == 0 ]]; then
#    if [[ $(nvm list default) == 3 ]]; then
#        install_node
#    fi
#fi

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm