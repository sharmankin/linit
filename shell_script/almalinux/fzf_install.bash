#!/usr/bin/env bash

mkdir -p "${HOME}"/.bashrc.d
git clone https://github.com/junegunn/fzf.git "${HOME}/.fzf" -q && \
  "${HOME}/.fzf"/install --all &>/dev/null && \
    tee "${HOME}/.bashrc.d/03-fzf" &>/dev/null <<EOF
source ${HOME}/.fzf.bash
EOF


