# lnav
```bash
dnf remove lnav -yq
dnf install {libcurl,pcre2,sqlite,ncurses,readline,zlib,bzip2,libarchive,wireshark}-devel -yq
src_dir="/opt/lnav"
git clone https://github.com/tstack/lnav.git "${src_dir}"
cd "${src_dir}"
./autogen.sh
./configure --prefix=/usr
make -j $(nproc)
make install
cd -
```
# htop
```bash
dnf remove -qy htop
dnf install {hwloc,libcap,libnl3,ncurses}-devel -yq
src_dir="/opt/htop"
git clone https://github.com/htop-dev/htop.git "${src_dir}"
cd "${src_dir}"
./autogen.sh
./configure --prefix=/usr --enable-unicode --enable-hwloc --enable-capabilities
make -j $(nproc)
make install
cd -
```
# tmux

## Install
```bash
dnf remove tmux -yq
dnf install pkgconf-pkg-config autoconf automake {libevent,ncurses}-devel gcc make bison pkg-config -yq

src_dir="/opt/tmux"
git clone https://github.com/tmux/tmux.git "${src_dir}"
cd "${src_dir}"
./autogen.sh
./configure --prefix=/usr
make -j $(nproc)
make install
cd -

tee /etc/tmux.conf 1>/dev/null <<eof
unbind C-b

set -g prefix S-Delete
bind S-Delete send-prefix

set -g default-terminal "tmux-256color"

bind -n S-Left select-pane -L
bind -n S-Right select-pane -R
bind -n S-Up select-pane -U
bind -n S-Down select-pane -D

bind -n C-M-Left resize-pane -L
bind -n C-M-Right resize-pane -R
bind -n C-M-Up resize-pane -U
bind -n C-M-Down resize-pane -D

bind -n C-M-z resize-pane -Z

bind -n M-Delete kill-window

bind -n C-S-Delete kill-server

bind -n C-S-Left previous-window
bind -n C-S-Right next-window

bind Tab choose-window
bind Insert new-window
bind Delete detach

bind -n M-l send 'clear && tput cup \$LINES' Enter

user_conf="${HOME}/.config/tmux/user.conf"
if-shell "[ -f ${user_conf} ]" "set-hook -g after-new-session 'source-file ${user_conf}'"

bind -n C-M-R source-file /etc/tmux.conf \; display "config reloaded"

set -g mouse on
set -s set-clipboard on
set -g pane-border-status top
set -g pane-border-format "#P: #{pane_current_command}"

bind-key F1 set-option status
bind-key m set-option mouse \; display-message "Mouse is #{?mouse,ON,OFF}"
eof
```
## Config hints
```text
MouseDown1Pane — Mouse Left button.
MouseDown2Pane — Mouse Wheel button.
MouseDown3Pane — Mouse Right button.

DoubleClick1Pane Left Mouse DoubleClick
TripleClick1Pane Left Mouse DoubleClick
```
## User Config Example
```bash
user_conf_dir="$HOME/.config/tmux"
mkdir -p ${user_conf_dir}

tee ${user_conf_dir}/user.conf <<eof
clr="clear && tput cup \\\$LINES\\n"
rename-window main
new-window -n root -S sudo -i
send \$clr
new-window -n admin -S sudo -i
split -v sudo lnav
resize-pane -D 10
selectp -U
send \$clr
split -h sudo htop
selectp -L
send \$clr
new-window -n postgres -S sudo -iu postgres
split -v sudo -u postgres lnav /var/lib/pgsql/16/data/log
resize-pane -D 10
selectp -U
send \$clr
split -h sudo -u postgres psql
selectp -L
# previous-window
select-window -t 0
send \$clr
eof
```
## .bash_profile / .profile block (copy/paste in header before reading .bashrc)
```bash
if [[ -z $TMUX ]] && [[ -n $SSH_TTY ]]; then
    session=$USER-tmux-session

    if tmux has-session -t "$session" 2>/dev/null; then
        exec tmux attach-session -t "$session"
    else
        exec tmux new-session -s "$session"
    fi
fi
```