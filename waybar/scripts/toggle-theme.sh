#!/bin/bash

THEME_FILE="$HOME/.config/waybar/current-theme"
ALACRITTY="$HOME/.config/alacritty/theme.yml"
WAYBAR="$HOME/.config/waybar/style.css"
SWAY="$HOME/.config/sway/colors"

get_current_theme() {
  [ -f "$THEME_FILE" ] && cat "$THEME_FILE" || echo "light"
}

reload_desktop() {
  swaymsg reload
  pkill -x waybar
  GTK_THEME=Adwaita:dark waybar &
}

set_theme() {
  local theme=$1
  local gtk_theme="Adwaita-$theme"
  local color_scheme="prefer-$theme"
  local code_theme="Atom One $(echo "$theme" | sed 's/\b./\u&/g')"
  local waybar_css="$HOME/.config/waybar/style-$theme.css"
  local alacritty_file="$HOME/.config/alacritty/$theme.yml"
  local sway_colors="$HOME/.config/sway/colors-$theme"

  echo "Linking waybar: $waybar_css -> $WAYBAR"
  ln -sf "$waybar_css" "$WAYBAR"
  ls -la "$WAYBAR"  # Debug: show what the symlink points to
  
  echo "$theme" > "$THEME_FILE"
  gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme"
  gsettings set org.gnome.desktop.interface color-scheme "$color_scheme"
  [ -f ~/.config/Code/User/settings.json ] && sed -i "s/\"workbench.colorTheme\": *\"[^\"]*\"/\"workbench.colorTheme\": \"$code_theme\"/" ~/.config/Code/User/settings.json
  ln -sf "$alacritty_file" "$ALACRITTY"
  ln -sf "$sway_colors" "$SWAY"
  reload_desktop
}

toggle_theme() {
  local current=$(get_current_theme)
  [ "$current" = "light" ] && set_theme "dark" || set_theme "light"
  echo "Theme switched to $(get_current_theme)"
}

toggle_theme
