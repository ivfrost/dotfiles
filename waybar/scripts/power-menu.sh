
#!/bin/bash
options=" Shutdown\n Reboot\n Suspend\n Hibernate\n Reload desktop\n Lock\n Log out"
selected=$(echo -e "$options" | wofi --dmenu --width 250 --lines 8 --prompt 'Power Menu')

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
    *Hibernate*)
        systemctl hibernate
        ;;
    *Reload*)
        (pkill -x sway && sway) && (pkill -x waybar && waybar) && (pkill -x swaync &&  swaync) && sleep 5 && notify-send "Desktop reloaded" "Desktop was reloaded successfully"
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
