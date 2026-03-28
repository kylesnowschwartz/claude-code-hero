#!/usr/bin/env bash
# Install script for Claude Code Hero.
# Checks for required dependencies and installs any that are missing.
#
# Dependencies:
#   ruby   -- runs the game engine (scripts/cli.rb)
#   jq     -- parses JSON in hook scripts
#   claude -- the Claude Code CLI from Anthropic
#
# Supports macOS (Homebrew) and Linux (apt + official installers).
# Does not support Windows natively -- use WSL.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
RESET='\033[0m'

info() { printf "${BOLD}%s${RESET}\n" "$1"; }
ok() { printf "${GREEN}OK${RESET} %s\n" "$1"; }
warn() { printf "${YELLOW}!!${RESET} %s\n" "$1"; }
fail() { printf "${RED}FAIL${RESET} %s\n" "$1"; }

OS="unknown"
case "$(uname -s)" in
Darwin*) OS="macos" ;;
Linux*) OS="linux" ;;
*) OS="unknown" ;;
esac

HAS_BREW=false
HAS_APT=false
command -v brew >/dev/null 2>&1 && HAS_BREW=true
command -v apt-get >/dev/null 2>&1 && HAS_APT=true

install_with_brew() {
  if ! $HAS_BREW; then
    fail "Homebrew not found. Install it from https://brew.sh then re-run this script."
    return 1
  fi
  info "Installing $1 with Homebrew..."
  brew install "$1"
}

install_with_apt() {
  if ! $HAS_APT; then
    fail "apt-get not found. Install $1 manually."
    return 1
  fi
  info "Installing $1 with apt-get..."
  sudo apt-get update -qq && sudo apt-get install -y "$1"
}

install_package() {
  local pkg="$1"
  case "$OS" in
  macos) install_with_brew "$pkg" ;;
  linux) install_with_apt "$pkg" ;;
  *)
    fail "Unsupported OS. Install $pkg manually."
    return 1
    ;;
  esac
}

# -- Claude Code --
# Official installer: https://docs.anthropic.com/en/docs/claude-code/getting-started
install_claude() {
  info "Installing Claude Code via official installer..."
  info "Source: https://docs.anthropic.com/en/docs/claude-code/getting-started"
  curl -fsSL https://claude.ai/install.sh | bash
}

printf "\n"
info "Claude Code Hero -- Dependency Check"
info "====================================="
printf "\n"

MISSING=()

# Check Ruby
# https://www.ruby-lang.org/en/documentation/installation/
if command -v ruby >/dev/null 2>&1; then
  ok "ruby $(ruby -e 'puts RUBY_VERSION')"
else
  fail "ruby not found"
  MISSING+=("ruby")
fi

# Check jq
# https://jqlang.org/download/
if command -v jq >/dev/null 2>&1; then
  ok "jq $(jq --version)"
else
  fail "jq not found"
  MISSING+=("jq")
fi

# Check Claude Code
# https://docs.anthropic.com/en/docs/claude-code/getting-started
if command -v claude >/dev/null 2>&1; then
  ok "claude ($(claude --version 2>/dev/null || echo 'version unknown'))"
else
  fail "claude not found"
  MISSING+=("claude")
fi

printf "\n"

if [ ${#MISSING[@]} -eq 0 ]; then
  info "All dependencies present. Ready to play!"
  printf "\n"
  info "Run:  claude --plugin-dir . --agent dungeon-master"
  printf "\n"
  exit 0
fi

info "Missing: ${MISSING[*]}"
printf "\n"
read -rp "Install missing dependencies? [y/N] " answer
if [[ ! "$answer" =~ ^[Yy] ]]; then
  warn "Skipped. Install manually and re-run."
  exit 1
fi

printf "\n"

FAILED=()
for dep in "${MISSING[@]}"; do
  case "$dep" in
  ruby | jq) install_package "$dep" || FAILED+=("$dep") ;;
  claude) install_claude || FAILED+=("$dep") ;;
  esac
  printf "\n"
done

if [ ${#FAILED[@]} -gt 0 ]; then
  fail "Could not install: ${FAILED[*]}"
  warn "Install them manually, then re-run this script."
  exit 1
fi

info "All dependencies installed. Ready to play!"
printf "\n"
info "Run:  claude --plugin-dir . --agent dungeon-master"
printf "\n"
