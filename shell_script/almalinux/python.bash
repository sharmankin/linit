#!/usr/bin/env bash

sudo dnf install libsqlite3x-devel

sudo dnf install dnf-plugins-core -yq
sudo dnf builddep python3

git clone -b 3.10 --single-branch https://github.com/python/cpython.git python-src && cd python-src || exit 1

./configure --enable-optimizations --prefix '/usr'
make
sudo make install
cd - || exit 1

sudo rm -rf python-src

git clone -b 3.11 --single-branch https://github.com/python/cpython.git python-src && cd python-src || exit 1

./configure --enable-optimizations --prefix '/usr'
make
sudo make install
cd - || exit 1

sudo rm -rf python-src

