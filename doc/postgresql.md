# Postgresql
```bash
version=16

dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
dnf -qy module disable postgresql
dnf install -qy postgresql"${version}"-server postgresql"${version}"-contrib

dnf install -yq mysql_fdw_"${version}" postgresql"${version}"-plpython3 pg_cron_"${version}" libpq5-devel perl-DBI perl-DBD-Pg

/usr/pgsql-"${version}"/bin/postgresql-"${version}"-setup initdb
systemctl enable --now postgresql-"${version}"
systemctl status postgresql-"${version}"

firewall-cmd --zone=public --permanent --add-service=postgresql
firewall-cmd --reload
```