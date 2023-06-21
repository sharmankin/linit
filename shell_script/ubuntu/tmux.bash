#!/usr/bin/env bash

apt install {libutempter,libutf8proc}-dev make automake autoconf pkg-config


git clone https://github.com/tmux/tmux.git && cd tmux || exit 1
sh autogen.sh
./configure --enable-static --enable-utempter --enable-utf8proc --prefix='/usr'
