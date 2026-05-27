# =============================
# Zsh settings
# =============================
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
alias vzs="nvim $ZDOTDIR/.zshrc"
alias files="nautilus ."
alias lsa="ls -a"
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

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

# NixOS
alias nrs="sudo nixos-rebuild switch"


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
# Plugins
# =============================

# zsh-defer
source "$ZSH_PLUGIN_DIR/zsh-defer/zsh-defer.plugin.zsh"

# compinit MUST run immediately
autoload -Uz compinit
zsh-defer compinit

# syntax highlighting AFTER compinit
zsh-defer source "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# autosuggestions AFTER compinit
zsh-defer source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
ZSH_AUTOSUGGEST_STRATEGY=(history)


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

