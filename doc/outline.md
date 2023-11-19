# Outline VPN (on RockyLinux)
## Install docker
```bash
sudo dnf check-update
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io -yq
sudo systemctl enable --now docker
sudo systemctl status docker

log_file=outline_install.log

yes | sudo bash -c "$(curl -s https://raw.githubusercontent.com/Jigsaw-Code/outline-server/master/src/server_manager/install_scripts/install_server.sh)" | tee ${log_file}

grep -Po '\{.+\}' ${log_file} > outline-manager.json

sudo firewall-cmd --permanent --zone=public  \
  --add-port="$(grep -Po '(?<=Management port )\d+' ${log_file})"/tcp \
  --add-port="$(grep -Po '(?<=Access key port )\d+' ${log_file})"/{tcp,udp}

sudo firewall-cmd --reload
rm ${log_file}
```