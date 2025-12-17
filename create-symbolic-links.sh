#!/bin/sh

dotfiles="$XDG_CONFIG_HOME/dotfiles"
zsh="$XDG_CONFIG_HOME/zsh"
alacritty="$XDG_CONFIG_HOME/alacritty"
nvim="$XDG_CONFIG_HOME/nvim"
sway="$XDG_CONFIG_HOME/sway"
waybar="$XDG_CONFIG_HOME/waybar"
wofi="$XDG_CONFIG_HOME/wofi"
pcmanfm="$XDG_CONFIG_HOME/pcmanfm"
scripts="$HOME/.local/scr"

mkdir -p "$zsh" "$alacritty" "$nvim" "$sway" "$waybar" "$wofi" "$pcmanfm" "$scripts"

# Link zsh configuration files
[ ! -e "$zsh/.zshrc" ] && ln -s "$dotfiles/zsh/.zshrc" "$zsh/"
[ ! -e "$HOME/.zprofile" ] && ln -s "$dotfiles/zsh/.zprofile" "$HOME/"

# Link other configuration files
ln -sf "$dotfiles/alacritty/"* "$alacritty/"
ln -sf "$dotfiles/nvim/"* "$nvim/"
ln -sf "$dotfiles/sway/"* "$sway/"
ln -sf "$dotfiles/waybar/"* "$waybar/"
ln -sf "$dotfiles/wofi/"* "$wofi/"
ln -sf "$dotfiles/pcmanfm/"* "$pcmanfm/"
ln -sf "$dotfiles/scripts/"* "$scripts/"

