#!/bin/bash
set -x

USER=${USER:-$(id -u -n)}
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
    sudo rm /usr/bin/nvim-linux64.tar.gz
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

REPO_CLONE="$(mktemp -d)/wsl-init"
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
  mkdir -p "$HOME/.ssh"
  wget -O "$HOME/.ssh/config" "$GITRAWURL/main/confs/ssh-config"
  # starship.toml
  mkdir -p "$HOME/.config"
  wget -O "$HOME/.config/starship.toml" "$GITRAWURL/main/confs/starship.toml"
}

update_custom_functions(){
  clone_repo 
  funcs="$HOME/.zfunc"
  cp -rf "$REPO_CLONE/confs/.zfunc" "$HOME/"
  if [[ $1 == '-u' ]]; then
    if [[ -d $funcs ]]; then
        typeset -TUg +x FPATH=$funcs:$FPATH
        autoload -U "${=$(cd "$funcs" && echo *)}"
    fi
  fi
}

uninstall_ohmyzsh(){
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
  local _install_script="$HOME/.tmux/plugins/tpm/bin/install_plugins"
  if [[ -f $_install_script ]]; then
    /bin/bash $_install_script
  else
    printf '%s tmux plufin filed missing install_script %s\n' $FMT_RED $FMT_RESET
  fi
}

update_nvim_config(){
  if [[ ! -d "$REPO_CLONE" ]]; then
    echo "cloning repo"
    clone_repo
  fi
  cp -rf "$REPO_CLONE/nvim" "$HOME/.config/nvim"
}

install_starship(){
  set -u
  local _tmp_dir
  _tmp_dir="$(mktemp -d)"
  wget -O "$_tmp_dir/starship-install.sh" https://starship.rs/install.sh
  /usr/bin/sh "$_tmp_dir/starship-install.sh" --yes 
  rm "$_tmp_dir/starship-install.sh"
}

install_zoxide(){
  set -u
  local _tmp_dir
  _tmp_dir="$(mktemp -d)"
  wget -O "$_tmp_dir/zoxide-install.sh" https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh 
  /bin/bash "$_tmp_dir/zoxide-install.sh"
}

install_zsh_autosuggestions(){
  [[ ! -d "$HOME/.zsh" ]] && mkdir -p "$HOME/.zsh"
  git clone https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.zsh/zsh-autosuggestions"
  
}


# This is put in braces to ensure that the script does not run until it is
# downloaded completely.
{
  # Ability to run only updates
  for i in "$@" ; do
      if [[ $i == "--update" || $i == "-u" ]] ; then
          echo "UPDATES ONLY"
          update_configs
          update_nvim_config
          update_custom_functions -u
          clean
          break
      fi
  done

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
  download_tmux_plugins
  update_nvim_config
  install_starship
  install_zoxide
  install_zsh_autosuggestions
  clean
}