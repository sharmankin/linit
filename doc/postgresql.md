# Postgresql
## Install
```bash
version=16

dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
dnf -qy module disable postgresql

while read -r repo; do
  [[ pgdg"${version}" != "$repo" ]] && dnf config-manager --disable "${repo}"
done < <(dnf repolist pgdg* --enabled | grep -Eo 'pgdg[0-9]+')

#while read -r -u 3 repo; do
#  IFS=: read -a a_repo <<<$repo
#  sed -E "$(( ${a_repo[0]} + 3 ))s/0/1/" -i /etc/yum.repos.d/pgdg-redhat-all.repo
#done 3< <(grep -Pno "(?<=\[)pgdg(?=\d+)(?"'!'"${version}).*?(?=\])" /etc/yum.repos.d/pgdg-redhat-all.repo)

dnf install -qy postgresql"${version}"-server postgresql"${version}"-contrib

dnf install -yq mysql_fdw_"${version}" postgresql"${version}"-plpython3 pg_cron_"${version}" libpq5-devel perl-DBI perl-DBD-Pg

/usr/pgsql-"${version}"/bin/postgresql-"${version}"-setup initdb
systemctl enable --now postgresql-"${version}"
systemctl status postgresql-"${version}"

firewall-cmd --zone=public --permanent --add-service=postgresql
firewall-cmd --reload
```
## Disable repo Opt 1
```bash
version=16

while read -r -u 3 repo; do
  IFS=: read -a a_repo <<<$repo
  sed -E "$(( ${a_repo[0]} + 3 ))s/1/0/" -i /etc/yum.repos.d/pgdg-redhat-all.repo
done 3< <(grep -Pno "(?<=\[)pgdg(?=\d+)(?"'!'"${version}).*?(?=\])" /etc/yum.repos.d/pgdg-redhat-all.repo)
```
## Disable repo Opt 2
```bash
version=16

while read -r repo; do
  [[ pgdg"${version}" != "$repo" ]] && dnf config-manager --disable "${repo}"
done < <(dnf repolist pgdg* --enabled | grep -Eo 'pgdg[0-9]+')
```


## PG Prompt
```bash

confdir=$(cat /etc/passwd | grep -E '^postgres' | cut -d : -f 6)

sudo -iu postgres tee "${confdir}"/.psqlrc <<eof
\set QUIET 1

\set PROMPT1 '%M:%[%033[1;31m%]%>%[%033[0m%] %n@%/%R%#%x '

\set PROMPT2 '%M %n@%/%R %# '

\pset null '[null]'
\pset format wrapped
\pset linestyle unicode

\set COMP_KEYWORD_CASE upper

\timing

\set HISTSIZE 2000

\set VERBOSITY verbose

\set QUIET 0

\echo 'Welcome to PostgreSQL! \n'
\echo 'Type :version to see the PostgreSQL version. \n' 
\echo 'Type :extensions to see the available extensions. \n'
\echo 'Type \\q to exit. \n'
\set version 'SELECT version();'
\set extensions 'select * from pg_available_extensions;'
eof

```
## postgres user color prompt
```bash
color=(reset red green brown blue purple cyan "l-gray")
color_idx=('0' '1;31' '1;32' '1;33' '1;34' '1;35' '1;36' '1;37')

mapfile -t f_color < <(printf '\e[%sm\n' "${color_idx[@]}")
mapfile -t ps_color < <(printf '\[\033[%sm\]\n' "${color_idx[@]}")

if [[ $(id -u) != 0 ]]; then
  for i in $(seq 1 $((${#color[@]} - 1))); do
    printf "${f_color[i]}%s) ${HOSTNAME} [ %s ]${f_color[0]}\n" "${i}" "${color[i]^}"
  done

  echo
  read -r -p "Select hostname color: " -n 1 s_color

  [[ -z $s_color  ]] && s_color=2

  name_color=2
  echo
else
  s_color=1
  name_color=1
fi

printf "Provide a prompt host part\nLeave blank to use ${f_color[s_color]}%s${f_color[0]}: " "${HOSTNAME}"

read -r host_part

[[ -z "${host_part}" ]] && host_part="${HOSTNAME}"

tee -a "${HOME}"/.bash_profile &>/dev/null <<EOF
PS1="
[ \A ] [${ps_color[1]} \\\$? ${ps_color[0]}] [ ${ps_color[3]}\w${ps_color[0]} ]
[ ${ps_color[name_color]}\u${ps_color[0]}@${ps_color[s_color]}${host_part}${ps_color[0]} ]${ps_color[s_color]}\\\\\$${ps_color[0]}: "
EOF

```
