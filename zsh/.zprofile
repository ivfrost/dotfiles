export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh/"

if [[ -z $DISPLAY && $TTY = /dev/tty1 ]]; then
  export MOZ_ENABLE_WAYLAND=1
  exec sway --unsupported-gpu
fi
