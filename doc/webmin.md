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

key_file="/etc/letsencrypt/live/${HOSTNAME}/privkey.pem"


if [[ -f "${key_file}" ]]; then
    ms_conf="/etc/webmin/miniserv.conf"
    cp "${ms_conf}" "${ms_conf}.org" 
    
    tee "${ms_conf}" <<eof
 port=10000
root=/usr/libexec/webmin
mimetypes=/usr/libexec/webmin/mime.types
addtype_cgi=internal/cgi
realm=Webmin Server
logfile=/var/webmin/miniserv.log
errorlog=/var/webmin/miniserv.error
pidfile=/var/webmin/miniserv.pid
logtime=168
ssl=1
no_ssl2=
no_ssl3=
ssl_honorcipherorder=1
no_sslcompression=1
env_WEBMIN_CONFIG=/etc/webmin
env_WEBMIN_VAR=/var/webmin
atboot=1
logout=/etc/webmin/logout-flag
listen=10000
denyfile=\.pl$
log=1
blockhost_failures=5
blockhost_time=60
syslog=1
ipv6=1
session=1
premodules=WebminCore
server=MiniServ/2.105
userfile=/etc/webmin/miniserv.users
keyfile=/etc/letsencrypt/live/${HOSTNAME}/privkey.pem
passwd_file=/etc/shadow
passwd_uindex=0
passwd_pindex=1
passwd_cindex=2
passwd_mindex=4
passwd_mode=0
preroot=authentic-theme
passdelay=1
failed_script=/etc/webmin/failed.pl
login_script=/etc/webmin/login.pl
cipher_list_def=1
logout_script=/etc/webmin/logout.pl
error_handler_404=404.cgi
error_handler_403=403.cgi
error_handler_401=401.cgi
nolog=\/stats\.cgi\?xhr\-stats\=general
no_tls1_2=1
extracas=
no_tls1=
ssl_hsts=1
no_tls1_1=1
certfile=/etc/letsencrypt/live/${HOSTNAME}/fullchain.pem
eof
systemctl restart webmin.service
fi

```
