
check_cmd() {
    command -v "$1" >/dev/null 2>&1
}

install_node(){
    if ! check_cmd nvm; then
        /usr/bin/bash -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
    fi
    if ! check_cmd node; then
        nvm install --lts 
        nvm use --lts 
    fi
    if ! check_cmd pnpm; then
        npm i -g pnpm  
    fi
}

install_node
# reset pnpm global store in container - to avoid conflicts with the host's store
pnpm config set store-dir "${$(pnpm config get store-dir):-$HOME/.pnpm-store}" --global

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm