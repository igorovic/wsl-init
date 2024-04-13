#!/bin/bash
set -e


USER=${USER:-$(id -u -n)}
TMPDIR=${TMPDIR:-'/tmp/'}
HOME="${HOME:-$(getent passwd $USER 2>/dev/null | cut -d: -f6)}"
# macOS does not have getent, but this works even if $HOME is unset
HOME="${HOME:-$(eval echo ~$USER)}"
REPO="igorovic/wsl-init"
# colors
FMT_RED=$(printf '\033[31m')
FMT_GREEN=$(printf '\033[32m')
FMT_YELLOW=$(printf '\033[33m')
FMT_BLUE=$(printf '\033[34m')
FMT_BOLD=$(printf '\033[1m')
FMT_RESET=$(printf '\033[0m')

GITRAWURL="https://raw.githubusercontent.com/$REPO"
GITURL="https://github.com/$REPO"

install_deps(){
  if [[ -f "/.dockerenv" ]]; then
    printf '%s App installation skipped %s\n' $FMT_RED $FMT_RESET
    printf '%s Advised to install apps during container build %s\n' $FMT_RED $FMT_RESET
  else
    sudo apt-get update 
    sudo apt-get upgrade
    sudo apt-get install -y software-properties-common gcc make 
    sudo apt-get install -y jq git unzip tmux zsh exa ripgrep fzf wget pass
    # for more recent version of neovim
    sudo wget -O /usr/bin/nvim-linux64.tar.gz https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz
    sudo tar -xv -C /usr/bin/ -f /usr/bin/nvim-linux64.tar.gz
    sudo ln -fs /usr/bin/nvim-linux64/bin/nvim /usr/bin/nvim
    sudo ln -fs /usr/bin/nvim-linux64/bin/nvim /usr/local/bin/nvim
    # MUST install from source for last version
    #sudo wget -O /tmp/zoxide-install.sh https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh
    #sudo /bin/bash /tmp/zoxide-install.sh
  fi
}

# Utilities
join_paths() {
  # source: https://www.baeldung.com/linux/concatenate-strings-to-build-path#a-generic-solution-that-handles-special-cases
   base_path=${1}
   sub_path=${2}
   full_path="${base_path:+$base_path/}$sub_path"
   full_path=$(realpath ${full_path})
   echo $full_path
}

command_exists(){
    command -v "$@" >/dev/null 2>&1
}

REPO_CLONE=$(join_paths $TMPDIR "/wsl-init")
clone_repo(){
  if [[ -d "$REPO_CLONE" ]]; then
    echo "remove dir $REPO_CLONE"
    sudo rm -rf "$REPO_CLONE"
  fi
  echo "cloning repo"
  git clone --depth=1 --filter=blob:none --single-branch "$GITURL.git" $REPO_CLONE
}

clean(){
  sudo rm -rf "$REPO_CLONE"
}
update_configs(){
  # .zshrc
  wget -O "$HOME/.zshrc" "$GITRAWURL/main/confs/zshrc.template"
  # .vimrc
  wget -O "$HOME/.vimrc" "$GITRAWURL/main/confs/vimrc"
  # .tmux.conf
  wget -O "$HOME/.tmux.conf" "$GITRAWURL/main/confs/.tmux.conf"
  # .zprofile
  wget -O "$HOME/.zprofile" "$GITRAWURL/main/confs/.zprofile"
  # .ssh-config
  wget -O "$HOME/.ssh/config" "$GITRAWURL/main/confs/ssh-config"
  # starship.toml
  wget -O "$HOME/.config/starship.toml" "$GITRAWURL/main/confs/starship.toml"
}

update_custom_functions(){
  clone_repo 
  cp -rf "$REPO_CLONE/confs/.zfunc" "$HOME/.zfunc"
}

uninstall_ohmyzsh(){
  # uninstall_script="$HOME/.oh-my-zsh/tools/uninstall.sh"
  # if [[ -f $uninstall_script ]]; then
  #   #command "$(echo $0)" $uninstall_script
  #   /bin/bash "$uninstall_script" | yes y
  # fi
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    rm -rf "$HOME/.oh-my-zsh" 
  fi
}

setup_wsl(){
  # wsl.conf
  wget -N -O "/etc/wsl.con" "$GITRAWURL/main/confs/wsl.conf"
  chmod 0764 /etc/wsl.conf
  chown root:root /etc/wsl.conf
  sed -i "s/{{user}}/$user/g" /etc/wsl.conf
}

download_tmux_plugins(){
  CONFIGDIR="$HOME/.config"
  [ -d $CONFIGDIR ] || mkdir -p $CONFIGDIR
  git clone --depth=1 --filter=blob:none https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm > /dev/null
}

update_nvim_config(){
  if [[ ! -d "$REPO_CLONE" ]]; then
    echo "cloning repo"
    clone_repo
  fi
  cp -rf "$REPO_CLONE/nvim" "$HOME/.config/nvim"
}

install_starship(){
  wget -O /tmp/starship-install.sh https://starship.rs/install.sh && /usr/bin/sh /tmp/starship-install.sh --yes 
  rm /tmp/starship-install.sh
}

install_deps
continue_as_root='N'
if [[ "root" == "$(id -u -n)" ]]; then
  printf 'Your are running as %s %s %s\n' $FMT_RED 'root' $FMT_RESET
  printf 'This will install customizations for root user!\n'
  printf "Continue as 'root'? [y/N]"
  continue_as_root=$(read -e)
  if [[ $continue_as_root != 'y' || $continue_as_root != 'Y' ]]; then
    exit
  fi
  echo "continue"
fi

uninstall_ohmyzsh
update_configs
update_custom_functions
# download_tmux_plugins
# update_nvim_config
# install_starship
# clean
if [[ -f "/.dockerenv" ]];then
  cat /.dockerenv
fi