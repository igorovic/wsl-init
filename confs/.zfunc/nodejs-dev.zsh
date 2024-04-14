
check_cmd() {
    command -v "$1" >/dev/null 2>&1
}

PNPM_STORE="$HOME/.pnpm-store/v3"

nvm_config(){
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
}
pnpm_config(){
    # use host's pnpm-store which should be mounted
    pnpm config --global set store-dir "$PNPM_STORE"
}

install_node(){
    if ! check_cmd nvm; then
        /usr/bin/bash -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
        nvm_config
    else
        nvm_config
    fi
    if ! check_cmd node; then
        nvm install --lts 
        nvm use --lts 
    fi
    if ! check_cmd pnpm; then
        npm i -g pnpm
        pnpm_config 
    else
        pnpm_config
    fi
    
    if ! grep -q 'NVM_DIR=' "$HOME/.zshenv"; then
    tee -a "$HOME/.zshenv" > /dev/null << 'EOF'
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
EOF
    fi
}

install_node
# reset pnpm global store in container - to avoid conflicts with the host's store
# need sed since sometime it returns the value 'undefined'
# pnpm config --global set store-dir "${$(pnpm store path | sed 's/undefined//p' ):-$HOME/.pnpm-store}"
#pnpm config --global set store-dire "$HOME/.pnpm-store"
