#!/bin/bash
source "$NVM_DIR/nvm.sh" \
&& nvm install --lts \
&& nvm use --lts \
&& wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which bash)" bash - \
&& source /root/.bashrc