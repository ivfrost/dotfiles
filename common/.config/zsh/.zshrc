# =============================
# Zsh settings
# =============================
setopt glob 
bindkey -v
bindkey '^?' backward-delete-char
bindkey '^H' backward-kill-word
bindkey -M viins '^[[1;5D' backward-word
bindkey -M viins '^[[1;5C' forward-word

WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
HISTFILE=$ZDOTDIR/.zsh_history
HISTSIZE=10000
SAVEHIST=20000

setopt HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_SAVE_NO_DUPS
setopt APPEND_HISTORY SHARE_HISTORY EXTENDED_HISTORY AUTO_CD


# =============================
# Aliases
# =============================
alias ..="cd .."
alias ~="cd ~"
alias dsk="cd ~/Desktop"
alias dwn="cd ~/Downloads"
alias doc="cd ~/Documents"
alias pjt="cd ~/Documents/Projects/"
alias vid="cd ~/Videos"
alias noi="cd ~/Videos/Noises"
alias mus="cd ~/Music"
alias hdd="cd /mnt/hdd"
alias opt="cd /opt"
alias dot="cd $XDG_CONFIG_HOME/dotfiles/"
alias srv="cd /srv"

alias sudo="sudo "
alias doas="sudo "
alias v="nvim "
alias vv="sudo -E nvim"
alias szs="source $ZDOTDIR/.zshrc"
alias vzs="nvim $XDG_CONFIG_HOME/dotfiles/common/zsh/.zshrc"
alias files="nautilus ."
alias lsa="ls -a"
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'
alias gitsummary='$HOME/.local/bin/gitsummary'
alias yt-dlp='noglob yt-dlp '

# Docker
alias dcpud="docker-compose up -d"
alias dcpu="docker-compose up"
alias dcpufr="docker-compose up --force-recreate"
alias dcpd="docker-compose down"
alias dcpdro="docker-compose down --remove-orphans"

# Flutter
alias fr="flutter run"
alias fdr="flutter doctor"
alias fpg="flutter pub get"
alias fpr="flutter pub remove "
alias fpa="flutter pub add "
alias fcl="flutter clean && flutter pub get"
alias fls="flutter devices"

# Sway + Waybar
alias vsw="nvim $XDG_CONFIG_HOME/sway/config"
alias vwb="nvim $XDG_CONFIG_HOME/waybar/config"

# Fedora
alias dnfi='sudo dnf install -y '
alias dnfr='sudo dnf remove -y '
alias dnfu='sudo dnf upgrade -y '
alias dnfs='sudo dnf search '
alias dnfl='sudo dnf list '

# NixOS
alias nrs="sudo nixos-rebuild switch"
alias nvc="sudo -E nvim /etc/nixos/configuration.nix"
alias nvhm="sudo -E nvim /etc/nixos/home.nix"

# =============================
# Plugin auto‑clone
# =============================
ZSH_PLUGIN_DIR="$ZDOTDIR/plugins"
mkdir -p "$ZSH_PLUGIN_DIR"

clone_if_missing() {
  local dir="$1"
  local repo="$2"

  if [ ! -d "$dir" ]; then
    echo "[zsh] Installing plugin: $repo → $dir"
    git clone --depth=1 "$repo" "$dir"
  fi
}

clone_if_missing "$ZSH_PLUGIN_DIR/zsh-defer" \
  https://github.com/romkatv/zsh-defer

clone_if_missing "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting" \
  https://github.com/zsh-users/zsh-syntax-highlighting

clone_if_missing "$ZSH_PLUGIN_DIR/zsh-autosuggestions" \
  https://github.com/zsh-users/zsh-autosuggestions

# =============================
# Plugins
# =============================

# zsh-defer
source "$ZSH_PLUGIN_DIR/zsh-defer/zsh-defer.plugin.zsh"

# compinit
autoload -Uz compinit
zsh-defer compinit

# syntax highlighting
zsh-defer source "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# autosuggestions
zsh-defer source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
ZSH_AUTOSUGGEST_STRATEGY=(history)

# ollama suggestions 
export ZSH_OLLAMA_MODEL="qwen2.5-coder:7b"
export ZSH_OLLAMA_URL="http://127.0.0.1:11434"
export ZSH_OLLAMA_COMMANDS_HOTKEY="^g"

if [ -f ~/.config/zsh/plugins/zsh-ollama-command/zsh-ollama-command.zsh ]; then
    zsh-defer source ~/.config/zsh/plugins/zsh-ollama-command/zsh-ollama-command.zsh
fi

# =============================
# Language/toolchain managers
# =============================

# sdkman
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && zsh-defer source "$HOME/.sdkman/bin/sdkman-init.sh"

# nvm
[[ -s "$NVM_DIR/nvm.sh" ]] && zsh-defer source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && zsh-defer source "$NVM_DIR/bash_completion"

# bun
[[ -s "$BUN_INSTALL/_bun" ]] && zsh-defer source "$BUN_INSTALL/_bun"

# =============================
# Prompt + shell enhancements
# =============================

# Starship
eval "$(starship init zsh)"
setopt PROMPT_CR PROMPT_SP

# Atuin
eval "$(atuin init zsh --disable-up-arrow)"
bindkey '^f' atuin-search

# zoxide
eval "$(zoxide init zsh)"


# =============================
# Exports
# =============================
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
export GDK_DPI_SCALE=0.9
export QT_QPA_PLATFORMTHEME=qt5ct

# PATH additions
export PATH="/opt/android-sdk/cmdline-tools/latest/bin:$PATH"
export PATH="/opt/android-sdk/platform-tools:$PATH"
export PATH="/opt/flutter/bin:$PATH"
export PATH="$PATH:$HOME/.local/scr"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/go/bin"
export PATH="$PATH:$JAVA_HOME/bin"
export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/apps/intellij-idea/bin"

export ANDROID_HOME=/opt/android-sdk
export CHROME_EXECUTABLE="/var/lib/flatpak/exports/bin/io.github.ungoogled_software.ungoogled_chromium"
export PATH="$PATH:$HOME/.pub-cache/bin"

# bun PATH
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


# =============================
# pnpm
# =============================
export PNPM_HOME="/home/ivfrost/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac


# =============================
# User-specific configs
# =============================
[ -f "$ZDOTDIR/.zshrc.local" ] && source "$ZDOTDIR/.zshrc.local"

