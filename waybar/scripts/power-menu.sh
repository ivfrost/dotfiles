
#!/bin/bash
options="⏻ Shutdown\n⏼ Reboot\n⏾ Suspend\n⏏ Lock\n⏹ Logout"
selected=$(echo -e "$options" | wofi --dmenu --width 250 --lines 6 --prompt 'Power Menu')

case "$selected" in
    *Shutdown*)
        systemctl poweroff
        ;;
    *Reboot*)
        systemctl reboot
        ;;
    *Suspend*)
        systemctl suspend
        ;;
    *Lock*)
        swaylock
        ;;
    *Logout*)
        swaymsg exit
        ;;
    *)
        exit 1
        ;;
esac
