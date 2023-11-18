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
This would replace the shell with a tmux session if the shell is started by ssh, unless the current shell is already running inside tmux.

With newer versions of tmux, you should instead be able to use
```bash
if [[ -z $TMUX ]] && [[ -n $SSH_TTY ]]; then
    exec tmux new-session -A -s $USER-tmux-session
fi
```
You would want to do this after setting variables like `TERM` and `LC_*` (if you set these) that affect the terminal capabilities and locale.

Remember that ssh needs a pseudo-tty to run tmux, so you must connect with ssh -t (or use `RequestTTY` force in `~/.ssh/config` for the connection).

## Toggle
```bash
# For tmux 2.1+
# Toggle mouse on
bind-key M \
  set-option -g mouse on \;\
  display-message 'Mouse: ON'

# Toggle mouse off
bind-key m \
  set-option -g mouse off \;\
  display-message 'Mouse: OFF'

# Or, to use a single bind-key toggle for tmux 2.1+
# Toggle mouse on/off
bind-key m \                  
set-option -gF mouse "#{?mouse,off,on}" \;\
display-message "#{?mouse,Mouse: ON,Mouse: OFF}"

```