# Install Webmin
## Add repo
```bash
curl -o setup-repos.sh https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh
```
```bash
sh setup-repos.sh
```
## Install webmin
```bash
dnf install webmin -y
```
## Firewalld Configure
```bash
firewall-cmd --add-port=10000/tcp --zone=public --permanent
firewall-cmd --reload
```