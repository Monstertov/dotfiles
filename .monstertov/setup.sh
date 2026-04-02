#!/usr/bin/env bash
# setup.sh — bootstrap monstertov's shell environment on a fresh system
set -euo pipefail

GITHUB_DOTFILES="https://github.com/Monstertov/dotfiles"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Colors ────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
info()    { echo -e "${CYAN}${BOLD}==> $*${RESET}"; }
success() { echo -e "${GREEN}✓ $*${RESET}"; }
warn()    { echo -e "${RED}! $*${RESET}"; }
abort()   { echo -e "\n${RED}${BOLD}ABORT: $*${RESET}\n" >&2; exit 1; }

# ── Parse arguments ───────────────────────────────────────────────────────
FORCE=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=true; shift ;;
    *) abort "Unknown argument: $1" ;;
  esac
done

# ── Already installed check ────────────────────────────────────────────────
if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
  if [[ "$FORCE" == false ]]; then
    abort "~/.zshrc already exists. Remove it first if you want to reinstall:
  rm ~/.zshrc
  (a backup is a good idea: cp ~/.zshrc ~/.zshrc.bak)

Or use --force to overwrite:"
  else
    warn "~/.zshrc exists, backing up to ~/.zshrc.bak..."
    cp "$HOME/.zshrc" "$HOME/.zshrc.bak"
  fi
fi

# ── Self-bootstrap: clone repo if files not present ───────────────────────
if [[ ! -f "$DOTFILES_DIR/.monstertov/.zshrc" ]]; then
  info "Dotfiles not found at $DOTFILES_DIR — cloning from GitHub..."
  DOTFILES_DIR="$HOME/.dotfiles"
  if [[ -d "$DOTFILES_DIR/.git" ]]; then
    info "~/.dotfiles already exists, pulling latest..."
    git -C "$DOTFILES_DIR" pull --ff-only || warn "Pull failed, using existing clone"
  else
    git clone "$GITHUB_DOTFILES" "$DOTFILES_DIR"
  fi
  success "Dotfiles ready at $DOTFILES_DIR"
fi

# ── Verify all required files ─────────────────────────────────────────────
missing=()
for f in ".monstertov/.zshrc" ".monstertov/sharp.zsh-theme" ".tmux.conf"; do
  [[ -f "$DOTFILES_DIR/$f" ]] || missing+=("$DOTFILES_DIR/$f")
done
if (( ${#missing[@]} > 0 )); then
  echo -e "${RED}${BOLD}ABORT: Required files missing:${RESET}" >&2
  for f in "${missing[@]}"; do echo "  $f" >&2; done
  exit 1
fi

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
missing_pkgs=()
for cmd in zsh tmux git curl xclip wl-clipboard zoxide; do
  command -v "$cmd" &>/dev/null || missing_pkgs+=("$cmd")
done

if (( ${#missing_pkgs[@]} > 0 )); then
  info "Installing system packages: ${missing_pkgs[*]}..."
  sudo apt update -qq
  sudo apt install -y "${missing_pkgs[@]}" command-not-found
  success "System packages installed"
else
  success "All system packages already installed"
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

install_plugin zsh-autosuggestions      https://github.com/zsh-users/zsh-autosuggestions
install_plugin zsh-syntax-highlighting  https://github.com/zsh-users/zsh-syntax-highlighting
install_plugin history-substring-search https://github.com/zsh-users/zsh-history-substring-search

# ── Sharp theme ───────────────────────────────────────────────────────────
info "Installing sharp theme..."
cp "$DOTFILES_DIR/.monstertov/sharp.zsh-theme" "$OMZ_CUSTOM/themes/sharp.zsh-theme"
success "sharp theme installed"

# ── .zshrc ────────────────────────────────────────────────────────────────
info "Installing .zshrc..."
cp "$DOTFILES_DIR/.monstertov/.zshrc" "$HOME/.zshrc"
success ".zshrc installed → ~/.zshrc"

# ── .tmux.conf ────────────────────────────────────────────────────────────
info "Installing .tmux.conf..."
if [[ -f "$HOME/.tmux.conf" && ! -L "$HOME/.tmux.conf" ]]; then
  warn ".tmux.conf already exists — skipping (remove ~/.tmux.conf to reinstall)"
else
  cp "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
  success ".tmux.conf installed → ~/.tmux.conf"
fi

# ── .dircolors (bright blue folders for better visibility) ──────────────
if [[ -f "$DOTFILES_DIR/.monstertov/.dircolors" ]]; then
  info "Installing .dircolors..."
  cp "$DOTFILES_DIR/.monstertov/.dircolors" "$HOME/.dircolors"
  success ".dircolors installed → ~/.dircolors"
fi

# ── Claude Code statusLine (claude-hud) ───────────────────────────────────
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
if [[ -f "$CLAUDE_SETTINGS" ]]; then
  if ! grep -q "claude-hud" "$CLAUDE_SETTINGS"; then
    info "Adding claude-hud statusLine to Claude Code settings..."
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

# ── Claude HUD config ─────────────────────────────────────────────────────
if [[ -f "$DOTFILES_DIR/.monstertov/claude-hud-config.json" ]]; then
  info "Installing claude-hud config..."
  mkdir -p "$HOME/.claude/plugins/claude-hud"
  cp "$DOTFILES_DIR/.monstertov/claude-hud-config.json" "$HOME/.claude/plugins/claude-hud/config.json"
  success "claude-hud config installed → ~/.claude/plugins/claude-hud/config.json"
fi

# ── Convertible/2-in-1 Support (auto-rotation + keyboard inhibit) ──────────
info "Configuring convertible display support..."

# Enable hinge sensor driver (ThinkPad X1 2-in-1, Framework, etc.)
echo "hid_sensor_custom_intel_hinge" | sudo tee /etc/modules-load.d/hid-hinge-sensor.conf >/dev/null 2>&1 || true
sudo modprobe hid_sensor_custom_intel_hinge 2>/dev/null || true

# Ensure iio-sensor-proxy is installed and running
if command -v iio-sensor-proxy &>/dev/null; then
  sudo systemctl start iio-sensor-proxy 2>/dev/null || true
  success "iio-sensor-proxy running"
else
  success "iio-sensor-proxy not installed (install for full convertible support)"
fi

# Desktop environment specific config
if [[ "$XDG_CURRENT_DESKTOP" == *"KDE"* || "$DESKTOP_SESSION" == *"plasma"* ]]; then
  # KDE/Plasma: enable screen rotation
  kwriteconfig6 --file kscreenrc --group General --key AutoRotation "true" 2>/dev/null || true
  success "Auto-rotation enabled for KDE"
elif [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* || "$DESKTOP_SESSION" == *"gnome"* ]]; then
  # GNOME: auto-rotation + automatic keyboard inhibit on tablet mode
  gsettings set org.gnome.settings-daemon.peripherals.touchscreen orientation-lock false 2>/dev/null || true
  success "Auto-rotation + keyboard inhibit enabled for GNOME (libinput 5.11+)"
else
  success "Desktop environment not detected (convertible support can be enabled manually later)"
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
