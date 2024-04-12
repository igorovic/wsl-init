function install_node(){
    nvm install --lts \
    && nvm use --lts \
    && npm i -g pnpm \ 
    # reset pnpm global store in container - to avoid conflicts with the host's store
    pnpm config set store-dir "${$(pnpm config get store-dir):-$HOME/.pnpm-store}" --global
}

install_node
#if [[ ! $(which node) == 0 ]]; then
#    if [[ $(nvm list default) == 3 ]]; then
#        install_node
#    fi
#fi