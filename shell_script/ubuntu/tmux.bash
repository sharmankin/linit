#!/usr/bin/env bash

apt install make cmake automake autoconf pkg-config \
  pkgconf {libevent,ncurses}-dev nasm


git clone https://github.com/tmux/tmux.git && cd tmux || exit 1
sh autogen.sh
./configure --enable-static --prefix='/usr'
