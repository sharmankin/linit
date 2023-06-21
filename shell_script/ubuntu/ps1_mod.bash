#!/usr/bin/env bash
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

mkdir -p "${HOME}"/.bashrc.d

tee "${HOME}"/.bashrc.d/01-ps1 &>/dev/null <<EOF
PS1="
[ \A ] [${ps_color[1]} \\\$? ${ps_color[0]}] [ ${ps_color[3]}\w${ps_color[0]} ]
[ ${ps_color[name_color]}\u${ps_color[0]}@${ps_color[s_color]}${host_part}${ps_color[0]} ]${ps_color[s_color]}\\\\\$${ps_color[0]}: "
EOF
