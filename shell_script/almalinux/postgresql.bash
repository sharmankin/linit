#!/usr/bin/env bash

dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
dnf -qy module disable postgresql
dnf install -qy postgresql15-server postgresql15-contrib

dnf --enablerepo=crb install mariadb-devel
dnf install -yq mysql_fdw_15 postgresql15-plpython3 pg_cron_15 libpq5-devel

/usr/pgsql-15/bin/postgresql-15-setup initdb
systemctl enable --now postgresql-15
systemctl status postgresql-15

firewall-cmd --zone=public --permanent --add-service=postgresql
firewall-cmd --reload