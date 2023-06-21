#!/usr/bin/env bash

sudo tee -a /etc/sudoers.d/10-"${USER}" <<EOF
${USER} ALL=(ALL:ALL) NOPASSWD:ALL
EOF

sudo apt install build-essential git cmake libx{t,mu}-dev htop ncdu
curl -sfL https://github.com/sharmankin.keys -o ~/.ssh/authorized_keys --create-dirs

git config --global user.name me
git config --global user.email me@karpovan.ru

git clone https://github.com/junegunn/fzf.git "$HOME"/.fzf && "$HOME"/.fzf/install --all

sudo apt install tmux -yq
tee ~/.tmux.conf <<EOF
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

mkdir -p "$HOME"/.config/tmux

tee ~/.config/tmux/4pane.conf <<EOF
splitp -h sudo lnav
splitp -v sudo htop
selectp -L
splitp -v sudo -i
selectp -U
EOF

mkdir -p "$HOME"/.bashrc.d

tee "$HOME"/.bashrc.d/100-tmux-4panel-alias <<EOF
alias tsm='tmux list-sessions 2>/dev/null | grep -q SMAI && tmux attach -d -t SMAI 2>/dev/null || tmux new -t SMAI'
EOF


pathmunge() {
  case ":${PATH}:" in
  *:"$1":*) ;;
  *)
    if [ "$2" = "after" ]; then
      PATH=$PATH:$1
    else
      PATH=$1:$PATH
    fi
    ;;
  esac
}
