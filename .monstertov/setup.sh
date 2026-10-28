#!/usr/bin/env bash
# setup.sh: bootstrap monstertov's shell environment on a fresh system
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
ZSHRC_BACKED_UP=false
if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
  if [[ "$FORCE" == false ]]; then
    abort "~/.zshrc already exists. Remove it first if you want to reinstall:
  rm ~/.zshrc
  (a backup is a good idea: cp ~/.zshrc ~/.zshrc.bak)

Or use --force to overwrite:"
  else
    warn "~/.zshrc exists, backing up to ~/.zshrc.bak..."
    cp "$HOME/.zshrc" "$HOME/.zshrc.bak"
    ZSHRC_BACKED_UP=true
  fi
fi

# ── Self-bootstrap: clone repo if files not present ───────────────────────
if [[ ! -f "$DOTFILES_DIR/.monstertov/.zshrc" ]]; then
  info "Dotfiles not found at $DOTFILES_DIR, cloning from GitHub..."
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
  echo "  zsh tmux git fzf xclip wl-clipboard"
  echo ""
  echo "Also install zoxide from: https://github.com/ajeetdsouza/zoxide"
  echo "  (cargo install zoxide  OR  your distro's package)"
  exit 1
fi

# ── APT dependencies (command it provides : package) ──────────────────────
missing_pkgs=()
for pair in zsh:zsh tmux:tmux git:git fzf:fzf zoxide:zoxide xclip:xclip wl-copy:wl-clipboard \
            /usr/lib/command-not-found:command-not-found; do
  command -v "${pair%%:*}" &>/dev/null || missing_pkgs+=("${pair#*:}")
done

if (( ${#missing_pkgs[@]} > 0 )); then
  info "Installing system packages: ${missing_pkgs[*]}..."
  sudo apt-get update -qq
  sudo apt-get install -y "${missing_pkgs[@]}"
  # command-not-found only learns which package has which command on the next update
  if [[ " ${missing_pkgs[*]} " == *" command-not-found "* ]]; then
    sudo apt-get update -qq
  fi
  success "System packages installed"
else
  success "All system packages already installed"
fi

# ── Oh My Zsh ─────────────────────────────────────────────────────────────
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  info "Installing Oh My Zsh..."
  # a plain clone, which is what its installer does too, without piping a script into sh
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
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
# history-substring-search comes with Oh My Zsh

# ── Sharp theme ───────────────────────────────────────────────────────────
info "Installing sharp theme..."
cp "$DOTFILES_DIR/.monstertov/sharp.zsh-theme" "$OMZ_CUSTOM/themes/sharp.zsh-theme"
success "sharp theme installed"

# ── .zshrc ────────────────────────────────────────────────────────────────
info "Installing .zshrc..."
cp "$DOTFILES_DIR/.monstertov/.zshrc" "$HOME/.zshrc"
# keep the monstertov-ai-hud block of the replaced .zshrc (the HUD would add it back on its next update)
if [[ "$ZSHRC_BACKED_UP" == true ]]; then
  hud_block=$(sed -n '/^# >>> monstertov-ai-hud >>>$/,/^# <<< monstertov-ai-hud <<<$/p' "$HOME/.zshrc.bak")
  [[ -n "$hud_block" ]] && printf '\n%s\n' "$hud_block" >> "$HOME/.zshrc"
fi
success ".zshrc installed → ~/.zshrc"

# ── .zprofile (login shells read ~/.profile for PATH, like bash) ─────────
if [[ -f "$HOME/.zprofile" ]]; then
  warn ".zprofile already exists, skipping (remove ~/.zprofile to reinstall)"
else
  cp "$DOTFILES_DIR/.monstertov/.zprofile" "$HOME/.zprofile"
  success ".zprofile installed → ~/.zprofile"
fi

# ── zsh history: start from the bash history, so suggestions and fuzzy search have something ──
if [[ ! -f "$HOME/.zsh_history" && -s "$HOME/.bash_history" ]]; then
  info "Importing bash history into zsh..."
  HISTFILE="$HOME/.zsh_history" HISTSIZE=50000 SAVEHIST=50000 \
    zsh -f -i -c 'setopt extended_history; fc -R ~/.bash_history; fc -W' </dev/null >/dev/null 2>&1 || true
  if [[ -f "$HOME/.zsh_history" ]]; then
    chmod 600 "$HOME/.zsh_history"
    success "bash history imported → ~/.zsh_history"
  else
    warn "bash history import failed, zsh starts with an empty history"
  fi
fi

# ── .tmux.conf ────────────────────────────────────────────────────────────
info "Installing .tmux.conf..."
if [[ -f "$HOME/.tmux.conf" && ! -L "$HOME/.tmux.conf" ]]; then
  warn ".tmux.conf already exists, skipping (remove ~/.tmux.conf to reinstall)"
else
  cp "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
  success ".tmux.conf installed → ~/.tmux.conf"
fi

# ── .inputrc (Ctrl+Backspace deletes a word in bash/readline) ────────────
info "Installing .inputrc..."
if [[ -f "$HOME/.inputrc" && ! -L "$HOME/.inputrc" ]]; then
  warn ".inputrc already exists, skipping (remove ~/.inputrc to reinstall)"
else
  cp "$DOTFILES_DIR/.inputrc" "$HOME/.inputrc"
  success ".inputrc installed → ~/.inputrc"
fi

# ── .dircolors (bright blue folders for better visibility) ──────────────
if [[ -f "$DOTFILES_DIR/.monstertov/.dircolors" ]]; then
  info "Installing .dircolors..."
  cp "$DOTFILES_DIR/.monstertov/.dircolors" "$HOME/.dircolors"
  success ".dircolors installed → ~/.dircolors"
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
