#!/usr/bin/env bash

tee "${HOME}"/.bashrc &>/dev/null <<EOF
#!/bin/bash

HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize
[[ -x /usr/bin/lesspipe ]] && eval "\$(SHELL=/bin/sh lesspipe)"

if [[ -d "${HOME}/.bashrc.d" ]]; then
  for item in ${HOME}/.bashrc.d/*; do
    source "\${item}"
  done
fi
EOF

mkdir -p "${HOME}"/.bashrc.d
tee "${HOME}/.bashrc.d/02-aliases" &> /dev/null <<EOF
if [[ -x /usr/bin/dircolors ]]; then
    test -r ~/.dircolors && eval "\$(dircolors -b ~/.dircolors)" || eval "\$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
alias l='ls -1F'
alias ll='ls -lF'
alias la='ls -lAF'
alias clr='clear && tput cud \$LINES'
EOF

[[ -d ${HOME}/.fzf ]] && tee "${HOME}/.bashrc.d/03-fzf" &> /dev/null <<EOF
source $HOME/.fzf.bash
EOF