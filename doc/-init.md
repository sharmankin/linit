# Prepare

```bash
sudo tee /etc/sudoers.d/10-"${USER}" <<EOF
${USER} ALL=(ALL:ALL) NOPASSWD:ALL
EOF
```

```bash
aexit() {
    printf '\e[1;31mAbnormal script exit on line %s\e[0m\n' $1 && exit $1
}

sudo dnf config-manager --set-enabled crb

sudo dnf install epel-release -y || aexit ${LINENO}
sudo dnf update -y

sudo dnf install epel-next-release elrepo-release -y  || aexit ${LINENO}
sudo dnf update -y --refresh

sudo dnf groupinstall development -y || aexit ${LINENO}

sudo dnf install bind-utils dnf-utils bash-completion \
  gcc-c++ make cmake ninja-build automake autoconf \
  pkgconf-pkg-config gcc bison pkg-config -y

sudo dnf install python3-{virtualenv,wheel,pip,devel,jedi,virtualenv-api} --setopt=install_weak_deps=False -y
sudo dnf install python3.11-{wheel,pip,devel,setuptools} -y --setopt=install_weak_deps=False  || aexit ${LINENO}

sudo dnf install mc fuse{,3}-devel timeshift ncdu -y \
  --setopt=install_weak_deps=False || aexit ${LINENO}

git config --global user.name "${USER}"
git config --global user.email "${USER}"@"${HOSTNAME}"

curl -sfL https://github.com/sharmankin.keys -o ~/.ssh/authorized_keys --create-dirs

git clone https://github.com/junegunn/fzf.git "${HOME}/.fzf" -q && \
  "${HOME}/.fzf"/install --all &>/dev/null
```

# Home
```bash
mkdir -p "${HOME}"/.bashrc.d
mkdir -p "${HOME}"/.local/src

mkdir -p "${HOME}"/.bashrc.d

fzf_dir="${HOME}/.fzf"
if [[ ! -d "${fzf_dir}" ]]; then
git clone https://github.com/junegunn/fzf.git "${HOME}/.fzf" -q && \
  "${HOME}/.fzf"/install --all &>/dev/null
fi
tee "${HOME}/.bashrc.d/03-fzf" &>/dev/null <<EOF
  source ${HOME}/.fzf.bash
EOF

tee "${HOME}/.bashrc" &>/dev/null <<EOF
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

pathmunge() {
  case ":\${PATH}:" in
  *:"\$1":*) ;;
  *)
    if [ "\$2" = "after" ]; then
      PATH=\${PATH}:\$1
    else
      PATH=\$1:\${PATH}
    fi
    ;;
  esac
}

# User specific environment
if ! [[ "\${PATH}" =~ \${HOME}/.local/bin:\${HOME}/bin: ]]; then
  PATH="\${HOME}/.local/bin:\${HOME}/bin:\${PATH}"
fi
export PATH

# User-specific aliases and functions
if [ -d ~/.bashrc.d ]; then
  for item in ~/.bashrc.d/*; do
    if [ -f "\${item}" ]; then
      . "\${item}"
    fi
  done
fi

unset item
EOF

[[ -d ${HOME}/.fzf ]] && tee "${HOME}/.bashrc.d/03-fzf" &>/dev/null <<EOF
source ${HOME}/.fzf.bash
EOF


mkdir -p "${HOME}"/.bashrc.d
tee "${HOME}/.bashrc.d/02-aliases" &> /dev/null <<EOF
if [[ -x /usr/bin/dircolors ]]; then
    test -r ~/.dircolors && eval "\$(dircolors -b ~/.dircolors)" || eval "\$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
alias l='ls -1F'
alias ll='ls -lF'
alias la='ls -lAF':wq

alias clr='clear && tput cup \$LINES'
EOF
```
## Prompt line
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

mkdir -p "${HOME}"/.bashrc.d

tee "${HOME}"/.bashrc.d/01-ps1 &>/dev/null <<EOF
PS1="
[ \A ] [${ps_color[1]} \\\$? ${ps_color[0]}] [ ${ps_color[3]}\w${ps_color[0]} ]
[ ${ps_color[name_color]}\u${ps_color[0]}@${ps_color[s_color]}${host_part}${ps_color[0]} ]${ps_color[s_color]}\\\\\$${ps_color[0]}: "
EOF
```


# RSysLog
```bash

grep -q 'ssh-rsa algorithm is disabled' /var/log/messages && {
  tee -a /etc/rsyslog.d/01-supress-trash.conf <<eof
:msg,contains,"ssh-rsa algorithm is disabled" /dev/null
&stop

eof
  systemctl restart rsyslog.service
}
```