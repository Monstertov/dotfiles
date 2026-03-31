#!/usr/bin/env bash
# setup.sh — bootstrap monstertov's shell environment on a fresh system
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ── Colors ────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
info()    { echo -e "${CYAN}${BOLD}==> $*${RESET}"; }
success() { echo -e "${GREEN}✓ $*${RESET}"; }
warn()    { echo -e "${RED}✗ $*${RESET}"; }

# ── Package manager check ──────────────────────────────────────────────────
if ! command -v apt &>/dev/null; then
  warn "apt not found. This script targets Debian/Ubuntu systems."
  echo ""
  echo "Install these packages manually with your package manager, then re-run:"
  echo "  zsh tmux git curl xclip wl-clipboard"
  echo ""
  echo "Also install zoxide from: https://github.com/ajeetdsouza/zoxide"
  echo "  (cargo install zoxide  OR  your distro's package)"
  exit 1
fi

# ── APT dependencies ──────────────────────────────────────────────────────
info "Installing system packages..."
sudo apt update -qq
sudo apt install -y zsh tmux git curl xclip wl-clipboard command-not-found
success "System packages installed"

# ── zoxide ────────────────────────────────────────────────────────────────
if ! command -v zoxide &>/dev/null; then
  info "Installing zoxide..."
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  success "zoxide installed"
else
  success "zoxide already installed"
fi

# ── Oh My Zsh ─────────────────────────────────────────────────────────────
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  info "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  success "Oh My Zsh installed"
else
  success "Oh My Zsh already installed"
fi

OMZ_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ── OMZ plugins ───────────────────────────────────────────────────────────
install_plugin() {
  local name="$1" repo="$2"
  local dest="$OMZ_CUSTOM/plugins/$name"
  if [[ ! -d "$dest" ]]; then
    info "Installing plugin: $name"
    git clone --depth=1 "$repo" "$dest"
    success "$name installed"
  else
    success "$name already installed"
  fi
}

install_plugin zsh-autosuggestions     https://github.com/zsh-users/zsh-autosuggestions
install_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting
install_plugin history-substring-search https://github.com/zsh-users/zsh-history-substring-search

# ── Sharp theme ───────────────────────────────────────────────────────────
info "Installing sharp theme..."
cp "$DOTFILES_DIR/.monstertov/sharp.zsh-theme" "$OMZ_CUSTOM/themes/sharp.zsh-theme"
success "sharp theme installed"

# ── .zshrc ────────────────────────────────────────────────────────────────
info "Linking .zshrc..."
if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
  cp "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%Y%m%d%H%M%S)"
  echo "  (backed up existing .zshrc)"
fi
cp "$DOTFILES_DIR/.monstertov/.zshrc" "$HOME/.zshrc"
success ".zshrc installed"

# ── .tmux.conf ────────────────────────────────────────────────────────────
info "Linking .tmux.conf..."
if [[ -f "$HOME/.tmux.conf" && ! -L "$HOME/.tmux.conf" ]]; then
  cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak.$(date +%Y%m%d%H%M%S)"
  echo "  (backed up existing .tmux.conf)"
fi
cp "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
success ".tmux.conf installed"

# ── Claude HUD config ─────────────────────────────────────────────────────
info "Installing claude-hud config..."
mkdir -p "$HOME/.claude/plugins/claude-hud"
cp "$DOTFILES_DIR/.monstertov/claude-hud-config.json" "$HOME/.claude/plugins/claude-hud/config.json"
success "claude-hud config installed"

# ── claude-hud statusLine in Claude Code settings ─────────────────────────
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
if [[ -f "$CLAUDE_SETTINGS" ]]; then
  if ! grep -q "claude-hud" "$CLAUDE_SETTINGS"; then
    info "Adding claude-hud statusLine to Claude Code settings..."
    # Insert statusLine before the last closing brace using python (no jq needed)
    python3 - "$CLAUDE_SETTINGS" <<'PYEOF'
import json, sys
path = sys.argv[1]
with open(path) as f:
    cfg = json.load(f)
cfg.setdefault('statusLine', {
    'type': 'command',
    'command': r"""bash -c 'dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/plugins/cache/claude-hud/claude-hud"; latest=$(ls "$dir" 2>/dev/null | sort -V | tail -1); exec node "$dir/$latest/dist/index.js"'"""
})
with open(path, 'w') as f:
    json.dump(cfg, f, indent=2)
PYEOF
    success "claude-hud statusLine added"
  else
    success "claude-hud statusLine already configured"
  fi
else
  warn "~/.claude/settings.json not found — install Claude Code first, then re-run to add the HUD"
fi

# ── Default shell → zsh ───────────────────────────────────────────────────
ZSH_PATH="$(command -v zsh)"
CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
  info "Setting zsh as default shell..."
  if ! grep -qF "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
  fi
  chsh -s "$ZSH_PATH"
  success "Default shell set to zsh (takes effect on next login)"
else
  success "zsh is already the default shell"
fi

# ── Done ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}${BOLD}All done! Open a new terminal (or run: exec zsh)${RESET}"
