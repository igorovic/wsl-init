#!/bin/bash
# uncomment next line for debug
#set -x

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
GITHUB_USERNAME="igorovic"
DOTFILES_REPO="https://github.com/$GITHUB_USERNAME/dotfiles.git"



command_exists(){
  command -v "$@" >/dev/null 2>&1
}

user_can_sudo() {
  # Check if sudo is installed
  command_exists sudo || return 1
  # Termux can't run sudo, so we can detect it and exit the function early.
  case "$PREFIX" in
  *com.termux*) return 1 ;;
  esac
  # The following command has 3 parts:
  #
  # 1. Run `sudo` with `-v`. Does the following:
  #    • with privilege: asks for a password immediately.
  #    • without privilege: exits with error code 1 and prints the message:
  #      Sorry, user <username> may not run sudo on <hostname>
  #
  # 2. Pass `-n` to `sudo` to tell it to not ask for a password. If the
  #    password is not required, the command will finish with exit code 0.
  #    If one is required, sudo will exit with error code 1 and print the
  #    message:
  #    sudo: a password is required
  #
  # 3. Check for the words "may not run sudo" in the output to really tell
  #    whether the user has privileges or not. For that we have to make sure
  #    to run `sudo` in the default locale (with `LANG=`) so that the message
  #    stays consistent regardless of the user's locale.
  #
  ! LANG= sudo -n -v 2>&1 | grep -q "may not run sudo"
}

function with_sudo(){
  if user_can_sudo; then
    # save the first argument
    local f=$1
    # check if first arg is a shell function
    if [[ $(type -t "$f") == 'function' ]]; then
      FUNC=$(declare -f $1)
      # shift to keep remaining args since first arg is the function/command to execute
      shift
      sudo bash -c "$FUNC; $f $@"
    else
      sudo $@
    fi
  else
    $@
  fi
}

function enable_nopass_sudo(){
  echo "$USER     ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER
}

install_zsh59(){
  # verify if we need to install latest
  if command_exists zsh; then
    if [[ $(zsh --version | sed -n 's/.*\(5.9\).*/\1/p') == '5.9' ]]; then
      # already the desired version
      return
    fi
  fi
  local tmp="$(mktemp -d)"
  wget -O "$tmp/zsh-5.9.tar.xz" https://www.zsh.org/pub/zsh-5.9.tar.xz
  cd "$tmp/"
  tar xvf "$tmp/zsh-5.9.tar.xz"
  cd zsh-5.9
  # install required dependencies for compilation
  with_sudo apt install -y libncurses-dev
  /bin/sh -c ./configure && make && with_sudo make install

}

install_chezmoi(){
  sh -c "$(curl -fsLS get.chezmoi.io)"
}

install_deps(){
  if [[ -f "/.dockerenv" ]]; then
    printf '%s App installation skipped %s\n' $FMT_RED $FMT_RESET
    printf '%s Advised to install apps during container build %s\n' $FMT_RED $FMT_RESET
  else
    apt-get update -y
    apt-get upgrade -y
    apt-get install -y software-properties-common gcc make 
    apt-get install -y jq git unzip tmux zsh ripgrep fzf wget
    # for more recent version of neovim
    wget -O /usr/bin/nvim-linux64.tar.gz https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz
    tar -xv -C /usr/bin/ -f /usr/bin/nvim-linux64.tar.gz
    ln -fs /usr/bin/nvim-linux64/bin/nvim /usr/bin/nvim
    ln -fs /usr/bin/nvim-linux64/bin/nvim /usr/local/bin/nvim
    rm /usr/bin/nvim-linux64.tar.gz
  fi
}

# Utilities
# join_paths() {
#   # source: https://www.baeldung.com/linux/concatenate-strings-to-build-path#a-generic-solution-that-handles-special-cases
#    base_path=${1}
#    sub_path=${2}
#    full_path="${base_path:+$base_path/}$sub_path"
#    full_path=$(realpath ${full_path})
#    echo $full_path
# }


# REPO_CLONE="$(mktemp -d)/wsl-init"
# clone_repo(){
#   if [[ -d "$REPO_CLONE" ]]; then
#     echo "remove dir $REPO_CLONE"
#     with_sudo rm -rf "$REPO_CLONE"
#   fi
#   echo "cloning repo"
#   git clone --depth=1 --filter=blob:none --single-branch "$GITURL.git" $REPO_CLONE
# }

# clean(){
#   with_sudo rm -rf "$REPO_CLONE"
# }
# update_configs(){
#   # .zshrc
#   wget -O "$HOME/.zshrc" "$GITRAWURL/main/confs/zshrc.template"
#   # .vimrc
#   wget -O "$HOME/.vimrc" "$GITRAWURL/main/confs/vimrc"
#   # .tmux.conf
#   wget -O "$HOME/.tmux.conf" "$GITRAWURL/main/confs/.tmux.conf"
#   # .zprofile
#   wget -O "$HOME/.zprofile" "$GITRAWURL/main/confs/.zprofile"
#   # .ssh-config
#   mkdir -p "$HOME/.ssh"
#   wget -O "$HOME/.ssh/config" "$GITRAWURL/main/confs/ssh-config"
#   # starship.toml
#   mkdir -p "$HOME/.config"
#   wget -O "$HOME/.config/starship.toml" "$GITRAWURL/main/confs/starship.toml"
# }

# update_custom_functions(){
#   clone_repo 
#   funcs="$HOME/.zfunc"
#   cp -rf "$REPO_CLONE/confs/.zfunc" "$HOME/"
#   if [[ $1 == '-u' ]]; then
#     printf '%s You should freload your functions %s\n' $FMT_YELLOW $FMT_RESET
#   fi
# }

uninstall_ohmyzsh(){
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    rm -rf "$HOME/.oh-my-zsh" 
  fi
}

setup_wsl(){
  # wsl.conf
  if [[ -z $WSL_DISTRO_NAME ]]; then
    printf '%s SKIP: Not WSL %s\n' $FMT_YELLOW $FMT_RESET
    return
  fi
  wget -N -O "/etc/wsl.conf" "$GITRAWURL/main/wsl/wsl.conf"
  chmod 0764 /etc/wsl.conf
  chown root:root /etc/wsl.conf
  sed -i "s/{{user}}/$USER/g" /etc/wsl.conf
}

download_tmux_plugins(){
  CONFIGDIR="$HOME/.config"
  [ -d $CONFIGDIR ] || mkdir -p $CONFIGDIR
  git clone --depth=1 --filter=blob:none https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm > /dev/null 2>/dev/null
  local _install_script="$HOME/.tmux/plugins/tpm/bin/install_plugins"
  if [[ -f $_install_script ]]; then
    /bin/bash $_install_script
  else
    printf '%s tmux plufin filed missing install_script %s\n' $FMT_RED $FMT_RESET
  fi
}

# update_nvim_config(){
#   if [[ ! -d "$REPO_CLONE" ]]; then
#     echo "cloning repo"
#     clone_repo
#   fi
#   # avoid creating a useless subdir
#   if [[ -d "$HOME/.config/nvim" ]]; then
#     cp -rf "$REPO_CLONE/nvim" "$HOME/.config"
#   else
#     cp -rf "$REPO_CLONE/nvim" "$HOME/.config/nvim"
#   fi
# }

install_starship(){
  set -u
  # set PREFIX to avoid bug in install-script
  PREFIX=''
  local _tmp_dir
  _tmp_dir="$(mktemp -d)"
  wget -O "$_tmp_dir/starship-install.sh" https://starship.rs/install.sh
  with_sudo /usr/bin/sh "$_tmp_dir/starship-install.sh" --yes 
  rm "$_tmp_dir/starship-install.sh"
}

install_zoxide(){
  # zoxide is installed in $HOME/.local/bin - make sure to set your PATH accordingly
  set -u
  local _tmp_dir
  _tmp_dir="$(mktemp -d)"
  wget -O "$_tmp_dir/zoxide-install.sh" https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh 
  /bin/bash "$_tmp_dir/zoxide-install.sh"
}

install_zsh_autosuggestions(){
  PREFIX=''
  [[ ! -d "$HOME/.zsh" ]] && mkdir -p "$HOME/.zsh"
  git clone https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.zsh/zsh-autosuggestions"
  
}

install_eza(){
  # requires sudo
  # https://github.com/eza-community/eza
  mkdir -p /etc/apt/keyrings
  if [[ ! -f "/etc/apt/keyrings/gierens.gpg" ]]; then
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list
    chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    apt update -y
  fi
  if ! command_exists eza; then
    apt install -y eza
  fi
}

apply_chezmoi(){
  cd $HOME
  chezmoi init --apply "$DOTFILES_REPO" 
}

customize(){
  #download_tmux_plugins
  #update_nvim_config
  #update_custom_functions
  install_zsh_autosuggestions
  install_chezmoi
  uninstall_ohmyzsh
  # zsh history setup
  mkdir -p "$HOME/.cache/zsh"
  touch "$HOME/.cache/zsh/history"
  chmod -R 0600 "$HOME/.cache/zsh"
  chown -R $USER:$USER "$HOME/.cache/zsh"
  apply_chezmoi
}

install_binaries(){
  with_sudo install_deps
  uninstall_ohmyzsh
  install_starship
  install_zoxide
  with_sudo install_eza
  with_sudo setup_wsl
  install_zsh59
}

show_outro(){
  printf '\n\n -----------------------------------------\n\n'
  echo "Create a new user or login and apply customization"
  echo "Example Ubuntu: "
  echo "  adduser --gecos --shell \$(which zsh) USER"
  printf '\n\n'
}



# The following code is in braces to ensure that the script does not run until it is
# downloaded completely.
{
  UPDATEONLY=false
  # Ability to run only updates
  while getopts "u" opt; do
    case $opt in
      u)
        echo "UPDATES ONLY"
        #update_configs
        #update_nvim_config
        #update_custom_functions -u
        #clean
        UPDATEONLY=true
        break
      ;;
      ?|*)
      ;;
    esac
  done

  if [[ "$UPDATEONLY" = false ]]; then
    install_binaries
  fi

  continue_as_root='N'
  if [[ "root" == "$(id -u -n)" ]]; then
    printf 'Your are running as %s %s %s\n' $FMT_RED 'root' $FMT_RESET
    printf 'This will install customizations for root user!\n'
    read -e -p 'Continue as 'root'? [y/N]' continue_as_root
    case $continue_as_root in
      y|Y)
        echo "continue customization"
        customize
        ;;
      n|N)
        show_outro
        ;;
      ?|*)
        show_outro
        ;;
    esac
  else
    customize
  fi

  #clean
}