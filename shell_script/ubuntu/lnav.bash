#!/usr/bin/env bash


sudo apt install {libncurses,libreadline,libsqlite3,libcurlpp,libpcre2,libghc-curl}-dev -y
src_dir="/opt/lnav"
git clone https://github.com/tstack/lnav.git "${src_dir}"
cd "${src_dir}" || exit ${LINENO}
./autogen.sh
./configure --prefix=/usr
make -j "$(nproc)"
make install
cd - || exit ${LINENO}
lnav -V
