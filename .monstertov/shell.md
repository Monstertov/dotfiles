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
- Vi copy mode

**Claude HUD** (`claude-hud` plugin)
- Statusline inside Claude Code — always visible below your input
- Line 1: `[model] │ project git:(branch*) │ hostname │ duration`
- Line 2: `Context ████░░░░░░ 8% │ Usage ████░░░░░░ 25%`
- Tools / agents / todos lines appear live during sessions
- Full cyan color scheme matching the zsh/tmux theme

---

## Files

| File | Destination |
|------|-------------|
| `.monstertov/.zshrc` | `~/.zshrc` |
| `.monstertov/sharp.zsh-theme` | `~/.oh-my-zsh/custom/themes/sharp.zsh-theme` |
| `.tmux.conf` | `~/.tmux.conf` |
| `.monstertov/claude-hud-config.json` | `~/.claude/plugins/claude-hud/config.json` |

> **Note:** claude-hud itself must be installed via Claude Code: `/plugin marketplace add jarrodwatts/claude-hud`
> The setup script only drops the config and wires the statusLine in `~/.claude/settings.json`.
> The `host()` color patch (brightBlue → cyan) applies to the cached plugin at install time — re-apply after a plugin update.

Existing files are backed up with a timestamp before being replaced.
