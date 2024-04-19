
if $(command -v rg > /dev/null 2>&1); then 
    alias grep="rg"
fi
# avoid to break ls command if eza fails installing
if $(command -v eza > /dev/null 2>&1); then 
    alias ls="eza -lh"
    alias ll="eza -lh --icons=always --color=auto --smart-group --no-time --git --no-filesize --no-user --no-permissions"

fi
alias tmux="tmux -2u"
alias vim="nvim"
#alias vi="nvim"
git config --global core.editor nvim
eval "$(starship init zsh)"
# check if zoxide exist to avoid breaking cd command
if $(command -v zoxide > /dev/null 2>&1); then 
    eval "$(zoxide init --cmd cd zsh)"
else
   echo 'zoxide is not installed' 
fi

# do not override with empty values
if [[ ! -z "$GIT_USER_EMAIL" && -z "$(git config user.email)" ]]; then
    git config --global user.email "$GIT_USER_EMAIL"
fi
if [[ ! -z "$GIT_USER_NAME" && -z "$(git config user.name)" ]]; then
    git config --global user.name "$GIT_USER_NAME"
fi
if [[ ! -z "$GIT_USERNAME" && -z "$(git config user.namename)" ]]; then
    # user.username is maybe not a standard git config option - however we can use it for gitpass custom zfunction
    git config --global user.username "$GIT_USERNAME"
fi


if [[ -d "$HOME/.zsh/zsh-autosuggestions" ]]; then
    source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
    bindkey '^ ' autosuggest-accept
fi

# function found online
() {
    # add our local functions dir to the fpath
    local funcs=$HOME/.zfunc

    # FPATH is already tied to fpath, but this adds
    # a uniqueness constraint to prevent duplicate entries
    typeset -TUg +x FPATH=$funcs:$FPATH fpath
    
    # Now autoload them
    if [[ -d $funcs ]]; then
        # use sed to remove .zsh extension if it exists
        #autoload ${=$(cd "$funcs" && echo * | sed -e ':a' -e 's/.zsh//g; ta')}
        autoload ${=$(cd "$funcs" && echo *)}
    fi
}


