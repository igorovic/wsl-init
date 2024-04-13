#!/bin/bash
set -e 

install_deps(){
  sudo -n apt-get update \
  && apt-get upgrade\
  && apt-get install -y software-properties-common gcc make \
  && apt-get install -y jq git unzip tmux bash-completion zsh exa ripgrep  fzf wget pass
  # for more recent version of neovim
  sudo -n wget -O /usr/bin/nvim-linux64.tar.gz https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz
  sudo -n tar -xv -C /usr/bin/ -f /usr/bin/nvim-linux64.tar.gz
  sudo -n ln -fs /usr/bin/nvim-linux64/bin/nvim /usr/bin/nvim
  sudo -n ln -fs /usr/bin/nvim-linux64/bin/nvim /usr/local/bin/nvim
  # -s keeps args to pass to the install script
  #curl -sS https://starship.rs/install.sh | /bin/sh -s -- --yes
  sudo -n wget -O /tmp/starship-install.sh https://starship.rs/install.sh && /usr/bin/sh /tmp/starship-install.sh --yes && rm /tmp/starship-install.sh
  # MUST install from source for last version
  sudo -n curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | /bin/bash
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

USER=${USER:-$(id -u -n)}
TMPDIR=${TMPDIR:-'/tmp/'}
HOME="${HOME:-$(getent passwd $USER 2>/dev/null | cut -d: -f6)}"
# macOS does not have getent, but this works even if $HOME is unset
HOME="${HOME:-$(eval echo ~$USER)}"
REPO="igorovic/wsl-init"
REPO_CLONE=$(join_paths $TMPDIR "/wsl-init")
CURRENT_DIR=$(pwd)
user=""

GITRAWURL="https://raw.githubusercontent.com/$REPO"
GITURL="https://github.com/$REPO"

clone_repo(){
    git clone --depth=1 --filter=blob:none --single-branch "$GITURL.git" $REPO_CLONE
}

clean(){
  rm -rf "$REPO_CLONE"
}
update_configs(){
  # .zshrc
  wget -O "$HOME/.zshrc" "$GITRAWURL/main/confs/zshrc.template"
  # .vimrc
  wget -N -O "$HOME/.vimrc" "$GITRAWURL/main/confs/vimrc"
  # .tmux.conf
  wget -N -O "$HOME/.tmux.conf" "$GITRAWURL/main/confs/.tmux.conf"
  # .zprofile
  wget -N -O "$HOME/.zprofile" "$GITRAWURL/main/confs/.zprofile"
  # .ssh-config
  wget -N -O "$HOME/.ssh/config" "$GITRAWURL/main/confs/ssh-config"
  # starship.toml
  wget -N -O "$HOME/.config/starship.toml" "$GITRAWURL/main/confs/starship.toml"
}

update_custom_functions(){
  clone_repo 
  cp -rf "$REPO_CLONE/confs/.zfunc" "$HOME/.zfunc"
}

uninstall_ohmyzsh(){
  uninstall_script="$HOME/.oh-my-zsh/tools/uninstall.sh"
  if [[ -f $uninstall_script ]]; then
    /bin/bash $uninstall_script
  fi
}

setup_wsl(){
  # wsl.conf
  wget -N -O "/etc/wsl.con" "$GITRAWURL/main/confs/wsl.conf"
  chmod 0764 /etc/wsl.conf
  chown root:root /etc/wsl.conf
  sed -i "s/{{user}}/$user/g" /etc/wsl.conf
}

install_tmux_plugins(){
  CONFIGDIR="$USER_HOME/.config"
  [ -d $CONFIGDIR ] || mkdir $CONFIGDIR
  git clone --depth=1 --filter=blob:none https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm 
  /usr/bin/bash -c $HOME/.tmux/plugins/tpm/bin/install_plugins
}

update_nvim_config(){
  if [[ ! -d "$REPO_CLONE" ]]; then
    clone_repo
  fi
  cp -rf "$REPO_CLONE/nvim" "$HOME/.config/nvim"
}

install_deps
uninstall_ohmyzsh
update_configs
update_custom_functions
install_tmux_plugins
update_nvim_config
clean

main(){
    read -p "Create user (leave empty to skip) : " user

    if [ -n "$user" ]; then 
    echo "create user '$user'"
    read -e -p "with password ? [y/N]" with_password
    with_password=${with_password:-N}
    case $with_password in 
        [Yy]*) sudo adduser --shell /bin/zsh $user;;
        [Nn]*) sudo adduser --disabled-password --shell /bin/zsh $user;;
    esac
    sudo usermod -aG sudo $user
    echo "$user     ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$user
    # 🚨 using the windows config util for ubuntu does not work probably because it does not support zsh shell
    # ubuntu2204.exe config --default-user $user
    chsh -s /bin/zsh $user
    else user=${SUDO_USER:-${USER}}; fi



    cp ../confs/wsl.conf /etc/wsl.conf
    chmod 0764 /etc/wsl.conf
    chown root:root /etc/wsl.conf
    sed -i "s/{{user}}/$user/g" /etc/wsl.conf

    # 🚨 Switch to user
    # Find user who is running as sudo
    USER_HOME=$(getent passwd $user | cut -d: -f6)
    chown -R $user:$user $USER_HOME/.tmux
    wget -O /tmp/starship-install.sh https://starship.rs/install.sh && /usr/bin/sh /tmp/starship-install.sh --yes 


    cp ../confs/ssh-config "$USER_HOME/.ssh/config"
    cp ../confs/vimrc "$USER_HOME/.vimrc"
    cp -rf ../confs/.zfunc "$USER_HOME/.zfunc"
    cp -f ../confs/starship.toml "$USER_HOME/.config/starship.toml"

    TMUX_CONF=$USER_HOME/.tmux.conf
    cp ../confs/.tmux.conf $TMUX_CONF
    chown $user:$user $TMUX_CONF && chmod 0644 $TMUX_CONF 
    ZPROFILE=$USER_HOME/.zprofile
    cp ../confs/.zprofile $ZPROFILE
    chown $user:$user $ZPROFILE && chmod 0644 $ZPROFILE 

    sudo -u $user /usr/bin/bash -c $USER_HOME/.tmux/plugins/tpm/bin/install_plugins
    sudo -u $user /usr/bin/bash -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"


    # Install oh-my-zsh for the right user (not necessary root)
    cp -f ../confs/zshrc.template "$USER_HOME/.zshrc"
    sudo -u $user /usr/bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --keep-zshrc --unattended"
    zoxide init zsh >> "$USER_HOME/.zshrc"


    # ENSURE OWNERSHIP FOR NEW USER
    chown -R $user:$user $USER_HOME


    # mkdir -p -m 0700 ~/.ssh && ssh-keyscan gitlab.com >> ~/.ssh/known_hosts

    echo """
    Restart your wsl 

    wsl --terminale <distro>
    wsl -d <distro> -u <your-new-user>

    In the wsl shell run the following command

    # this
    ubuntu2204.exe config --default-user <your-new-user>

    exit your wsl and terminate again. If you are lucky your user will be used as default. 

    """
}
