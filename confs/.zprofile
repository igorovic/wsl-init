
if $(command -v rg > /dev/null 2>&1); then 
    alias grep="rg"
fi
# avoid to break ls command if eza fails installing
if $(command -v eza > /dev/null 2>&1); then 
    alias ls="eza"
fi
alias ll="ls -lha"
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

git config --global user.email "$GIT_USER_EMAIL"
git config --global user.name "$GIT_USER_NAME"

if [[ -d "$HOME/.zsh/zsh-autosuggestions" ]]; then
    source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
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


