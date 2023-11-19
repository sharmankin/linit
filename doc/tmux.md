## Install
```bash
dnf remove tmux -yq
dnf install pkgconf-pkg-config autoconf automake {libevent,ncurses}-devel gcc make bison pkg-config -y

src_dir="/opt/tmux"
git clone https://github.com/tmux/tmux.git "${src_dir}"
cd "${src_dir}"
./autogen.sh
./configure --prefix=/usr
make -j $(nproc)
make install
cd -
tmux -V
```
## Make common config
```bash
sudo tee /etc/tmux.conf 1>/dev/null <<eof
unbind C-b

set -g prefix M-q
bind M-q send-prefix

set -g default-terminal "tmux-256color"

bind -n S-Left select-pane -L
bind -n S-Right select-pane -R
bind -n S-Up select-pane -U
bind -n S-Down select-pane -D

bind -n C-M-Right resize-pane -R
bind -n C-M-Left resize-pane -L
bind -n C-M-Up resize-pane -U
bind -n C-M-Down resize-pane -D

bind -n C-M-S-Right resize-window -R
bind -n C-M-S-Left resize-window -L
bind -n C-M-S-Up resize-window -U
bind -n C-M-S-Down resize-window -D

bind -n C-M-S-PageUp resize-window -A
bind -n C-M-S-PageDown resize-window -a

bind -n C-M-z resize-pane -Z

bind -n M-Delete kill-window

bind -n C-S-Delete kill-server

bind -n C-S-Left previous-window
bind -n C-S-Right next-window

bind Tab choose-window
bind Insert new-window
bind Delete detach

bind -n M-l send 'clear && tput cud \$LINES' Enter

user_conf="\${HOME}/.config/tmux/.tmux.conf"
if-shell "[ -f \${user_conf} ]" "set-hook -g after-new-session 'source-file \${user_conf}'"

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
### Mouse buttons
```text
MouseDown1Pane — Mouse Left button.
MouseDown2Pane — Mouse Wheel button.
MouseDown3Pane — Mouse Right button.

DoubleClick1Pane Left Mouse DoubleClick
TripleClick1Pane Left Mouse DoubleClick
```
### Toggle
*For tmux 2.1+\
Toggle mouse `on`*
```text
bind-key M \
  set-option -g mouse on \;\
  display-message 'Mouse: ON'
```
*For tmux 2.1+\
Toggle mouse `off`*
```text
bind-key m \
  set-option -g mouse off \;\
  display-message 'Mouse: OFF'
```
*Or, to use a single bind-key toggle for tmux 2.1+\
Toggle mouse on/off*
```text
bind-key m \                  
set-option mouse \;\
display-message "#{?mouse,Mouse: ON,Mouse: OFF}"
```

---
## Autostart
To start tmux automatically in `~/.bash_profile` (for login shells), or `~/.bashrc` (for interactive shells), use something like
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
*This would replace the shell with a tmux session if the shell is started by ssh, unless the current shell is already running inside tmux.\
With newer versions of tmux, you should instead be able to use*
```bash
if [[ -z $TMUX ]] && [[ -n $SSH_TTY ]]; then
    exec tmux new-session -A -s $USER-tmux-session
fi
```
*You would want to do this after setting variables like `TERM` and `LC_*` (if you set these) that affect the terminal capabilities and locale.\
Remember that ssh needs a pseudo-tty to run tmux, so you must connect with ssh -t (or use `RequestTTY force` in `~/.ssh/config` for the connection).*
## User config
### Config #1
```bash
user_conf_dir="$HOME/.config/tmux"
mkdir -p ${user_conf_dir}

tee ${user_conf_dir}/.tmux.conf <<eof
clr="clear && tput cud \\\$LINES\\n"
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
### Config #2 (with postgresql window)
```bash
user_conf_dir="$HOME/.config/tmux"
mkdir -p ${user_conf_dir}

if grep -qPo '\bpostgres\b' /etc/passwd ; then
  pg_log_dir="$(sudo -iu postgres psql -AXqtc \
  "SELECT format('%s/%s', current_setting('data_directory'), current_setting('log_directory'));" \
  )"
  
  pg_part="$(cat <<eof
# -- pg part --
new-window -n postgres -S sudo -iu postgres
split -v sudo -iu postgres lnav ${pg_log_dir}
resize-pane -y 30%
select-pane -t 0
send \$clr
split -h sudo -iu postgres psql
select-pane -t 0

eof
  )"
fi

tee ${user_conf_dir}/.tmux.conf <<eof
clr="clear && tput cud \\\$LINES\\n"
rename-window ${USER}

split-window -v -l 30% 'sudo -i'
send \$clr

split-window -h 'sudo -i lnav'
select-pane -t 0

split-window -h 'sudo -i htop'

select-pane -t 0
send \$clr
${pg_part}
select-window -t 0
send \$clr
eof
```