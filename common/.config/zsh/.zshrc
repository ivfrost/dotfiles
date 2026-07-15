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
# Exports & Path
# =============================
export EDITOR=nvim
export JAVA_HOME=/usr/lib/jvm/java-25-openjdk
export GDK_DPI_SCALE=0.9
export QT_QPA_PLATFORMTHEME=qt5ct
export CHROME_EXECUTABLE="/var/lib/flatpak/exports/bin/io.github.ungoogled_software.ungoogled_chromium"
export ANDROID_HOME=$HOME/Android/Sdk
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="/home/ivfrost/.local/share/pnpm"
export PYENV_ROOT="$HOME/.pyenv"

# Path assembly
export PATH="/opt/android-sdk/cmdline-tools/latest/bin:$PATH"
export PATH="/opt/android-sdk/platform-tools:$PATH"
export PATH="/opt/flutter/bin:$PATH"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$PATH:$HOME/.local/scr"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/go/bin"
export PATH="$PATH:$JAVA_HOME/bin"
export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/apps/intellij-idea/bin"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$HOME/.pub-cache/bin"

# PNPM Path check
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac


# =============================
# Functions & Smart Helpers
# =============================

# Smart Pacman/Paru wrapper (replaces deprecated pac* aliases)
pac() {
    if [[ -z "$1" ]]; then
        paru
    elif [[ "$1" =~ ^-[RU] ]] || [[ "$1" =~ ^-S && ! "$1" =~ [sg] ]]; then
        # Needs root: sync, upgrade, remove, install
        sudo paru "$@"
    else
        # No root needed: search, info, query
        paru "$@"
    fi
}

# Force sudo to recognize user-defined shell functions
function sudo {
    if [[ "$1" == "pac" ]]; then
        # Bypass the binary lookup and evaluate the function locally
        shift
        pac "$@"
    else
        # Fall back to standard system sudo
        command sudo "$@"
    fi
}

# =============================
# Aliases
# =============================

# Navigation
alias ..="cd .."
alias ~="cd ~"
alias dsk="cd ~/Desktop"
alias dwn="cd ~/Downloads"
alias doc="cd ~/Documents"
alias pjt="cd ~/Projects/"
alias vid="cd ~/Videos"
alias noi="cd ~/Videos/Noises"
alias mus="cd ~/Music"
alias hdd="cd /mnt/hdd"
alias opt="cd /opt"
alias dot="cd $XDG_CONFIG_HOME/dotfiles/"
alias srv="cd /srv"

# System & Editor Utilities
alias sudo="sudo "
alias doas="sudo "
alias v="nvim "
alias vv="sudo -E nvim"
alias szs="source $ZDOTDIR/.zshrc"
alias vzs="nvim $XDG_CONFIG_HOME/dotfiles/common/.config/zsh/.zshrc"
alias files="nautilus ."
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'
alias gitsummary='$HOME/.local/bin/gitsummary'
alias yt-dlp='noglob yt-dlp '
alias idea="$HOME/.local/share/JetBrains/Toolbox/apps/intellij-idea-2/bin/idea "

# Modern Coreutils (eza)
alias ls="eza --icons=always --group-directories-first"
alias lsa="eza -a --icons=always --group-directories-first"
alias ll="eza -lh --icons=always --git --group-directories-first"

# Terminal UIs (TUIs)
alias lg="lazygit"
alias ld="lazydocker"

# Docker
alias dcpud="docker-compose up -d"
alias dcpu="docker-compose up"
alias dcpufr="docker-compose up --force-recreate"
alias dcpd="docker-compose down"
alias dcpdro="docker-compose down --remove-orphans"
alias dch="docker ps --format \"table {{.Names}}\t{{.Status}}\t{{.Ports}}\""

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
# Plugin auto-clone
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

clone_if_missing "$ZSH_PLUGIN_DIR/fzf-tab" \
  https://github.com/Aloxaf/fzf-tab


# =============================
# Plugins
# =============================

# zsh-defer
source "$ZSH_PLUGIN_DIR/zsh-defer/zsh-defer.plugin.zsh"

# compinit
autoload -Uz compinit
zsh-defer compinit

# fzf-tab (must be sourced after compinit but before syntax-highlighting)
zsh-defer source "$ZSH_PLUGIN_DIR/fzf-tab/fzf-tab.plugin.zsh"

# syntax highlighting
zsh-defer source "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# autosuggestions
zsh-defer source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

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
# Shell environments & Inits
# =============================

# Starship
eval "$(starship init zsh)"
setopt PROMPT_CR PROMPT_SP

# Atuin
eval "$(atuin init zsh --disable-up-arrow)"
bindkey '^f' atuin-search

# zoxide
eval "$(zoxide init zsh)"

# Pyenv
[[ -d $PYENV_ROOT/bin ]] && eval "$(pyenv init - zsh)"
eval "$(pyenv virtualenv-init -)"

# Envman
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# TheFuck (as please)
eval $(thefuck --alias please)


# =============================
# User-specific configs
# =============================
[ -f "$ZDOTDIR/.zshrc.local" ] && source "$ZDOTDIR/.zshrc.local"
