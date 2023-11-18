#!/usr/bin/env bash
sudo tee /etc/sudoers.d/10-"${USER}" <<EOF
${USER} ALL=(ALL:ALL) NOPASSWD:ALL
EOF

current_dir=$(dirname "$0")

sudo dnf config-manager --set-enabled crb
sudo dnf install epel-{next-,}release elrepo-release -yq
sudo dnf update -y --refresh

sudo dnf groupinstall development -yq
sudo dnf install python3-{virtualenv,wheel,pip,devel,jedi,virtualenv-api} ninja-build --setopt=install_weak_deps=False -yq
sudo dnf install python3.11-{wheel,pip,devel,setuptools} -yq --setopt=install_weak_deps=False

sudo dnf install git wget curl lnav htop mc ncdu fuse{,3}-devel timeshift top -yq --setopt=install_weak_deps=False

git config --global user.name "${USER}"
git config --global user.email "${USER}"@"${HOSTNAME}"

curl -sfL https://github.com/sharmankin.keys -o ~/.ssh/authorized_keys --create-dirs

"${current_dir}"/fzf_install.bash
"${current_dir}"/bashrc.bash
"${current_dir}"/ps1_mod.bash
"${current_dir}"/neovim.bash
"${current_dir}"/tmux.bash
