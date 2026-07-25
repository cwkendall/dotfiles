#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  printf 'This bootstrap currently supports macOS only.\n' >&2
  exit 1
fi

DOTFILES_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)-$$"

if ! xcode-select -p >/dev/null 2>&1; then
  printf 'Requesting Apple Command Line Tools. Rerun this script after installation completes.\n'
  xcode-select --install
  exit 0
fi

if ! command -v brew >/dev/null 2>&1; then
  printf 'Installing Homebrew from the official installer...\n'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if ! command -v brew >/dev/null 2>&1; then
  printf 'Homebrew was installed but is not available on PATH. Open a new terminal and rerun this script.\n' >&2
  exit 1
fi

brew bundle install --file="$DOTFILES_DIR/Brewfile"

link_file() {
  local source_path="$1"
  local destination_path="$2"
  local relative_path

  mkdir -p "$(dirname -- "$destination_path")"

  if [[ -L "$destination_path" ]] && [[ "$(readlink "$destination_path")" == "$source_path" ]]; then
    printf 'Already linked: %s\n' "$destination_path"
    return
  fi

  if [[ -e "$destination_path" || -L "$destination_path" ]]; then
    relative_path="${destination_path#"$HOME"/}"
    mkdir -p "$BACKUP_DIR/$(dirname -- "$relative_path")"
    mv "$destination_path" "$BACKUP_DIR/$relative_path"
    printf 'Backed up: %s\n' "$destination_path"
  fi

  ln -s "$source_path" "$destination_path"
  printf 'Linked: %s\n' "$destination_path"
}

link_file "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/zprofile" "$HOME/.zprofile"
link_file "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/gitignore_global" "$HOME/.gitignore_global"
link_file "$DOTFILES_DIR/config/ghostty/config" "$HOME/.config/ghostty/config"
link_file "$DOTFILES_DIR/config/zed/settings.json" "$HOME/.config/zed/settings.json"
link_file "$DOTFILES_DIR/config/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
link_file "$DOTFILES_DIR/config/opencode/AGENTS.md" "$HOME/.config/opencode/AGENTS.md"

configure_git_identity() {
  local identity_file="$HOME/.gitconfig.local"
  local value

  if ! value="$(git config --global --get user.name 2>/dev/null)" || [[ -z "$value" ]]; then
    if [[ -t 0 ]]; then
      printf 'Git author name (leave blank to configure later): '
      IFS= read -r value
      if [[ -n "$value" ]]; then
        git config --file "$identity_file" user.name "$value"
      fi
    else
      printf 'Git author name is unset; configure it in %s before committing.\n' "$identity_file" >&2
    fi
  fi

  if ! value="$(git config --global --get user.email 2>/dev/null)" || [[ -z "$value" ]]; then
    if [[ -t 0 ]]; then
      printf 'Git author email (leave blank to configure later): '
      IFS= read -r value
      if [[ -n "$value" ]]; then
        git config --file "$identity_file" user.email "$value"
      fi
    else
      printf 'Git author email is unset; configure it in %s before committing.\n' "$identity_file" >&2
    fi
  fi
}

configure_git_identity

while read -r source skills; do
  [[ -z "$source" || "$source" == \#* ]] && continue
  read -r -a skill_names <<< "$skills"
  printf 'Installing OpenCode skills from %s...\n' "$source"
  bunx skills add "$source" --global --agent opencode --skill "${skill_names[@]}" --yes
done < "$DOTFILES_DIR/config/opencode/skills.txt"

printf '\nBootstrap complete. Open a new terminal, then follow README.md for authentication and optional tools.\n'
