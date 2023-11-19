# PHP remi
## Install remi repo
```bash
sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
sudo dnf update -y --refresh

sudo dnf module disable php -y
sudo dnf module enable php:remi-8.3 -y
```
