# .bashrc

# Bash Settings
set -o vi
HISTTIMEFORMAT="%F %T "
HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=10000
export HISTFILESIZE=20000
shopt -s histappend
PROMPT_COMMAND='history -a; history -n'


# Aliases: Directory Navigation
alias ..='cd ..'
alias ~='cd ~'
alias dsk='cd ~/Desktop'
alias dwn='cd ~/Downloads'
alias doc='cd ~/Documents'
alias pjt='cd ~/Documents/Projects'
alias vid='cd ~/Videos'
alias mus='cd ~/Music'
alias hdd='cd /mnt/hdd'
alias opt='cd /opt'
alias srv='cd /srv'
shopt -s autocd

# Aliases: Commands
alias sudo='sudo '
alias doas='sudo '
alias v='nvim '
alias sbs='. ~/.bashrc'
alias vbs='nvim ~/.bashrc'
alias lsa='ls -a'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias dcud='docker-compose up -d'
alias dcu='docker-compose up'
alias dcufr='docker-compose up --force-recreate'
alias dcd='docker-compose down'
alias dcdro='docker-compose down --remove-orphans'
alias swallow='$HOME/.config/sway/scripts/swallow.sh'
alias mpv='swallow mpv '

# User specific configs
[ -f "$HOME/.bashrc.local" ] && source "$HOME/.bashrc.local"

# Exports
[ -f "$HOME/git-prompt.sh" ] && source "$HOME/git-prompt.sh"
export GIT_SSH_COMMAND='ssh -i ~/.ssh/id_rsa'
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
export XDG_CURRENT_DESKTOP=sway
export GDK_DPI_SCALE=1.1

# Update PATH
export PATH=$PATH:$HOME/.local/scr
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/go/bin
export PATH=$PATH:$JAVA_HOME/bin

# sdkman - JVM SDKs
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# nvm - Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Bash Completion
if [ -f /etc/bash_completion ]; then
  source /etc/bash_completion
fi

# PS1
export PS1='\[$(tput bold)\]\[$(tput setaf 4)\][\u@\h \W$(__git_ps1 " *%s")]$ \[$(tput sgr0)\]'
