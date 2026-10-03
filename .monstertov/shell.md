# Shell Setup

Run `.monstertov/setup.sh` on a fresh system to get the full environment.

**Requires apt (Debian/Ubuntu).** On other distros, install these manually first:
`zsh tmux git curl xclip wl-clipboard` + [zoxide](https://github.com/ajeetdsouza/zoxide)

---

## What it sets up

**Zsh + Oh My Zsh**
- Theme: `sharp` — cyan prompt with git branch on right
- Plugins: git, sudo, history, gh, zoxide, command-not-found, tmux, history-substring-search, zsh-autosuggestions, zsh-syntax-highlighting
- Right-arrow accepts autosuggestions, up/down arrows search history
- Sets zsh as your default shell

**tmux**
- Default shell: zsh
- Prefix: `C-b` (default)
- Split panes: `|` horizontal, `-` vertical
- Mouse on — right-click pastes from clipboard (`xclip` / `wl-clipboard`)
- Copy with `y` or mouse drag → clipboard
- Status bar: cyan accent, time + date on right
- Clickable links (OSC 8) passed through to your terminal, tmux 3.4+
- Vi copy mode

**Readline (bash, python REPL, etc.)**
- Ctrl+Backspace deletes the previous word (Windows Terminal sends it as `^H`)

**Claude Code**: not set up here. The status line, plugins and global instructions come from
[monstertov-claude-hud](https://github.com/Monstertov/monstertov-claude-hud) (`bash install.sh` there).

---

## Files

| File | Destination |
|------|-------------|
| `.monstertov/.zshrc` | `~/.zshrc` |
| `.monstertov/sharp.zsh-theme` | `~/.oh-my-zsh/custom/themes/sharp.zsh-theme` |
| `.tmux.conf` | `~/.tmux.conf` |
| `.inputrc` | `~/.inputrc` |

Existing files are backed up with a timestamp before being replaced.
