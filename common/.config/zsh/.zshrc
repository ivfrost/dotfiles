# .zshrc

# Zsh Settings
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
alias dnfi='dnf install -y '
alias dnfr='dnf remove -y '
alias dnfu='dnf upgrade -y '
alias v='nvim '
alias szs="source $ZDOTDIR/.zshrc"
alias vzs="nvim $ZDOTDIR/.zshrc"
alias vsw="nvim $XDG_CONFIG_HOME/sway/config"
alias vwb="nvim $XDG_CONFIG_HOME/waybar/config"
alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'
alias lsa='ls -a'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias dcpud='docker-compose up -d'
alias dcpu='docker-compose up'
alias dcpufr='docker-compose up --force-recreate'
alias dcpd='docker-compose down'
alias dcpdro='docker-compose down --remove-orphans'

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
export PATH=$PATH:$HOME/.local/scr
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/go/bin
export PATH=$PATH:$JAVA_HOME/bin
export PATH=$PATH:$HOME/.local/share/JetBrains/Toolbox/apps/intellij-idea/bin

# sdkman - JVM SDKs
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# nvm - Node Version Manager
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# Zsh Completion
autoload -Uz compinit
compinit

# starship
setopt PROMPT_CR
setopt PROMPT_SP

eval "$(starship init zsh)"

# pnpm
export PNPM_HOME="/home/ivfrost/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
