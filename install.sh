#!/usr/bin/env bash
# Sets up this machine from rjparton_config. Safe to re-run:
# existing files are backed up before being replaced, and package/auth
# steps are skipped if already done.
set -euo pipefail

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf '==> %s\n' "$1"; }

# Symlink $1 (source, inside CONFIG_DIR) to $2 (destination in $HOME).
# If $2 already exists and isn't already the right symlink, back it up first.
link() {
  local src="$1" dest="$2"

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    log "Already linked: $dest"
    return
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    local backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$backup"
    log "Backed up existing $dest -> $backup"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  log "Linked $dest -> $src"
}

# --- Homebrew ---------------------------------------------------------

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if ! grep -qs 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
  { echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'; } >> "$HOME/.zprofile"
  log "Added Homebrew shellenv to ~/.zprofile"
fi

# --- Packages -----------------------------------------------------------
# Installed one at a time so a package that's already present outside
# Homebrew (e.g. an app installed manually) doesn't abort the whole run.

FORMULAE=(gh git tmux python node yarn)
CASKS=(warp visual-studio-code)

log "Installing packages via Homebrew..."

for pkg in "${FORMULAE[@]}"; do
  if brew list --formula "$pkg" >/dev/null 2>&1; then
    log "Already installed: $pkg"
  elif ! brew install "$pkg"; then
    log "WARNING: failed to install $pkg, continuing"
  fi
done

for pkg in "${CASKS[@]}"; do
  if brew list --cask "$pkg" >/dev/null 2>&1; then
    log "Already installed: $pkg"
  elif ! brew install --cask "$pkg"; then
    log "WARNING: failed to install $pkg (it may already be installed outside Homebrew), continuing"
  fi
done

if [ "$SHELL" != "/bin/zsh" ]; then
  log "Setting default shell to zsh..."
  chsh -s /bin/zsh
fi

if ! gh auth status >/dev/null 2>&1; then
  log "Running gh auth login..."
  gh auth login
fi

# --- Pure prompt submodule -----------------------------------------------

log "Initializing pure prompt submodule..."
git -C "$CONFIG_DIR" submodule update --init --recursive

# --- Dotfile symlinks -----------------------------------------------------

link "$CONFIG_DIR/git/gitconfig"    "$HOME/.gitconfig"
link "$CONFIG_DIR/git/gitignore"    "$HOME/.gitignore"
link "$CONFIG_DIR/tmux/tmux.conf"   "$HOME/.tmux.conf"
link "$CONFIG_DIR/vim/vimrc"        "$HOME/.vimrc"
link "$CONFIG_DIR/vim"              "$HOME/.vim"
link "$CONFIG_DIR/vim/init.vim"     "$HOME/.config/nvim/init.vim"

log "Done."
