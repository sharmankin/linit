# Disable/Enable in GRUB
You can disable SELinux by adding the kernel parameter

    selinux=0

to the kernel command line.

If you can't boot into your system anymore because of - say - SELinux relabeling issues the simplest thing is to temporarily add this parameter in Grub, i.e. while the Grub menu is displayed, select the right menu entry, enter entry edit mode with <kbd>E</kbd>, move to the kernel parameters line, move the cursor to the end, append `selinux=0` and then hit <kbd>Ctrl</kbd><kbd>X</kbd> to boot that modified entry.

After the next successful boot you can permanently disable SELinux by either adding `selinux=0` to your grub kernel parameter configuration or by setting `SELINUX=disabled` in `/etc/selinux/config`.

On CentOS 7 and later you can edit the kernel parameters in `/etc/default/grub` (in the `GRUB_CMDLINE_LINUX=` key) and then you have to regenerate your Grub config like this:
```bash
grub2-editenv - unset kernelopts
grub2-mkconfig -o /etc/grub2.cfg
grub2-mkconfig -o /etc/grub2-efi.cfg
```
---
# Simple
## Enable
```bash
grubby --update-kernel ALL --remove-args selinux
sed -r '/^SELINUX=/s/(=).*$/\1enforcing/' -i /etc/selinux/config
reboot
```
## Disable
```bash
grubby --update-kernel ALL --args selinux=0
sed -r '/^SELINUX=/s/(=).*$/\1disabled/' -i /etc/selinux/config
reboot
```