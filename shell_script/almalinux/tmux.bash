#!/usr/bin/env bash
sudo dnf remove tmux -yq

sudo dnf install pkgconf automake autoconf {libevent,ncurses}-devel lnav htop -yq
src_dir="${HOME}"/.local/src/tmux

[[ -d "${src_dir}" ]] && {
  read -r -p "Source directory exists. Continue? " reply
  if [[ ${reply,,} != 'y' ]] && [[ ${reply,,} != 'yes' ]]; then
    exit "${LINENO}"
  fi
}

sudo rm -rf "${src_dir}"

git clone https://github.com/tmux/tmux.git "${src_dir}" && {
  cd "${src_dir}" || exit ${LINENO}
} || exit ${LINENO}

sh autogen.sh
./configure --prefix='/usr' || exit ${LINENO}
make
sudo make install
cd - || exit ${LINENO}

sudo tee /etc/tmux.conf <<EOF
unbind C-b
set -g prefix C-q
bind C-q send-prefix

set -g default-terminal "tmux-256color"

bind -n S-Left select-pane -L
bind -n S-Right select-pane -R
bind -n S-Up select-pane -U
bind -n S-Down select-pane -D

bind -n C-M-Left resize-pane -L
bind -n C-M-Right resize-pane -R
bind -n C-M-Up resize-pane -U
bind -n C-M-Down resize-pane -D

bind -n C-Home splitp -h \; swapp -U
bind -n C-End splitp -h
bind -n C-PageUp splitp -v \; swapp -U
bind -n C-PageDown splitp -v

bind -n M-Delete kill-window

bind -n C-Delete kill-pane
bind Delete detach
bind -n C-S-Delete kill-server

bind Tab previous-window

bind -n M-Insert new-window

bind r source-file ~/.tmux.conf \; display "config reloaded"
bind M-1 source-file ~/.config/tmux/4pane.conf \; display "readed 4pane config"

bind -n C-M-Insert new-window

set -g mouse on
set -s set-clipboard on

bind-key F1 set-option status off
bind-key C-F1 set-option status on
EOF

mkdir -p "${HOME}"/.config/tmux

tee ~/.config/tmux/4pane.conf <<EOF
splitp -h sudo lnav
splitp -v sudo htop
selectp -L
splitp -v sudo -i
selectp -U
EOF
