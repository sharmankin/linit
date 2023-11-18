#!/usr/bin/env bash

curl -o setup-repos.sh https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh && yes | sh setup-repos.sh

sudo dnf install perl-IO-Tty perl-Time-HiRes -yq