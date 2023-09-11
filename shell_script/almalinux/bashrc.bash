#!/usr/bin/env bash

mkdir -p "${HOME}"/.bashrc.d
mkdir -p "${HOME}"/.local/src

tee "${HOME}/.bashrc" &>/dev/null <<EOF
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

pathmunge() {
  case ":\${PATH}:" in
  *:"\$1":*) ;;
  *)
    if [ "\$2" = "after" ]; then
      PATH=\${PATH}:\$1
    else
      PATH=\$1:\${PATH}
    fi
    ;;
  esac
}

# User specific environment
if ! [[ "\${PATH}" =~ \${HOME}/.local/bin:\${HOME}/bin: ]]; then
  PATH="\${HOME}/.local/bin:\${HOME}/bin:\${PATH}"
fi
export PATH

# User-specific aliases and functions
if [ -d ~/.bashrc.d ]; then
  for item in ~/.bashrc.d/*; do
    if [ -f "\${item}" ]; then
      . "\${item}"
    fi
  done
fi

unset item
EOF

[[ -d ${HOME}/.fzf ]] && tee "${HOME}/.bashrc.d/03-fzf" &>/dev/null <<EOF
source ${HOME}/.fzf.bash
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
alias la='ls -lAF':wq

alias clr='clear && tput cup \$LINES'
EOF