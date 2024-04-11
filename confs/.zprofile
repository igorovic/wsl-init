alias ll="ls -lha"
alias tmux="tmux -2u"
alias vim="nvim"
#alias vi="nvim"
alias apb="ansible-playbook"
git config --global core.editor nvim
eval "$(starship init zsh)"

git config --global user.email "$GIT_USER_EMAIL"
git config --global user.name "$GIT_USER_NAME"

# function found online
() {
    # add our local functions dir to the fpath
    local funcs=$HOME/.zfunc

    # FPATH is already tied to fpath, but this adds
    # a uniqueness constraint to prevent duplicate entries
    typeset -TUg +x FPATH=$funcs:$FPATH fpath
    
    # Now autoload them
    if [[ -d $funcs ]]; then
        autoload ${=$(cd "$funcs" && echo *)}
    fi
}