# systemd-vconsole-setup.service
## loadkeys: Unable to open file: ***: No such file or directory
```bash
localectl list-keymaps
```
### Copy any keymaps value from output
```text
kr-kr104
kz-latin
latam
latam-colemak
latam-colemak-gaming
latam-deadtilde
latam-dvorak
...
mt-alt-us
mt-us
ng
ng-hausa
ng-igbo
ng-yoruba
nl
nl-mac
nl-std
nl-us
no
no-colemak
no-dvorak
no-mac
no-mac_nodeadkeys
no-nodeadkeys
no-smi
```
---
### Change the value in file
`/etc/vconsole.conf`
```text
KEYMAP="us"
# -----^^^
FONT="latarcyrheb-sun16"
```
*EXAMPLE*
```bash
sed -r '/KEYMAP/s/(").+(")/\1en\2/g' -i /etc/vconsole.conf
```