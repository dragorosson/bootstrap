#!/usr/bin/env zsh
#
# Bootstraps a fresh Mac just far enough to hand off to the real setup repo.
# Steps:
#   1. Install Homebrew (which installs Xcode CLT itself if needed)
#   2. Install git and gh
#   3. Run `gh auth login`
#   4. Clone dragorosson/setup-mac
#   5. Exec setup-mac's own init.sh
#
# This script (dragorosson/bootstrap) stays intentionally thin. Everything
# specific to how the machine actually gets set up lives in setup-mac.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/dragorosson/bootstrap/main/mac.sh | zsh
#
set -euo pipefail

SETUP_REPO_SLUG="dragorosson/setup-mac"
CLONE_DIR="$HOME/workspace/${SETUP_REPO_SLUG}"

log() {
  print -P "%F{blue}==>%f $1"
}

if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

log "Installing git and gh..."
brew install git gh

if ! gh auth status >/dev/null 2>&1; then
  log "Log into GitHub (this opens a browser)..."
  gh auth login
fi

mkdir -p "${CLONE_DIR:h}"
if [[ ! -d "$CLONE_DIR" ]]; then
  log "Cloning ${SETUP_REPO_SLUG} into ${CLONE_DIR}..."
  gh repo clone "$SETUP_REPO_SLUG" "$CLONE_DIR"
else
  log "${CLONE_DIR} already exists, skipping clone."
fi

log "Handing off to setup-mac..."
cd "$CLONE_DIR"
exec ./init.sh
