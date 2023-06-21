#!/usr/bin/env bash
sudo apt install git build-essential libreadline-dev libncursesw5-dev libssl-dev \
  libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev \
  -y --no-install-recommends

git clone -b 3.11 --single-branch https://github.com/python/cpython.git python-src && cd python-src || exit 1

./configure --enable-optimizations --prefix '/usr'
make
sudo make install
cd - || exit 1

sudo rm -rf python-src
sudo update-alternatives --install /usr/bin/python3 python3 "$(which python3.11)" 100
sudo update-alternatives --install /usr/bin/python3 python3 "$(which python3.10)" 10

sudo update-alternatives --auto python3
