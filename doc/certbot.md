# Certbot
## Install lib
```bash
dnf install certbot python3-certbot-nginx -yq 
```
## For nginx host
```bash
HOST=$(hostname)
certbot --nginx --agree-tos --staple-ocsp -d ${HOST} --email webmaster@${HOST} --noninteractive --nginx-sleep-seconds 5 --no-eff-email --hsts --redirect
```
## For mailserver
```bash
HOST=$(hostname)
certbot --nginx --agree-tos --staple-ocsp -d mail.${HOST} --email webmaster@${HOST} --noninteractive --nginx-sleep-seconds 5 --no-eff-email
```