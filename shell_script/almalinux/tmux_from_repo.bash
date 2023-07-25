#!/usr/bin/env bash

sudo dnf install http://galaxy4.net/repo/galaxy4-release-8-current.noarch.rpm -yq
sudo dnf update -yq
sudo dnf install tmux --nobest -yq