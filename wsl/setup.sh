#!/bin/bash

apt-get update \
&& apt-get upgrade\
&& apt-get install -y software-properties-common \
&& apt-get install -y jq git unzip tmux bash-completion zsh gcc make exa ripgrep zoxide
# for more recent version of neovim
wget -O /usr/bin/nvim-linux64.tar.gz https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz
tar -xv -C /usr/bin/ -f /usr/bin/nvim-linux64.tar.gz
ln -fs /usr/bin/nvim-linux64/bin/nvim /usr/bin/nvim
ln -fs /usr/bin/nvim-linux64/bin/nvim /usr/local/bin/nvim

CURRENT_DIR=$(pwd)
user=""

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

curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash --yes


cp ../confs/wsl.conf /etc/wsl.conf
chmod 0764 /etc/wsl.conf
chown root:root /etc/wsl.conf
sed -i "s/{{user}}/$user/g" /etc/wsl.conf

# 🚨 Switch to user
# Find user who is running as sudo
USER_HOME=$(getent passwd $user | cut -d: -f6)
CONFIGDIR="$USER_HOME/.config"
[ -d $CONFIGDIR ] || mkdir $CONFIGDIR
git clone --depth=1 --filter=blob:none https://github.com/tmux-plugins/tpm $USER_HOME/.tmux/plugins/tpm 
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