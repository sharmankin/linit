# CentOS / Rocky Linux
## Install

### Add repo
```bash
sudo dnf install yum-utils -yq

sudo tee /etc/yum.repos.d/nginx.repo 1>/dev/null <<eof
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
eof

sudo dnf config-manager --disable nginx{,-stable}
sudo dnf config-manager --enable nginx-mainline

sudo dnf upgrade --refresh -y

sudo dnf install nginx -y
sudo systemctl enable --now nginx.service 
sudo systemctl status nginx.service 
```

## PreConfigure
```bash
HOST=$(hostname)

sudo tee /etc/nginx/conf.d/"${HOST}.conf" <<eof
server {
      listen 80;
      listen [::]:80;
      server_name $HOST;

      root /usr/share/nginx/html/;

      location ~ /.well-known/acme-challenge {
         allow all;
      }
}
eof
```
## Firewalld Configure
```bash
firewall-cmd --add-service=http{,s} --zone=public --permanent
firewall-cmd --reload
```


# Ubuntu
## Install

```bash
sudo apt install curl gnupg2 ca-certificates lsb-release debian-archive-keyring -y

key_path=/usr/share/keyrings/nginx-archive-keyring.gpg

sudo curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | sudo tee "${key_path}" >/dev/null
    
sudo gpg --dry-run --quiet --no-keyring --import --import-options import-show "${key_path}"

sudo tee /etc/apt/sources.list.d/nginx.list 1>/dev/null <<eof
deb [signed-by=$key_path] http://nginx.org/packages/mainline/debian `lsb_release -cs` nginx
eof

sudo tee /etc/apt/preferences.d/99nginx 1>/dev/null <<eof
Package: *
Pin: origin nginx.org
Pin: release o=nginx
Pin-Priority: 900

eof

sudo apt update
sudo apt install nginx
```

