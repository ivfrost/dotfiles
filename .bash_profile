# .bash_profile

if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# Auto-start Sway on tty1
if [[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty1 ]]; then
    exec sway
fi

export GDK_DPI_SCALE=1.1