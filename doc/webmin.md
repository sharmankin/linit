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
dnf install webmin perl-IO-Tty perl-DBI perl-DBD-Pg -y
```
## Firewalld Configure
```bash
firewall-cmd --add-port=10000/tcp --zone=public --permanent
firewall-cmd --reload
```
## One script
```bash
yes | sudo bash -c "$(curl -s https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh )" && {
  sudo dnf install webmin perl-IO-Tty perl-DBI perl-DBD-Pg -y
  sudo firewall-cmd --add-port=10000/tcp --zone=public --permanent 2>/dev/null
  sudo firewall-cmd --reload
  sudo systemctl enable --now webmin.service
  sudo systemctl status webmin.service
}
```
