alias ll="ls -lha"
alias tmux="tmux -2u"
alias vim="nvim"
#alias vi="nvim"
alias apb="ansible-playbook"
git config --global core.editor nvim
eval "$(starship init zsh)"

git config --global user.email "$GIT_USER_EMAIL"
git config --global user.name "$GIT_USER_NAME"