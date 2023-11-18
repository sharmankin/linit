# Wireguard

## Install

## Deployment

```bash
#!/usr/bin/env bash
port=10456
broadcast_ip=$(curl -s https:/ipinfo.io/ip)

net='192.168.203'
prefix="space"
conf='vpn'

wg_dir="/etc/wireguard"

conf_file="${wg_dir}/${conf}.conf"
profiles_dir="${wg_dir}/clients"

dnf list --installed wireguard-tool 2>/dev/null || {
    systemctl disable --now wg-quick@${conf}.service 2>/dev/null
    dnf remove wireguard-tools -yq

    rm -rf ${wg_dir}
    systemctl daemon-reload
}

dnf update -yq
dnf install wireguard-tools -y || exit ${LINENO}

read -r server_private <<<"$(wg genkey | tee ${wg_dir}/${prefix}-server_private.key)"
read -r server_public <<<"$(wg pubkey <<<${server_private} | tee ${wg_dir}/${prefix}-server_public.key)"

tee "${conf_file}" &>/dev/null <<eof
[Interface]
Address = ${net}.1/24

ListenPort = ${port}
PrivateKey = ${server_private}
eof

if [[ -z "$(grep ${port}/udp <<<$(firewall-cmd --zone=public --list-ports))" ]]; then
      firewall-cmd --permanent --zone=public --add-port=${port}/udp
      firewall-cmd --permanent --zone=trusted --add-interface=${conf}
      firewall-cmd --reload
fi

systemctl enable --now wg-quick@${conf}.service
systemctl status wg-quick@${conf}.service

for i in {2..254}; do
  
  client="${net}.${i}"
  client_dir="${profiles_dir}/${client}"
  
  mkdir -p ${client_dir}
  
  read -r client_private <<<"$(wg genkey | tee ${client_dir}/private.key)"
  read -r client_public <<<"$(wg pubkey <<<${client_private} | tee ${client_dir}/public.key)"
  
  tee -a /etc/wireguard/vpn.conf <<eof

# -- free --
[Peer]
AllowedIPs = $client
PublicKey = ${client_public}
eof

  user_conf_file="${client_dir}/${HOSTNAME//./-}.conf"
  user_conf_full_file="${client_dir}/${HOSTNAME//./-}-full.conf"

  tee "${user_conf_file}" <<eof
[Interface]
PrivateKey = ${client_private}
Address = ${client}/32

[Peer]
PublicKey = ${server_public}
AllowedIPs = ${net}.0/24
Endpoint = ${broadcast_ip}:${port}
PersistentKeepalive = 25
eof

  tee "${user_conf_full_file}" <<eof
[Interface]
PrivateKey = ${client_private}
Address = ${client}/32

[Peer]
PublicKey = ${server_public}
AllowedIPs = 0.0.0.0/1, 128.0.0.0/1
Endpoint = ${broadcast_ip}:${port}
PersistentKeepalive = 25
eof
  
  zip_file=${client_dir}/${HOSTNAME//./-}.wg-conf.zip
  
  rm -f ${zip_file}
  zip ${zip_file} ${user_conf_file} ${user_conf_full_file} -j "${client_dir}" -q
  rm ${user_conf_file} ${user_conf_full_file}

done
systemctl restart wg-quick@${conf}.service
systemctl status wg-quick@${conf}.service
```
