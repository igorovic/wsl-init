#!/bin/bash

apt-get update \
&& apt-get upgrade\
&& apt-get install -y software-properties-common \
&& apt-get install -y jq git unzip tmux bash-completion zsh zplug gcc make
# for more recent version of neovim
wget -O /usr/bin/nvim-linux64.tar.gz https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz
tar -xv -C /usr/bin/ -f /usr/bin/nvim-linux64.tar.gz
ln -fs /usr/bin/nvim-linux64/bin/nvim /usr/bin/nvim
ln -fs /usr/bin/nvim-linux64/bin/nvim /usr/local/bin/nvim
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
else user=${SUDO_USER:-${USER}}; fi

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

TMUX_CONF=$USER_HOME/.tmux.conf
cp ../confs/.tmux.conf $TMUX_CONF
chown $user:$user $TMUX_CONF && chmod 0644 $TMUX_CONF 
ZPROFILE=$USER_HOME/.zprofile
cp ../confs/.zprofile $ZPROFILE
chown $user:$user $ZPROFILE && chmod 0644 $ZPROFILE 

sudo -u $user /usr/bin/bash -c $USER_HOME/.tmux/plugins/tpm/bin/install_plugins
sudo -u $user /usr/bin/bash -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"

# 🚨 check if .zshrc exists or create one
if [ ! -f $HOME/.zprofile ]; then
    cp ../confs/zshrc.zsh-template $USER_HOME/.zshrc
    chown $user:$user $USER_HOME/.zshrc
    chmod 0664 $USER_HOME/.zshrc
fi

echo '
if [ -f $HOME/.zprofile ]; then
    . $HOME/.zprofile
fi
if [ -z "$TMUX" ]
then
    tmux attach -t TMUX || tmux new -s TMUX
fi' >> $USER_HOME/.zshrc

# Install zplug for the right user (not necessary root)
ZPLUG_HOME=$USER_HOME/.zplug
export ZPLUG_HOME=$USER_HOME/.zplug
[ -d .config ] || mkdir -p $ZPLUG_HOME
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
sed -i "1 i\source $ZPLUG_HOME/init.zsh\n" $USER_HOME/.zshrc
chown -R $user:$user $ZPLUG_HOME

## ✨change to the user's home directory for next steps
pushd $USER_HOME/.config
git init -b main
git config --local core.sparseCheckout true
git remote add -f origin https://github.com/igorovic/wsl-init.git
echo "nvim" >> .git/info/sparse-checkout
git pull origin main
chown -R $user:$user $USER_HOME/.config

# mkdir -p -m 0700 ~/.ssh && ssh-keyscan gitlab.com >> ~/.ssh/known_hosts