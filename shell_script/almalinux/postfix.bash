#!/usr/bin/env bash

sudo dnf upgrade --refresh -yq

sudo dnf install postfix dovecot s-nail -yq

sudo systemctl enable --now postfix dovecot
sudo systemctl status postfix dovecot



sudo dnf install https://rpms.remirepo.net/enterprise/remi-release-9.rpm -yq

sudo dnf upgrade --refresh -yq

systemd_conf="/etc/systemd/system/"

MACHINE_HOST=$(hostname)

mkdir -p ${systemd_conf}/{postfix,dovecot}.service.d/

tee ${systemd_conf}/{postfix,dovecot}.service.d/override.conf &>/dev/null <<EOF
[Service]
Restart=on-failure
RestartSec=5s
EOF

tar -czPf ./mailserver_conf_backup_"$(date +'%s')".tar.gz /etc/{postfix,dovecot}

sudo tee /etc/postfix/main.cf <<EOF
compatibility_level = 2
queue_directory = /var/spool/postfix
command_directory = /usr/sbin
daemon_directory = /usr/libexec/postfix
data_directory = /var/lib/postfix
mail_owner = postfix
inet_interfaces = localhost
inet_protocols = ipv4
smtp_address_preference = ipv4


mydestination = \$myhostname, localhost.\$mydomain, localhost
unknown_local_recipient_reject_code = 550
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases


debug_peer_level = 2
debugger_command =
         PATH=/bin:/usr/bin:/usr/local/bin:/usr/X11R6/bin
         ddd \$daemon_directory/\$process_name \$process_id & sleep 5
sendmail_path = /usr/sbin/sendmail.postfix
newaliases_path = /usr/bin/newaliases.postfix
mailq_path = /usr/bin/mailq.postfix
setgid_group = postdrop
html_directory = no
manpage_directory = /usr/share/man
sample_directory = /usr/share/doc/postfix/samples
readme_directory = /usr/share/doc/postfix/README_FILES
smtpd_tls_cert_file = /etc/pki/tls/certs/postfix.pem
smtpd_tls_key_file = /etc/pki/tls/private/postfix.key
smtpd_tls_security_level = may
smtp_tls_CApath = /etc/pki/tls/certs
smtp_tls_CAfile = /etc/pki/tls/certs/ca-bundle.crt
smtp_tls_security_level = may
meta_directory = /etc/postfix
shlib_directory = /usr/lib64/postfix


message_size_limit = 52428800
mailbox_size_limit=0

EOF

sudo systemctl restart postfix

sudo firewall-cmd --permanent --add-service={http,https,smtp-submission,smtps,imap,imaps,smtp}
sudo firewall-cmd --reload

sudo dnf upgrade --refresh -yq

sudo dnf install nginx certbot python3-certbot-nginx -y
sudo systemctl enable --now nginx

sudo dnf install https://rpms.remirepo.net/enterprise/remi-release-9.rpm -yq

sudo dnf upgrade --refresh -yq

sudo dnf module disable php:8.1
sudo dnf module enable php:remi-8.1


sudo tee /etc/nginx/conf.d/mail."${MACHINE_HOST}".conf <<EOF
server {
      listen 80;
      listen [::]:80;
      server_name mail.${MACHINE_HOST};

      root /usr/share/nginx/html/;

      location ~ /.well-known/acme-challenge {
         allow all;
      }
}
EOF
sudo systemctl reload nginx

sudo certbot certonly -a nginx --agree-tos --staple-ocsp --must-staple \
  -d mail."${MACHINE_HOST}" \
  --email webmaster@"${MACHINE_HOST}" \
  --noninteractive --nginx-sleep-seconds 5 --no-eff-email


sudo tee /etc/postfix/master.cf <<EOF
smtp      inet  n       -       n       -       -       smtpd

submission     inet     n    -    n    -    -    smtpd
  -o syslog_name=postfix/submission
  -o smtpd_tls_security_level=encrypt
  -o smtpd_tls_wrappermode=no
  -o smtpd_sasl_auth_enable=yes
  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
  -o smtpd_recipient_restrictions=permit_mynetworks,permit_sasl_authenticated,reject
  -o smtpd_sasl_type=dovecot
  -o smtpd_sasl_path=private/auth

smtps     inet  n       -       y       -       -       smtpd
  -o syslog_name=postfix/smtps
  -o smtpd_tls_wrappermode=yes
  -o smtpd_sasl_auth_enable=yes
  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
  -o smtpd_recipient_restrictions=permit_mynetworks,permit_sasl_authenticated,reject
  -o smtpd_sasl_type=dovecot
  -o smtpd_sasl_path=private/auth

pickup    unix  n       -       n       60      1       pickup
cleanup   unix  n       -       n       -       0       cleanup
qmgr      unix  n       -       n       300     1       qmgr
tlsmgr    unix  -       -       n       1000?   1       tlsmgr
rewrite   unix  -       -       n       -       -       trivial-rewrite
bounce    unix  -       -       n       -       0       bounce
defer     unix  -       -       n       -       0       bounce
trace     unix  -       -       n       -       0       bounce
verify    unix  -       -       n       -       1       verify
flush     unix  n       -       n       1000?   0       flush
proxymap  unix  -       -       n       -       -       proxymap
proxywrite unix -       -       n       -       1       proxymap
smtp      unix  -       -       n       -       -       smtp
relay     unix  -       -       n       -       -       smtp
        -o syslog_name=postfix/\$service_name
showq     unix  n       -       n       -       -       showq
error     unix  -       -       n       -       -       error
retry     unix  -       -       n       -       -       error
discard   unix  -       -       n       -       -       discard
local     unix  -       n       n       -       -       local
virtual   unix  -       n       n       -       -       virtual
lmtp      unix  -       -       n       -       -       lmtp
anvil     unix  -       -       n       -       1       anvil
scache    unix  -       -       n       -       1       scache
postlog   unix-dgram n  -       n       -       1       postlogd
EOF
