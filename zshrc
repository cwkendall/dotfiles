# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# Native zsh completion, without a shell framework.
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

alias cat='bat --paging=never'
alias ll='eza --long --all --group-directories-first --git'

if command -v zed >/dev/null 2>&1; then
  export EDITOR='zed --wait'
  export VISUAL="$EDITOR"
else
  export EDITOR='vim'
  export VISUAL="$EDITOR"
fi

# Retrieve developer-created generic passwords from the macOS Keychain.
# Usage: keychain_secret OPENAI_API_KEY
keychain_secret() {
  /usr/bin/security find-generic-password -a "$USER" -s "$1" -w 2>/dev/null
}

# Add or replace a generic password, prompting without exposing it in history.
# Usage: keychain_store OPENAI_API_KEY
keychain_store() {
  /usr/bin/security add-generic-password -U -a "$USER" -s "$1" -w
}
