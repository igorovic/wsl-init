## WSL setup 

Download the desired tarball here `https://cloud-images.ubuntu.com/wsl/` 

```powershell
wsl.exe --import <Distribution Name> <Install Folder> <.TAR.GZ File Path>
```

In your WSL git clone this repo and execute the initial script. 

```bash
/bin/bash setup.sh
```

## Docker container setup

### Build 

```bash
# UID is necessary to grant access to ssh-agent socket
docker build -t dyve/ubuntu-dev-base:latest --progress plain --build-arg "UID=${UID}" --file ./Docker/Dockerfile.ubuntu-dev-base .
```

### Start container 

```bash
# FIRST RUN: container does not exists -- this will create the container
docker run -it --name ubuntu-dev -p 3000-3020:3000-3020 \
--mount type=bind,source=./,target=/home/vscode/dev \
-e SSH_AUTH_SOCK=/ssh-agent -v "${SSH_AUTH_SOCK}:/ssh-agent" \
-e GIT_USER_EMAIL="$(git config user.email)" \
-e GIT_USER_NAME="$(git config user.name)" \
dyve/ubuntu-dev-base:latest
# if container already exists 
docker start -ia ubuntu-dev
```
 
## Tmux

First time you start tmux `tpm` plugin is not automatically installed. You need to 
- open tmux `tmux`
- Use `<leader>I` which sould be `Ctrl-s I` - this will install the plugin

## Neovim config

The nvim lua files go inside `~/.config/nvim/` 

## Terminal Setup

### Nerd fonts

For nerd fonts you need to install the patched versions on your host. (Not in the container or WSL)

Then configure the nerd font in your terminal. This step depends on your terminal app. 

### Mouse reporting

You need to enable mouse reporting in your terminal if you want to resize tmux panels with your mouse.


## VIM healthcheck

Show usefull information about your environment.

```vimcmd
:checkhealth
```

### Colors issues in Tmux

Some nvim plugin uses `TERM` environment variable so I had to manually define it inside a Docker container to fix colors issues.

```bash
export TERM=xterm-256color
```

The following tmux options where not sufficient. 

```bash
# ~/.tmux.conf
set -g default-terminal "screen-256color"
set-option -sa terminal-features ',xterm-256color:RGB'
```


## Misc Notes

### Ansible linter

- Files must have the `*.ansible.yaml` for the linter to activate. Otherwise it will be considered as a simple `.yaml` file. 
- Files inside `**/tasks/*` folder are recognized as `tasks definitions` by the ansible linter. 
- Files inside `playbooks/*` are recognized as `playbooks` 
