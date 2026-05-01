source "$ZDOTDIR/zsh-defer/zsh-defer.plugin.zsh"

# Zsh Settings
setopt noglob
bindkey -v
bindkey '^?' backward-delete-char 
bindkey '^H' backward-kill-word
bindkey -M viins '^[[1;5D' backward-word
bindkey -M viins '^[[1;5C' forward-word
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
HISTFILE=$ZDOTDIR/.zsh_history
HISTSIZE=10000
SAVEHIST=20000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt AUTO_CD

# Aliases: Directory Navigation
alias ..='cd ..'
alias ~='cd ~'
alias dsk='cd ~/Desktop'
alias dwn='cd ~/Downloads'
alias doc='cd ~/Documents'
alias pjt='cd ~/Documents/Projects/'
alias vid='cd ~/Videos'
alias noi='cd ~/Videos/Noises'
alias mus='cd ~/Music'
alias hdd='cd /mnt/hdd'
alias opt='cd /opt'
alias dot="cd $XDG_CONFIG_HOME/dotfiles/"
alias srv='cd /srv'

# Aliases: Commands
alias sudo='sudo '
alias doas='sudo '
alias dnfi='sudo dnf install -y '
alias dnfr='sudo dnf remove -y '
alias dnfu='sudo dnf upgrade -y '
alias dnfs='sudo dnf search '
alias dnfl='sudo dnf list '
alias v='nvim '
alias szs="source $ZDOTDIR/.zshrc"
alias vzs="nvim $ZDOTDIR/.zshrc"
alias vsw="nvim $XDG_CONFIG_HOME/sway/config"
alias vwb="nvim $XDG_CONFIG_HOME/waybar/config"
alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'
alias files='nautilus .'
alias lsa='ls -a'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias gitsummary='$HOME/.local/bin/gitsummary'
alias cine='/var/lib/flatpak/app/io.github.diegopvlk.Cine/x86_64/stable/active/export/bin/io.github.diegopvlk.Cine --new-window'
alias android_studio='/home/ivfrost/.local/share/JetBrains/Toolbox/apps/android-studio/bin/studio.sh '


# Aliases: Docker
alias dcpud='docker-compose up -d'
alias dcpu='docker-compose up'
alias dcpufr='docker-compose up --force-recreate'
alias dcpd='docker-compose down'
alias dcpdro='docker-compose down --remove-orphans'

# Aliases: Flutter 
alias fr='flutter run'
alias fdr='flutter doctor'
alias fpg='flutter pub get'
alias fpr='flutter pub remove '
alias fpa='flutter pub add '
alias fcl='flutter clean && flutter pub get'
alias fls='flutter devices'

# User specific configs
[ -f "$ZDOTDIR/.zshrc.local" ] && source "$ZDOTDIR/.zshrc.local"

# Exports
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
#export XDG_CURRENT_DESKTOP=sway
export GDK_DPI_SCALE=0.9
#export SSH_AUTH_SOCK=/run/user/1000/keyring/ssh

# QT Apps
export QT_QPA_PLATFORMTHEME=qt5ct

# Update PATH
export PATH="/opt/android-sdk/cmdline-tools/latest/bin:$PATH"
export PATH="/opt/android-sdk/platform-tools:$PATH"
export PATH="/opt/flutter/bin:$PATH"
export PATH=$PATH:$HOME/.local/scr
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/go/bin
export PATH=$PATH:$JAVA_HOME/bin
export PATH=$PATH:$HOME/.local/share/JetBrains/Toolbox/apps/intellij-idea/bin

# Flutter
export ANDROID_HOME=/opt/android-sdk
export CHROME_EXECUTABLE="/var/lib/flatpak/exports/bin/io.github.ungoogled_software.ungoogled_chromium"
export PATH="$PATH":"$HOME/.pub-cache/bin"

# sdkman - JVM SDKs
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && zsh-defer source "$HOME/.sdkman/bin/sdkman-init.sh"

# nvm - Node Version Manager
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && zsh-defer source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && zsh-defer source "$NVM_DIR/bash_completion"

# Zsh Completion
autoload -Uz compinit
zsh-defer compinit

# Zsh AI suggestions 
export ZSH_OLLAMA_MODEL="qwen2.5-coder:7b"
export ZSH_OLLAMA_URL="http://127.0.0.1:11434"
export ZSH_OLLAMA_COMMANDS_HOTKEY="^g"

if [ -f ~/.config/zsh/plugins/zsh-ollama-command/zsh-ollama-command.zsh ]; then
    zsh-defer source ~/.config/zsh/plugins/zsh-ollama-command/zsh-ollama-command.zsh
fi

if [ -f ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    zsh-defer source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_STRATEGY=(history)
fi

if [ -f ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    zsh-defer source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Starship 
if [[ -z "$STARSHIP_INITIALIZED" ]]; then
    export STARSHIP_INITIALIZED=1
    eval "$(starship init zsh)"
fi
setopt PROMPT_CR
setopt PROMPT_SP


# pnpm
export PNPM_HOME="/home/ivfrost/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Atuin
eval "$(atuin init zsh --disable-up-arrow)"
bindkey '^f' atuin-search

# zoxide
eval "$(zoxide init zsh)"
